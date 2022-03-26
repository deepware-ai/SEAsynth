import sys
import os
import struct
from pathlib import Path
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras.layers import Conv2D
from tensorflow.keras.layers import MaxPooling2D
from tensorflow.keras.layers import Flatten
from tensorflow.keras.layers import Dense

# Load the data
minst = keras.datasets.mnist
(train_images, train_labels), (test_images, test_labels) = minst.load_data()

# Normalize the input image so that each pixel value is between 0 to 1.
train_images = train_images / 255.0
test_images = test_images / 255.0

# Create custom PynqNet model
model = keras.Sequential([
    keras.layers.InputLayer(input_shape=(28,28)),
    keras.layers.Reshape(target_shape=(28,28,1)),
    keras.layers.Conv2D(12, kernel_size=(3,3), 
        strides=(1,1), activation='relu', input_shape=(28,28,1), use_bias=False),
    keras.layers.MaxPooling2D(pool_size=(2,2)),
    keras.layers.MaxPooling2D(pool_size=(2,2)),
    keras.layers.Flatten(),
    keras.layers.Dense(10, activation='softmax', use_bias=False)
])

# Train the model
model.compile(
    optimizer="adam", 
    loss="sparse_categorical_crossentropy",
    metrics=["accuracy"]
)
model.fit(train_images, train_labels, epochs=10)
print("[Info]: PynqNet successfully trained.")

# Test accuracy
score = model.evaluate(test_images, test_labels, verbose=0)
print('Test loss:', score[0])
print('Test accuracy:', score[1])

# Extract trained layer values 
# (layer1 = 'conv2d', layer5 = 'dense')
npa_conv2d = model.layers[1].get_weights()[0]
npa_dense = model.layers[5].get_weights()[0]

# Output raw hexadecimal float32 values to 'cell-weights.mem' file
weights_conv2d_dir = "build/raw-mnist-weights-float32/conv2d"
weights_fc1_dir = "build/raw-mnist-weights-float32/fc"
Path(weights_conv2d_dir).mkdir(parents=True, exist_ok=True)
Path(weights_fc1_dir).mkdir(parents=True, exist_ok=True)
print("[Info]: Converting trained weight data to raw hexadecimal float32 values...")

# Convert conv2d layer values
cell_idx = 0
for row in npa_conv2d:
    for col in row:
        # Open weight-file-[cell-idx].mem
        cell_file = open(Path(weights_conv2d_dir + "/cell-weight-" + str(cell_idx) + ".mem"), 'w')

        # Get weights for the current cell idx
        for kernel_px in col[0]:
            f32_val = float(kernel_px)
            byte_arr = bytearray(struct.pack("f", f32_val))
            byte_lst = ["%02x" % b for b in byte_arr]
            byte_lst.reverse()
            raw_f32_val = "".join(byte_lst) + "\n"
            cell_file.write(raw_f32_val)
        
        # Close the cell's weight file; move to next cell
        cell_file.close()
        cell_idx += 1

# Convert dense layer values
cell_file = open(Path(weights_fc1_dir + "/cell-fc.mem"), 'w')
for ip in npa_dense:
    for op in ip:
        f32_val = float(op)
        byte_arr = bytearray(struct.pack("f", f32_val))
        byte_lst = ["%02x" % b for b in byte_arr]
        byte_lst.reverse()
        raw_f32_val = "".join(byte_lst) + "\n"
        cell_file.write(raw_f32_val)

# Close the 'cell_file'
cell_file.close() 
print("[Info]: Done.")

# Create quantized weight values
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_models_dir = Path("build/raw-mnist-weights-int8")
tflite_models_dir.mkdir(exist_ok=True, parents=True)
conv2d_dir = Path("build/raw-mnist-weights-int8/conv2d")
conv2d_dir.mkdir(exist_ok=True, parents=True)
fc_dir = Path("build/raw-mnist-weights-int8/fc")
fc_dir.mkdir(exist_ok=True, parents=True)
converter.optimizations = [tf.lite.Optimize.OPTIMIZE_FOR_SIZE]
mnist_train, _ = tf.keras.datasets.mnist.load_data()
images = tf.cast(mnist_train[0], tf.float32) / 255.0
mnist_ds = tf.data.Dataset.from_tensor_slices((images)).batch(1)
def representative_data_gen():
  for input_value in mnist_ds.take(100):
    yield [input_value]

# Write quantized weight values to files
converter.representative_dataset = representative_data_gen
tflite_model_quant = converter.convert()
tflite_model_quant_file = tflite_models_dir/"mnist_model_quant.tflite"
tflite_model_quant_file.write_bytes(tflite_model_quant)
interpreter = tf.lite.Interpreter(model_path="build/raw-mnist-weights-int8/mnist_model_quant.tflite")
tensor_details = interpreter.get_tensor_details() 
interpreter.allocate_tensors()

# Convert conv2d layer values
cell_idx = 0
for c2d in interpreter.tensor(tensor_details[2]["index"])()[0]:
    for col in c2d:
        # Open weight-file-[cell-idx].mem
        cell_file = open(Path("build/raw-mnist-weights-int8/conv2d" + "/cell-weight-" + str(cell_idx) + ".mem"), 'w')
        
        # Get weights for the current cell idx
        for ker_px in col:
            byte_arr = bytearray(struct.pack("i", ker_px))
            byte_lst = ["%02x" % b for b in byte_arr]
            byte_lst.reverse()
            raw_int8_val = "".join(byte_lst)
            cell_file.write(raw_int8_val[6:8] + "\n")

        # Close the cell's weight file; move to next cell
        cell_file.close()
        cell_idx += 1

# Convert dense layer values
cell_idx = 0
cell_file = open(Path("build/raw-mnist-weights-int8/fc" + "/cell-weight-" + str(cell_idx) + ".mem"), 'w')
for fc_out in interpreter.tensor(tensor_details[6]["index"])():
    for fc_in in fc_out:
        byte_arr = bytearray(struct.pack("i", fc_in))
        byte_lst = ["%02x" % b for b in byte_arr]
        byte_lst.reverse()
        raw_int8_val = "".join(byte_lst)
        cell_file.write(raw_int8_val[6:8] + "\n")

cell_file.close()

print("[Info]: Done.")


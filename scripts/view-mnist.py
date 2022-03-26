import gzip
import numpy as np
import matplotlib.pyplot as plt

# Open the gziped training images
file = gzip.open('../datasets/train-images-idx3-ubyte.gz','r')

# First 2 bytes are 0 so ignore those
file.read(16)

# Images are 28 x 28 pixels
image_size = 28

# Number of images to load
num_images = 5

# Load raw data to numpy
buf = file.read(image_size * image_size * num_images)
data = np.frombuffer(buf, dtype=np.uint8).astype(np.float32)
data = data.reshape(num_images, image_size, image_size, 1)
image = np.asarray(data[0]).squeeze()

# Iterate through MNIST data
for image in data:
    image = np.asarray(image).squeeze()

    # Plot data visually using matplotlib
    plt.imshow(image)
    plt.show()

# Close file
file.close()


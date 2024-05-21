from PIL import Image

# Create image with 25% alpha
size = (256, 256)
image = Image.new("RGBA", size, (255, 255, 255, 128))
image.save("rgba_128.png", "png")

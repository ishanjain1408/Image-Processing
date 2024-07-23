import cv2 as cv
from matplotlib import pyplot as plt
from denoising_strategies.denoising_strategy import DenoisingStrategy
from denoising_strategies.gausian_strategy import GausianStrategy
import numpy as np
from utils.image import Image
from image_reading_strategies.image_reader import ImageReader
from image_reading_strategies.image_reading_from_path import ImageReadingFromPath

class ImageDenoiser:
    def __init__(self, noised_image: Image, strategy: DenoisingStrategy) -> None:
        self.noised_image = noised_image.array_image
        self.strategy = strategy

    def set_strategy(self, strategy: DenoisingStrategy) -> None:
        self.strategy = strategy

    def denoise_image(self) -> Image:
        return self.strategy.denoise_image(self.noised_image)

if __name__ == "__main__":
    
    #micro1.png
    image_reader: ImageReader = ImageReader(ImageReadingFromPath("./images/micro1.png"))
    noised_image: Image = image_reader.read_image()

    denoiser = ImageDenoiser(noised_image, GausianStrategy())

    cv.imshow("noised image",denoiser.noised_image)
    cv.waitKey(0)
    cv.imshow("denoised image",denoiser.denoise_image())
    cv.waitKey(0)
    
    plt.figure(figsize=(10, 5))

    plt.subplot(1, 2, 1)
    plt.imshow(cv.cvtColor(denoiser.noised_image, cv.COLOR_BGR2RGB))
    plt.title('Original Image')

    plt.subplot(1, 2, 2)
    plt.imshow(cv.cvtColor(denoiser.denoise_image(), cv.COLOR_BGR2RGB))
    plt.title('Image after removing the noise')

    plt.show()
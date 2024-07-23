import cv2 as cv
import numpy as np
from .denoising_strategy import DenoisingStrategy
from utils.image import Image

class GausianStrategy(DenoisingStrategy):
    def denoise_image(self, image: Image) -> Image:
        noised_image: np.ndarray = image.array_image
        noiseless_image:np.ndarray = cv.fastNlMeansDenoisingColored(noised_image, None, 20, 20, 7, 21)
        return Image(noiseless_image)
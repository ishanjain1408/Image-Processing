# CLAHE -> Contrast Limited Adaptive Histogram Equalization
# a pre-processing technique that improves image contrast by redistributing intensity levels in local regions.

import cv2 as cv
import numpy as np
from matplotlib import pyplot as plt
from typing import Tuple

class ContrastDenoiser:
    def __init__(self,noised_image: str)->None:
        self.noised_image = cv.imread(noised_image)

    def denoise_image_equalize(self)-> np.ndarray:
        noised_image = cv.cvtColor(self.noised_image, cv.COLOR_BGR2GRAY)
        equalized_img = cv.equalizeHist(noised_image)
        return equalized_img

    def denoise_image_CLAHE(self,clipLimit:float = 2.0, tileGridSize: Tuple[int,int] = (8,8))-> np.ndarray:
        noised_image = cv.cvtColor(self.noised_image, cv.COLOR_BGR2GRAY)
        clahe = cv.createCLAHE(clipLimit, tileGridSize)
        clean_img = clahe.apply(noised_image)
        # temp, thresh = cv.threshold(cl_img, 190, 255, cv.THRESH_BINARY)
        return clean_img


if __name__ == "__main__":
    #micro1.png
    denoiser = ContrastDenoiser('./images/micro1.png')
    denoised_image = denoiser.denoise_image_CLAHE()

    cv.imshow("noised image",denoiser.noised_image) 
    cv.waitKey(0)
    cv.imshow("denoised image",denoised_image)
    cv.waitKey(0)
    
    plt.figure(figsize=(10, 5))

    plt.subplot(1, 2, 1)
    plt.imshow(cv.cvtColor(denoiser.noised_image, cv.COLOR_BGR2RGB))
    plt.title('Original Image')

    plt.subplot(1, 2, 2)
    plt.imshow(cv.cvtColor(denoised_image, cv.COLOR_BGR2RGB))
    plt.title('Image after removing the noise')

    plt.show()
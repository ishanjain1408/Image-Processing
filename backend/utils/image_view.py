import cv2 as cv
from matplotlib import pyplot as plt
import numpy as np
from utils.image import Image

class ImageView:
    def __init__(self, matched_image: Image, matched_result: Image)-> None:
        self.matched_image = matched_image.array_image
        self.matched_result = matched_result.array_image

    def display(self)-> None:
        plt.imshow(self.matched_result,cmap="gray")
        plt.show()
        cv.imshow("Matched Image", self.matched_image)
        cv.waitKey()
        cv.destroyAllWindows()
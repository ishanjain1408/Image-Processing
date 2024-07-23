import cv2 as cv
from utils.image import Image
from image_reading_strategies.image_reading_strategy import ImageReadingStrategy

class ImageReadingFromPath(ImageReadingStrategy):
    def __init__(self, image_path: str) -> None:
        self.image_path = image_path

    def read_image(self) -> Image:
        image = cv.imread(self.image_path)
        if image is None:
            raise FileNotFoundError("Image not found.")
        return Image(image)

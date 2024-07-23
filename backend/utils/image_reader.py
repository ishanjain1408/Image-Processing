import cv2 as cv
from utils.image import Image

class ImageReader:
    def __init__(self) -> None:
        self.image_path = None

    def set_image_path(self, image_path: str) -> None:
        self.image_path = image_path

    def read_image(self) -> Image:
        if self.image_path is None:
            raise ValueError("Image path not set.")
        image = cv.imread(self.image_path)
        if image is None:
            raise FileNotFoundError(f"Image at path '{self.image_path}' not found.")
        return Image(image)
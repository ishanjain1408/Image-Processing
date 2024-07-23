from utils.image import Image
from image_reading_strategies.image_reading_strategy import ImageReadingStrategy

class ImageReader:
    def __init__(self, strategy: ImageReadingStrategy) -> None:
        self.strategy = strategy

    def read_image(self) -> Image:
        return self.strategy.read_image()
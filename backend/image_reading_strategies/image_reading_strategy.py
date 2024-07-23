from abc import ABC, abstractmethod
import numpy as np
from utils.image import Image
from utils.image_payload import ImagePayload

class ImageReadingStrategy(ABC):
    @abstractmethod
    def read_image(self, image) -> Image:
        pass
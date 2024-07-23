from abc import ABC, abstractmethod
import numpy as np
from utils.image import Image
import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'utils'))
from image import Image

class DenoisingStrategy(ABC):
    @abstractmethod
    def denoise_image(self, image: Image) -> Image:
        pass

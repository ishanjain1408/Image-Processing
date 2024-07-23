import numpy as np
from utils.image import Image

class ImagePayload:
    def __init__(self, source_image: Image, template_image: Image):
        self.source_image: np.ndarray = source_image.get_data()
        self.template_image: np.ndarray = template_image.get_data()

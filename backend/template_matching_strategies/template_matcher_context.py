from typing import List, Tuple
import cv2
import numpy as np
from utils.image import Image
from utils.image_payload import ImagePayload
from template_matching_strategies.template_matching_strategy import TemplateMatchingStrategy

class TemplateMatcherContext:
    def __init__(self, image_payload: ImagePayload, strategy: TemplateMatchingStrategy):
        self.image_payload = image_payload
        self.strategy = strategy
        self.template_width = 0
        self.template_height = 0

    def _set_template_dimensions(self, template_image: Image):
        template_data = template_image.get_data() 
        self.template_height, self.template_width = template_data.shape[:2]

    def find_template_matches(self, threshold: float = 0.7) -> Tuple[Image, List[Tuple[int, int]]]:
        matched_image, coordinates = self.strategy.find_matches(self.image_payload, threshold)
        self._set_template_dimensions(Image(self.image_payload.template_image))
        
        output_image = self.image_payload.source_image.copy()
        for pt in coordinates:
            cv2.rectangle(output_image, pt, (pt[0] + self.template_width, pt[1] + self.template_height), (0, 255, 0), 2)
        
        return Image(output_image), coordinates

    def highlight_matches(self, coordinates: List[Tuple[int, int]]) -> Image:
        source_data = self.image_payload.source_image
        output_image = source_data.copy()
        
        for pt in coordinates:
            cv2.rectangle(output_image, pt, (pt[0] + self.template_width, pt[1] + self.template_height), (0, 255, 0), 2)
        
        highlighted_image = Image(output_image)
        return highlighted_image

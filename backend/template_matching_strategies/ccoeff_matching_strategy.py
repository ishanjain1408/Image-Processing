import cv2 as cv
import numpy as np
from typing import Tuple, List
from utils.image import Image
from utils.image_payload import ImagePayload
from template_matching_strategies.template_matching_strategy import TemplateMatchingStrategy

class CoeffMatchingStrategy(TemplateMatchingStrategy):
    def find_matches(self, image_payload: ImagePayload, threshold: float = 0.7) -> Tuple[Image, List[Tuple[int, int]]]:
        matched_result = cv.matchTemplate(image_payload.source_image, image_payload.template_image, cv.TM_CCOEFF)
        matched_locations = np.where(matched_result >= threshold)
        matched_coordinates = [point for point in zip(*matched_locations[::-1])]
        return Image(matched_result), matched_coordinates

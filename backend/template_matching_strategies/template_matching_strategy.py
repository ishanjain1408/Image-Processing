from abc import ABC, abstractmethod
from typing import List, Tuple
from utils.image import Image
from utils.image_payload import ImagePayload

class TemplateMatchingStrategy(ABC):
    @abstractmethod
    def find_matches(self, image_payload: ImagePayload, threshold: float = 0.7) -> Tuple[Image, List[Tuple[int, int]]]:
        pass

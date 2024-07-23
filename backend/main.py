from utils.image_view import ImageView
from utils.image_reader import ImageReader
from utils.image import Image
from utils.image_payload import ImagePayload
from typing import List, Tuple
from template_matching_strategies.template_matcher_context import TemplateMatcherContext
from image_reading_strategies.image_reader import ImageReader
from image_reading_strategies.image_reading_from_path import ImageReadingFromPath

if __name__ == "__main__":
    source_image_path = './images/bubbles.png'
    template_image_path = './images/bubble.png'

    source_image_reader: ImageReader = ImageReader(ImageReadingFromPath(source_image_path))
    source_image: Image = source_image_reader.read_image()

    template_image_reader: ImageReader = ImageReader(ImageReadingFromPath(template_image_path))
    template_image: Image = template_image_reader.read_image()

    image_payload: ImagePayload = ImagePayload(source_image, template_image)
    
    templateMatcher: TemplateMatcherContext = TemplateMatcherContext(image_payload)
    matched_result: Image
    matched_coordinates: List[Tuple[int, int]]
    matched_result, matched_coordinates = templateMatcher.find_template_matches()
    processed_image: Image = templateMatcher.highlight_matches(matched_coordinates)
    print(matched_coordinates)

    imageView: ImageView = ImageView(processed_image, matched_result)
    imageView.display() 
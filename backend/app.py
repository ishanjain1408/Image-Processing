from flask import Flask, request, jsonify
from flask_cors import CORS
from utils.image_view import ImageView 
from utils.image_reader import ImageReader
from utils.image import Image
from utils.image_payload import ImagePayload
from typing import List, Tuple
from template_matching_strategies.template_matcher_context import TemplateMatcherContext
from template_matching_strategies.template_matching_strategy import TemplateMatchingStrategy
from template_matching_strategies.ccoeff_matching_strategy import CoeffMatchingStrategy
from template_matching_strategies.ccoeff_normed_matching_strategy import CoeffNormalizedMatchingStrategy
from template_matching_strategies.square_differnece_matching_strategy import SquareDifferenceMatchingStrategy
from image_reading_strategies.image_reader import ImageReader
from image_reading_strategies.image_reading_from_path import ImageReadingFromPath
import base64
import cv2
import numpy as np
import os
import uuid

app = Flask(__name__)
CORS(app)

algorithm_strategy_mapping = {
    'CoeffMatching': CoeffMatchingStrategy,
    'CoeffNormalizedMatching': CoeffNormalizedMatchingStrategy,
    'SquareDifferenceMatching': SquareDifferenceMatchingStrategy,
    'TemplateMatching': TemplateMatchingStrategy  
}

@app.route('/match-template', methods=['POST'])
def match_template():
    source_image_file = request.files['source_image']
    template_image_file = request.files['template_image']
    algorithm_type = request.form.get('algorithm_type', 'CoeffNormalizedMatching') 

    if algorithm_type not in algorithm_strategy_mapping:
        return jsonify({'error': 'Invalid algorithm type'}), 400

    source_image_path = './images/source_image.jpg'
    template_image_path = './images/template_image.jpg'
    source_image_file.save(source_image_path)
    template_image_file.save(template_image_path)

    source_image_reader: ImageReader = ImageReader(ImageReadingFromPath(source_image_path))
    source_image: Image = source_image_reader.read_image()

    template_image_reader: ImageReader = ImageReader(ImageReadingFromPath(template_image_path))
    template_image: Image = template_image_reader.read_image()

    image_payload: ImagePayload = ImagePayload(source_image, template_image)

    strategy_class = algorithm_strategy_mapping[algorithm_type]
    strategy = strategy_class()
    templateMatcher: TemplateMatcherContext = TemplateMatcherContext(image_payload, strategy)
    matched_result: Image
    matched_coordinates: List[Tuple[int, int]]
    matched_result, matched_coordinates = templateMatcher.find_template_matches()
    processed_image: Image = templateMatcher.highlight_matches(matched_coordinates)

    if not os.path.exists('./matched_images'):
        os.makedirs('./matched_images')

    matched_image_filename = f"matched_image_{uuid.uuid4().hex}.jpg"
    matched_image_path = os.path.join('./matched_images', matched_image_filename)
    
    cv2.imwrite(matched_image_path, processed_image.get_data())

    _, buffer = cv2.imencode('.jpg', processed_image.get_data())
    processed_image_base64 = base64.b64encode(buffer).decode('utf-8')

    serializable_coordinates = [(int(x), int(y)) for x, y in matched_coordinates]

    response = {
        'coordinates': serializable_coordinates,
        'marked_image_base64': processed_image_base64,
        'matched_image_path': matched_image_path
    }

    return jsonify(response)

if __name__ == "__main__":
    app.run(debug=True, port=5000)

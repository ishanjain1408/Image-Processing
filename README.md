# IMAGE PROCESSING
Image Processing Application
This project involves developing an image processing application using Flutter and Python. The application supports multiple image processing features such as cropping, template matching, and denoising images. The template matching functionality utilizes two primary algorithms: the coefficient normalized matching algorithm and the square difference matching algorithm.

Features
Image Uploading: Users can upload images directly from their device.
Server Storage: Uploaded images are stored on the server for processing.
Template Matching: Users can perform template matching to find specific patterns within an image using two different algorithms:
1. Coefficient Normalized Matching Algorithm: This algorithm normalizes the coefficient to ensure that the values lie between -1 and 1, making it scale-invariant and more robust to variations in illumination and contrast.
2. Square Difference Matching Algorithm: This algorithm calculates the sum of squared differences between the template and the image regions, providing a simple and fast method for template matching.
Precise Crop: The application allows users to crop images with high precision, ensuring that the required part of the image is accurately extracted.

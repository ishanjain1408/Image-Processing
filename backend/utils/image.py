import numpy as np

class Image:
    def __init__(self, data: np.ndarray):
        self._data = data

    def get_data(self) -> np.ndarray:
        return self._data

import tensorflow as tf
from tensorflow import keras
from tensorflow.lite import TFLiteConverter

# Carregar o modelo treinado
model: keras.Model = keras.models.load_model('libras_model.h5')

# Converter o modelo para TFLite
converter: TFLiteConverter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model: bytes = converter.convert()

# Salvar o modelo TFLite
with open('libras_model.tflite', 'wb') as f:
    f.write(tflite_model)

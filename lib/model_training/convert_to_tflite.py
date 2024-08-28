import tensorflow as tf
import keras

# Carregar o modelo treinado
model = keras.models.load_model('libras_model.h5')

# Converter o modelo para TFLite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# Salvar o modelo TFLite
with open('libras_model.tflite', 'wb') as f:
    f.write(tflite_model)
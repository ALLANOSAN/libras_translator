import tensorflow as tf
from tensorflow.keras import layers
import os

# Diretórios de treinamento e validação
train_dir = 'C:/Wondershare UniConverter 15/Downloaded'
validation_dir = 'C:/Wondershare UniConverter 15/Downloaded'

def preprocess_image(image, label):
    image = tf.image.decode_jpeg(image, channels=3)
    image = tf.image.resize(image, [224, 224])
    image /= 255.0  # Normalize para o intervalo [0,1]
    return image, label

# Função para carregar o dataset
def load_dataset(directory):
    dataset = tf.data.Dataset.list_files(directory + '/*/*')
    dataset = dataset.map(lambda x: (tf.io.read_file(x),
                                     tf.strings.split(x, os.sep)[-2]))
    dataset = dataset.map(preprocess_image)
    return dataset

# Carregar e preprocessar os datasets
train_dataset = load_dataset(train_dir)
validation_dataset = load_dataset(validation_dir)

# Codificar os rótulos
def encode_labels(image, label):
    label = tf.strings.to_number(label, out_type=tf.int32)
    label = tf.one_hot(label, depth=10)  # Supondo 10 classes
    return image, label

train_dataset = train_dataset.map(encode_labels)
validation_dataset = validation_dataset.map(encode_labels)

# Agrupar e embaralhar os datasets
train_dataset = train_dataset.shuffle(buffer_size=1000).batch(32)
validation_dataset = validation_dataset.batch(32)

# Definir o modelo
model = tf.keras.Sequential([
    layers.Input(shape=(224, 224, 3)),
    layers.Conv2D(32, (3, 3), activation='relu'),
    layers.MaxPooling2D((2, 2)),
    layers.Conv2D(128, (3, 3), activation='relu'),
    layers.MaxPooling2D((2, 2)),
    layers.Flatten(),
    layers.Dense(128, activation='relu'),
    layers.Dense(10, activation='softmax')  # Ajuste o número de classes conforme necessário
])

model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])

# Treine o modelo
history = model.fit(
    train_dataset,
    epochs=10,
    validation_data=validation_dataset
)

# Salve o modelo
model.save('libras_model.h5')
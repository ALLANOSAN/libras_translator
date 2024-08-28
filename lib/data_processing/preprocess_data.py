"""
Este módulo contém funções para pré-processar dados de vídeo,
extraindo frames e salvando-os em um diretório especificado.
"""
import os

import cv2


def preprocess_data(video_path, output_dir, frame_size=(224, 224)):
    """
    Processa um vídeo, extraindo frames e salvando-os em um diretório
    especificado.

    Args:
        video_path (str): O caminho para o arquivo de vídeo.
        output_dir (str): O diretório onde os frames serão salvos.
        frame_size (tuple): O tamanho dos frames redimensionados (largura,
        altura).
    """
    cap = cv2.VideoCapture(video_path)
    frame_count = 0

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break

        cv2.imshow('frame', frame)
        # Adiciona um pequeno delay para a exibição do frame
        cv2.waitKey(1)

        resized_frame = cv2.resize(
            frame, frame_size)
        frame_file = os.path.join(output_dir, f'frame_{frame_count:04d}.png')
        cv2.imwrite(frame_file, resized_frame)
        frame_count += 1

    cap.release()
    # Fecha todas as janelas abertas pelo OpenCV, # pylint: disable=no-member
    cv2.destroyAllWindows()


def main():
    """
    Função principal que define o caminho do vídeo e o diretório de saída,
    e chama a função de pré-processamento.
    """
    # Defina o caminho para o seu vídeo e o diretório de saída
    video_path = 'path_to_your_video.mp4'
    output_dir = 'output_frames'
    os.makedirs(output_dir, exist_ok=True)
    preprocess_data(video_path, output_dir)


if __name__ == "__main__":
    main()

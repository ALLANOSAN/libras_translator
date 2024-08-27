import os
import cv2


def preprocess_data(video_path, output_dir, frame_size=(224, 224)):
    cap = cv2.VideoCapture(video_path)
    frame_count = 0

    while cap.isOpened():
        ret, frame = cap.read()
        cv2.imshow('frame', frame)
        if not ret:
            break

        resized_frame = cv2.resize(frame, frame_size)
        frame_file = os.path.join(output_dir, f'frame_{frame_count:04d}.png')
        cv2.imwrite(frame_file, resized_frame)
        frame_count += 1

    cap.release()

# Defina o caminho para o seu vídeo e o diretório de saída
video_path = 'path_to_your_video.mp4'
output_dir = 'output_frames'
os.makedirs(output_dir, exist_ok=True)
preprocess_data(video_path, output_dir)
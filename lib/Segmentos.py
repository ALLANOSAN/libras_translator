from scenedetect import VideoManager, SceneManager
from scenedetect.detectors import ContentDetector
import os
import subprocess

# Configuração do vídeo e diretórios
video_path = "dataset/video/Alfabeto_de_LIBRAS-COMPLETO_E_INESQUECIVEL.mp4"
output_dir = "segments/"
os.makedirs(output_dir, exist_ok=True)

# Gerenciadores de vídeo e cenas
video_manager = VideoManager([video_path])
scene_manager = SceneManager()
scene_manager.add_detector(ContentDetector(threshold=30))  # Ajuste o threshold se necessário

# Processar o vídeo
video_manager.set_downscale_factor()  # Reduz resolução para processar mais rápido
video_manager.start()
scene_manager.detect_scenes(video_manager)

# Obter intervalos de cena
scene_list = scene_manager.get_scene_list()
print(f"Total de cenas detectadas: {len(scene_list)}")

# Salvar segmentos usando ffmpeg
for i, (start, end) in enumerate(scene_list):
    start_time = start.get_seconds()
    end_time = end.get_seconds()
    segment_path = os.path.join(output_dir, f"scene_{i + 1}.mp4")

    # Usar ffmpeg para cortar o segmento
    ffmpeg_command = [
        "C:/ffmpeg/bin/ffmpeg.exe",
        "-i", video_path,
        "-ss", str(start_time),
        "-to", str(end_time),
        "-c", "copy",
        segment_path
    ]

    subprocess.run(ffmpeg_command)
    print(f"Cena {i + 1} salva em: {segment_path}")

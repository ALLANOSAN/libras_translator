import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:logging/logging.dart';

void main() => runApp(TradutordeLibras());

final Logger _logger = Logger('MyAppLogger');

void setupLogging() {
  Logger.root.level = Level.ALL; // Configura o nível de logging
  Logger.root.onRecord.listen((record) {
    _logger.log(record.level, '${record.time}: ${record.message}');
  });
}

class TradutordeLibras extends StatelessWidget {
  const TradutordeLibras({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  List<CameraDescription>? cameras;
  XFile? videoFile;
  VideoPlayerController? videoPlayerController;

  static const platform = MethodChannel('com.example.libras/opencv');

  @override
  void initState() {
    super.initState();
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      if (cameras!.isNotEmpty) {
        controller = CameraController(cameras![0], ResolutionPreset.high);
        controller?.initialize().then((_) {
          if (!mounted) return;
          setState(() {});
        });
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> startRecording() async {
    if (controller!.value.isRecordingVideo) return;
    try {
      await controller!.startVideoRecording();
    } catch (e) {
      _logger.severe('Error starting video recording: $e');
    }
  }

  Future<void> stopRecording() async {
    if (!controller!.value.isRecordingVideo) return;
    try {
      videoFile = await controller!.stopVideoRecording();
      // Processar vídeo com OpenCV
      if (videoFile != null) {
        final byteData = await videoFile!.readAsBytes();
        await platform.invokeMethod('processFrame', {'frame': byteData});
        // Display or use the processed data
      }
      setState(() {});
    } catch (e) {
      _logger.severe('Error starting video recording: $e');
    }
  }

  Future<void> playVideo() async {
    if (videoFile == null) return;
    videoPlayerController = VideoPlayerController.file(File(videoFile!.path));
    await videoPlayerController!.initialize();
    await videoPlayerController!.play();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(title: Text('Tradutor de Libras')),
      body: Column(
        children: [
          Expanded(child: CameraPreview(controller!)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: startRecording,
                child: Text('Iniciar Gravação'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: stopRecording,
                child: Text('Parar Gravação'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: playVideo,
                child: Text('Reproduzir Vídeo'),
              ),
            ],
          ),
          if (videoPlayerController != null && videoPlayerController!.value.isInitialized)
            AspectRatio(
              aspectRatio: videoPlayerController!.value.aspectRatio,
              child: VideoPlayer(videoPlayerController!),
            ),
        ],
      ),
    );
  }
}

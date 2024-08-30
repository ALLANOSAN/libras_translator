import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image/image.dart' as img;
import 'dart:math' as math;
import 'dart:typed_data'; // Importando o pacote dart:typed_data

void main() => runApp(const LibrasTranslatorApp());

class LibrasTranslatorApp extends StatelessWidget {
  const LibrasTranslatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LIBRAS Translator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  CameraController? controller;
  List<CameraDescription>? cameras;
  String? videoPath;
  String? recognizedText;
  FlutterTts flutterTts = FlutterTts();
  Interpreter? interpreter;
  List<String>? labels;

  @override
  void initState() {
    super.initState();
    initializeCamera();
    loadModel();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras![0], ResolutionPreset.high);
    await controller!.initialize();
    setState(() {});
  }

  Future<void> loadModel() async {
    interpreter = await Interpreter.fromAsset('libras_model.tflite');
    labels = await loadLabels('assets/labels.txt');
  }

  Future<List<String>> loadLabels(String path) async {
    final file = File(path);
    final lines = await file.readAsLines();
    return lines;
  }

  Future<void> startRecording() async {
    final directory = await getApplicationDocumentsDirectory();
    videoPath = '${directory.path}/video.mp4';
    await controller!.startVideoRecording();
  }

  Future<void> stopRecording() async {
    await controller!.stopVideoRecording();
    setState(() {});
    await processVideo();
  }

  Future<void> processVideo() async {
    recognizedText = await recognizeSignLanguage(videoPath!);
    setState(() {});
    await speakText(recognizedText!);
  }

  Future<String> recognizeSignLanguage(String videoPath) async {
    // Abrir o vídeo e extrair frames
    final videoFile = File(videoPath);
    final videoBytes = await videoFile.readAsBytes();
    final videoImage = img.decodeImage(videoBytes);

    if (videoImage == null) {
      return "Erro ao processar o vídeo";
    }

    List<String> predictions = [];

    // Processar frames em intervalos regulares
    for (int i = 0; i < videoImage.height; i += 30) {
      final frame = img.copyCrop(videoImage, 0, i, videoImage.width, 30);

      // Pré-processar o frame
      final resizedFrame = img.copyResize(frame, width: 224, height: 224);
      final input = imgToByteListFloat32(resizedFrame, 224);

      // Fazer a predição
      var output = List.filled(labels!.length, 0.0).reshape([1, labels!.length]);
      interpreter!.run(input, output);

      // Encontrar o índice com maior valor
      int maxIndex = output[0].indexWhere((element) => element == output[0].reduce(math.max));
      predictions.add(labels![maxIndex]);
    }

    // Converter as predições em texto
    return predictions.join('');
  }

  Uint8List imgToByteListFloat32(img.Image image, int inputSize) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (img.getRed(pixel) - 127.5) / 127.5;
        buffer[pixelIndex++] = (img.getGreen(pixel) - 127.5) / 127.5;
        buffer[pixelIndex++] = (img.getBlue(pixel) - 127.5) / 127.5;
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  Future<void> speakText(String text) async {
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LIBRAS Translator'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (controller != null && controller!.value.isInitialized)
            AspectRatio(
              aspectRatio: controller!.value.aspectRatio,
              child: CameraPreview(controller!),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: startRecording,
            child: const Text('Start Recording'),
          ),
          ElevatedButton(
            onPressed: stopRecording,
            child: const Text('Stop Recording'),
          ),
          if (recognizedText != null)
            Text(
              recognizedText!,
              style: const TextStyle(fontSize: 20),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    interpreter?.close();
    super.dispose();
  }
}
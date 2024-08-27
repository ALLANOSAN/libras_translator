import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_tts/flutter_tts.dart';
import 'tflite_model.dart';
import 'package:libras_translator/main.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  List<CameraDescription>? cameras;
  bool isCameraInitialized = false;
  TFLiteModel? model;
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    initializeCamera();
    initializeModel();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras![0], ResolutionPreset.high);

    await controller?.initialize();
    setState(() {
      isCameraInitialized = true;
    });
  }

  Future<void> initializeModel() async {
    model = TFLiteModel();
    await model?.loadModel();
  }

  @override
  void dispose() {
    controller?.dispose();
    model?.close();
    super.dispose();
  }

  Future<void> captureAndPredict() async {
    if (controller != null && controller!.value.isInitialized) {
      XFile file = await controller!.takePicture();
      File imageFile = File(file.path);
      img.Image? image = img.decodeImage(await imageFile.readAsBytes());

      if (image != null) {
        // Redimensionar a imagem para o tamanho esperado pelo modelo
        img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

        // Converter a imagem em uma lista de entradas para o modelo
        List<List<List<int>>> input = imageToInput(resizedImage);

        List<dynamic> output = model!.predict(input);
        logger.info('Resultado da Previsão: $output');

        // Traduzir o resultado para áudio
        if (output.isNotEmpty) {
          await _speak(output.first);
        }
      }
    }
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("pt-BR");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  List<List<List<int>>> imageToInput(img.Image image) {
    List<List<List<int>>> input = List.generate(224, (i) => List.generate(224, (j) => List.filled(3, 0)));
    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        // Obter os componentes RGB do pixel corretamente
        img.Pixel pixel = image.getPixel(x, y);
        input[y][x][0] = pixel.r.toInt();
        input[y][x][1] = pixel.g.toInt();
        input[y][x][2] = pixel.b.toInt();
      }
    }
    return input;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capturar Vídeo'),
      ),
      body: isCameraInitialized
          ? CameraPreview(controller!)
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await captureAndPredict();
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}
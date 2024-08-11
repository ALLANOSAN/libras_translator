import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteModel {
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('model.tflite');
  }

  List<dynamic> predict(List<dynamic> input) {
    var output = List.filled(1 * 1, 0).reshape([1, 1]);
    _interpreter?.run(input, output);
    return output;
  }

  void close() {
    _interpreter?.close();
  }
}

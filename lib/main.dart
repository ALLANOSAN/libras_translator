import 'package:flutter/material.dart';
import 'camera_screen.dart';
import 'package:logging/logging.dart';

final logger = Logger('CameraScreenLogger');

void main() {
  // Configura o nível de log e define um listener para os logs.
  Logger.root.level = Level.ALL; // Define o nível de log desejado
  Logger.root.onRecord.listen((record) {
    // Aqui você pode personalizar a saída do log.
    logger.info('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(const LibrasTranslatorApp());
}

class LibrasTranslatorApp extends StatelessWidget {
  const LibrasTranslatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Libras Translator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Libras Translator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CameraScreen()),
                );
              },
              child: const Text('Capturar Vídeo'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Adicione a funcionalidade de comunicação reversa aqui
              },
              child: const Text('Comunicação Reversa'),
            ),
          ],
        ),
      ),
    );
  }
}
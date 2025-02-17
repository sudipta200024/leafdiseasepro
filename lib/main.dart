import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:image/image.dart' as img;

void main() {
  runApp(RiceDiseaseApp());
}

class RiceDiseaseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RiceDiseaseDetector(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RiceDiseaseDetector extends StatefulWidget {
  @override
  _RiceDiseaseDetectorState createState() => _RiceDiseaseDetectorState();
}

class _RiceDiseaseDetectorState extends State<RiceDiseaseDetector> {
  File? _image;
  String _prediction = "No prediction yet";
  late tfl.Interpreter _interpreter;
  List<String> labels = [
    "Rice_Bacterial_blight",
    "Rice_Blast",
    "Rice_Brown_spot",
    "Rice_Healthy",
    "Rice_Tungro"
  ];

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await tfl.Interpreter.fromAsset('assets/tensorFlow/rice_leaf_model.tflite');
      print("✅ Model Loaded Successfully!");

      // Debugging: Print model input/output details
      print("🔍 Model Input Details: ${_interpreter.getInputTensors()}");
      print("🔍 Model Output Details: ${_interpreter.getOutputTensors()}");

    } catch (e) {
      print("❌ Error Loading Model: $e");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _predict(_image!);
    }
  }

  Future<void> _predict(File file) async {
    if (_image == null) return;

    try {
      // Decode and resize image
      img.Image imageInput = img.decodeImage(File(_image!.path).readAsBytesSync())!;
      img.Image resizedImage = img.copyResize(imageInput, width: 224, height: 224);

      // Convert image to appropriate format (check if model expects uint8 or float32)
      var input = List.generate(1, (_) =>
          List.generate(224, (y) =>
              List.generate(224, (x) {
                var pixel = resizedImage.getPixel(x, y);
                return [pixel.r.toDouble(), pixel.g.toDouble(), pixel.b.toDouble()];
              })
          )
      );

      // Debugging: Print first pixel values to ensure correct scaling
      print("🔍 First pixel values: ${input[0][0][0]}");

      // Prepare output list
      var output = List.generate(1, (i) => List<double>.filled(labels.length, 0));

      // Run inference
      _interpreter.run(input, output);

      // Debugging: Print raw model output
      print("📊 Raw Model Output: $output");

      // Get highest confidence prediction
      int index = output[0].indexOf(output[0].reduce((a, b) => a > b ? a : b));
      double confidence = output[0][index];

      print("🎯 Predicted Index: $index, Confidence: $confidence");

      setState(() {
        _prediction = "${labels[index]} (Confidence: ${(confidence * 100).toStringAsFixed(2)}%)";
      });
    } catch (e) {
      print("❌ Error during prediction: $e");
      setState(() {
        _prediction = "Error in prediction!";
      });
    }
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rice Leaf Disease Detector")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null ? Text("No image selected.") : Image.file(_image!),
            SizedBox(height: 20),
            Text("Prediction: $_prediction", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.camera_alt),
                  label: Text("Capture"),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: Icon(Icons.image),
                  label: Text("Gallery"),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

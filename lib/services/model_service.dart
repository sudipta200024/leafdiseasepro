import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:image/image.dart' as img;

class ModelService {
  late tfl.Interpreter _interpreter;
  List<String> labels = [
    "Rice_Bacterial_blight",
    "Rice_Blast",
    "Rice_Brown_spot",
    "Rice_Healthy",
    "Rice_Tungro"
  ];

  Future<void> loadModel() async {
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

  Future<String> predict(File image) async {
    try {
      // Decode and resize image
      img.Image imageInput = img.decodeImage(image.readAsBytesSync())!;
      img.Image resizedImage = img.copyResize(imageInput, width: 224, height: 224);

      // Convert image to appropriate format
      var input = List.generate(1, (_) =>
          List.generate(224, (y) =>
              List.generate(224, (x) {
                var pixel = resizedImage.getPixel(x, y);
                return [
                  pixel.r.toDouble(),
                  pixel.g.toDouble(),
                  pixel.b.toDouble()
                ];
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

      return "${labels[index]} (Confidence: ${(confidence * 100).toStringAsFixed(2)}%)";
    } catch (e) {
      print("❌ Error during prediction: $e");
      return "Error in prediction!";
    }
  }

  void dispose() {
    _interpreter.close();
  }
}

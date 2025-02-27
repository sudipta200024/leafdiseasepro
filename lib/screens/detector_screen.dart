import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_picker_services.dart';
import '../services/model_service.dart';

class RiceDiseaseDetector extends StatefulWidget {
  @override
  _RiceDiseaseDetectorState createState() => _RiceDiseaseDetectorState();
}

class _RiceDiseaseDetectorState extends State<RiceDiseaseDetector> {
  File? _image;
  String _prediction = "No prediction yet";
  final ModelService _modelService = ModelService();

  @override
  void initState() {
    super.initState();
    _modelService.loadModel();
  }

  Future<void> _pickImage(ImageSource source) async {
    File? pickedImage = await ImagePickerService.pickImage(source);

    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
      String prediction = await _modelService.predict(_image!);
      setState(() {
        _prediction = prediction;
      });
    }
  }

  @override
  void dispose() {
    _modelService.dispose();
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
            Text(
              "Prediction: $_prediction",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
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

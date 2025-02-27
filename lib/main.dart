import 'package:flutter/material.dart';
import 'package:leaf7/screens/detector_screen.dart';

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


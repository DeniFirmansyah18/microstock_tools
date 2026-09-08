import 'dart:typed_data';
import 'package:flutter/material.dart';

class ReviewLabScreen extends StatelessWidget {
  final Uint8List imageBytes;
  final String prompt;

  const ReviewLabScreen({
    super.key,
    required this.imageBytes,
    required this.prompt,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Lab')),
      body: Center(child: Text(prompt)),
    );
  }
}

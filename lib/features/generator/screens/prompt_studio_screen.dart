import 'package:flutter/material.dart';
import '../../trends/models/trend_item.dart';

class PromptStudioScreen extends StatelessWidget {
  final TrendItem? initialTrend;

  const PromptStudioScreen({super.key, this.initialTrend});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prompt Studio')),
      body: Center(child: Text(initialTrend?.title ?? 'Prompt Studio')),
    );
  }
}

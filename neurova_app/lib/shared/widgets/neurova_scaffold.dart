import 'package:flutter/material.dart';

class NeurovaScaffold extends StatelessWidget {
  const NeurovaScaffold({
    super.key,
    required this.title,
    required this.body,
    this.action,
  });

  final String title;
  final Widget body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: body,
      ),
      floatingActionButton: action,
    );
  }
}

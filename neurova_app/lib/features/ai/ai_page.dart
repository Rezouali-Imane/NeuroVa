import 'package:flutter/material.dart';

import '../../shared/widgets/neurova_scaffold.dart';

class AIPage extends StatelessWidget {
  const AIPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NeurovaScaffold(
      title: 'AI Assistant',
      body: Text(
        'Ask Neurova AI to summarize notes or generate your study plan.',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../shared/widgets/neurova_scaffold.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NeurovaScaffold(
      title: 'Notes',
      body: Text(
        'Capture quick ideas, summaries, and study notes here.',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

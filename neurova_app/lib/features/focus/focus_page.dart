import 'package:flutter/material.dart';

import '../../shared/widgets/neurova_scaffold.dart';

class FocusPage extends StatelessWidget {
  const FocusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NeurovaScaffold(
      title: 'Focus Session',
      body: Text(
        'Start a distraction-free timer session and track your streak.',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/neurova_scaffold.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NeurovaScaffold(
      title: 'Tasks',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your daily priorities.', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            children: [
              ElevatedButton(
                onPressed: () => context.go('/notes'),
                child: const Text('Notes'),
              ),
              ElevatedButton(
                onPressed: () => context.go('/focus'),
                child: const Text('Focus'),
              ),
              ElevatedButton(
                onPressed: () => context.go('/ai'),
                child: const Text('AI'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

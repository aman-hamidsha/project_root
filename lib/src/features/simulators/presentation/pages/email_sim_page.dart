import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmailSimPage extends StatelessWidget {
  const EmailSimPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Email Simulator')),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Email Simulator (placeholder)'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

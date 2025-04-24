import 'package:flutter/material.dart';
import 'package:frontend/screens/home_screen.dart';

class ErrorScreen extends StatelessWidget {
  final String message;
  const ErrorScreen({super.key, this.message = 'An unexpected error occurred.'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center( child: Padding( padding: const EdgeInsets.all(16.0), child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 60), const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 24),
              ElevatedButton( onPressed: () {
                  if (Navigator.canPop(context)) { Navigator.pop(context); }
                  else { Navigator.pushReplacementNamed(context, HomeScreen.routeName); }
                }, child: const Text('Go Back'),)
            ],),),),
    );
  }
}
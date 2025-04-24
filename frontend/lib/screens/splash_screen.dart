import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SplashScreen extends StatelessWidget {
  static const routeName = splashRoute;
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.track_changes_rounded,
                size: 100, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: kDefaultPadding * 2),
            const CircularProgressIndicator(),
            const SizedBox(height: kDefaultPadding),
            Text('Loading...', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../widgets/connectivity_builder.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConnectivityBuilder(
        onRetry: () {},
        child: Center(child: Text('Splash Screen')),
      ),
    );
  }
}

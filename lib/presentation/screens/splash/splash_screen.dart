import 'package:flutter/material.dart';

import '../../utils/connectivity_aware_mixin.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with ConnectivityAwareMixin {
  @override
  void onConnectionRestored() {
    debugPrint('Connection restored');
  }

  @override
  Widget build(BuildContext context) {
    return buildWithConnectivity(child: const Scaffold());
  }
}

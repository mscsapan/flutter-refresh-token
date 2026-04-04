import 'package:flutter/material.dart';

import '../../widgets/custom_text.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(text: 'Welcome screen'),
        automaticallyImplyLeading: false,
      ),
    );
  }
}

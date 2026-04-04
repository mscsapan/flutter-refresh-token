import 'package:bloc_clean_architecture/dependency_injection_packages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/connectivity_builder.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SettingCubit settingCubit;

  @override
  void initState() {
    super.initState();

    settingCubit = context.read<SettingCubit>();
    Future.microtask(()=>settingCubit.getSetting());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}

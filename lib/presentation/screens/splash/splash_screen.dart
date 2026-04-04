import 'package:bloc_clean_architecture/dependency_injection_packages.dart';
import 'package:bloc_clean_architecture/presentation/cubit/setting/setting_state.dart';
import 'package:bloc_clean_architecture/presentation/routes/route_packages_name.dart';
import 'package:bloc_clean_architecture/presentation/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/navigation_service.dart';
import '../../routes/route_names.dart';
import '../../widgets/connectivity_builder.dart';
import '../../widgets/custom_text.dart';

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
    Future.microtask(() => settingCubit.getSetting());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SettingCubit, SettingState>(
        listener: (context, state) {
          if (state is SettingError) {
            NavigationService.errorSnackBar(context, state.message);
          } else if (state is SettingLoaded) {
            NavigationService.navigateTo(RouteNames.onBoardingScreen);
          }
        },
        child: Center(child: CustomText(text: 'Splash Screen')),
      ),
    );
  }
}

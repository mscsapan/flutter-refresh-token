import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/navigation_service.dart';
import '../../bloc/auth/login_bloc.dart';
import '../../cubit/setting/setting_cubit.dart';
import '../../cubit/setting/setting_state.dart';
import '../../routes/route_names.dart';
import '../../widgets/custom_text.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SettingCubit settingCubit;
  late LoginBloc loginBloc;

  @override
  void initState() {
    super.initState();

    settingCubit = context.read<SettingCubit>();
    loginBloc = context.read<LoginBloc>();
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
            if (settingCubit.showOnBoarding) {
              if (loginBloc.isLoggedIn) {
                NavigationService.navigateTo(RouteNames.homeScreen);
              } else {
                NavigationService.navigateTo(RouteNames.authScreen);
              }
            } else {
              NavigationService.navigateTo(RouteNames.onBoardingScreen);
            }
          }
        },

        child: Center(child: CustomText(text: 'Splash Screen')),
      ),
    );
  }
}

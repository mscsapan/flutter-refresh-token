import 'package:bloc_clean_architecture/dependency_injection_packages.dart';
import 'package:bloc_clean_architecture/presentation/cubit/home/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/custom_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    Future.microtask(() => context.read<HomeCubit>().getSetting());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint('accessToken ${context.read<LoginBloc>().userInformation?.accessToken}');
    // debugPrint('accessToken ${context.read<LoginBloc>().userInformation?.refreshToken}');
    return Scaffold(
      appBar: AppBar(
        title: CustomText(text: 'Home'),
        automaticallyImplyLeading: false,
      ),
    );
  }
}

import 'package:bloc_clean_architecture/presentation/cubit/home/home_cubit.dart';
import 'package:bloc_clean_architecture/presentation/routes/route_packages_name.dart';
import 'package:bloc_clean_architecture/presentation/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/home/home_model.dart';
import '../../widgets/custom_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeCubit homeCubit;

  @override
  void initState() {
    homeCubit = context.read<HomeCubit>();
    Future.microtask(() => homeCubit.getSetting());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(text: 'Home'),
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<HomeCubit, HomeState>(
        builder: (context, state) {
          debugPrint('called');
          if (state is HomeLoading) {
            return LoadingWidget();
          } else if (state is HomeError) {
            if (state.statusCode != 503 ||
                (homeCubit.homeModel?.isNotEmpty ?? false)) {
              return HomeLoadedView(homeModel: homeCubit.homeModel);
            }
          } else if (state is HomeLoaded) {
            return HomeLoadedView(homeModel: state.homeData);
          }
          if (homeCubit.homeModel?.isNotEmpty ?? false) {
            return HomeLoadedView(homeModel: homeCubit.homeModel);
          } else {
            return FetchErrorText(text: 'Something went wrong');
          }
        },
        listener: (context, state) {
          if (state is HomeError && state.statusCode == 503) {
            homeCubit.getSetting();
          }
        },
        buildWhen: (previous,current) => previous != current,
      ),
    );
  }
}

class HomeLoadedView extends StatelessWidget {
  const HomeLoadedView({super.key, required this.homeModel});

  final List<HomeModel?>? homeModel;

  @override
  Widget build(BuildContext context) {
    if (homeModel?.isEmpty ?? false) {
      return CustomText(text: 'No Data Found');
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: homeModel?.length,
      itemBuilder: (context, index) {
        final todo = homeModel?[index];
        return ListTile(
          key: ValueKey(todo?.id ?? 'row-$index'),
          title: CustomText(text: todo?.title ?? ''),
          subtitle: CustomText(text: todo?.description ?? ''),
        );
      },
    );
  }
}

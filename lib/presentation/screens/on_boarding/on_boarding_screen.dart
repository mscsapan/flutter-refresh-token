
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/navigation_service.dart';
import '../../../data/dummy_data/dummy_data.dart';
import '../../cubit/setting/setting_cubit.dart';
import '../../routes/route_names.dart';
import '../../utils/constraints.dart';
import '../../utils/utils.dart';
import '../../widgets/custom_image.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/primary_button.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {

  late SettingCubit setting;
  late int _numPages;
  late PageController _pageController;
  int _currentPage = 0;


  @override
  void initState() {
    super.initState();

    setting = context.read<SettingCubit>();

    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SizedBox(
        height: Utils.mediaQuery(context).height,
        width: Utils.mediaQuery(context).width,
        child: Column(
          children: [
            Utils.verticalSpace(Utils.mediaQuery(context).height * 0.04),
            Expanded(
              flex: 6,
              child:  PageView.builder(
                physics: const ClampingScrollPhysics(),
                controller: _pageController,
                itemCount: onBoardingData.length,
                itemBuilder: (context,index){
                  final data = onBoardingData[index];
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.9, end: 1.0).animate(anim),
                        child: child,
                      ),
                    ),
                    child: CustomImage(
                      key: ValueKey(index),
                      path: data.image,
                      fit: BoxFit.fill,
                      width: Utils.mediaQuery(context).width,
                    ),
                  );
                },
                onPageChanged: (int page) {
                  setState(() {_currentPage = page;
                  });
                },
              ),
            ),
            Utils.verticalSpace(Utils.mediaQuery(context).height * 0.04),
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: CustomText(
                      text:onBoardingData[_currentPage].title,
                      key: ValueKey("title-$_currentPage"),
                      textAlign: TextAlign.center,
                      fontSize: 22.0,
                      fontWeight: FontWeight.w700,
                      color: blackColor,
                    ),
                  ),
                  Utils.verticalSpace(12.0),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Padding(
                      key: ValueKey("sub-$_currentPage"),
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: CustomText(
                        text: onBoardingData[_currentPage].subTitle,
                        textAlign: TextAlign.center,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const Spacer(flex: 4),
                  _buildDotIndicator(),
                  Utils.verticalSpace(Utils.mediaQuery(context).height * 0.02),
                  Padding(
                    padding: Utils.symmetric(),
                    child: Row(
                      children: [
                        Expanded(flex: 8,child: PrimaryButton(text: 'Skip', onPressed: (){
                          setting.cacheOnBoarding();
                          NavigationService.navigateToAndClearStack(RouteNames.mainScreen);
                          // NavigationService.navigateToAndClearStack(RouteNames.authScreen);
                        },bgColor: borderColor,textColor: blackColor,minimumSize: Size(double.infinity,  36.0),)),
                        Spacer(),
                        Expanded(flex: 8,child: PrimaryButton(text: _currentPage==3?'Get Started':'Next', onPressed: (){
                          if (_currentPage == onBoardingData.length - 1) {
                            setting.cacheOnBoarding();
                            NavigationService.navigateToAndClearStack(RouteNames.mainScreen);
                            // NavigationService.navigateToAndClearStack(RouteNames.authScreen);
                          } else {
                            _pageController.nextPage(duration: kDuration, curve: Curves.easeInOut);
                          }

                        },minimumSize: Size(double.infinity,  36.0))),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        onBoardingData.length,
            (index) {
          final i = _currentPage == index;
          return AnimatedContainer(
            duration: const Duration(seconds: 1),
            height: Utils.vSize(6.0),
            width: Utils.hSize(i ? 24.0 : 6.0),
            margin: const EdgeInsets.only(right: 4.0),
            decoration: BoxDecoration(
              color: i ? primaryColor : primaryColor.withValues(alpha:0.3),
              borderRadius: BorderRadius.circular(i ? 50.0 : 5.0),
              //shape: i ? BoxShape.rectangle : BoxShape.circle,
            ),
          );
        },
      ),
    );
  }
}

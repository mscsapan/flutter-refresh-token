import 'package:flutter/material.dart';

import 'route_packages_name.dart';

class RouteNames {
  ///authentication routes
  static const String splashScreen = '/splashScreen';
  static const String onBoardingScreen = '/onBoardingScreen';
  static const String authScreen = '/authenticationScreen';
  static const String changePasswordScreen = '/changePasswordScreen';
  static const String forgotPasswordScreen = '/forgotPasswordScreen';
  static const String updatePasswordScreen = '/updatePasswordScreen';
  static const String verificationScreen = '/verificationScreen';
  static const String mainScreen = '/mainScreen';
  static const String homeScreen = '/homeScreen';

  ///setting routes
  static const String privacyPolicyScreen = '/privacyPolicyScreen';
  static const String termsConditionScreen = '/termsConditionScreen';
  static const String faqScreen = '/faqScreen';
  static const String contactUsScreen = '/contactUsScreen';
  static const String aboutUsScreen = '/aboutUsScreen';

  ///profile routes
  static const String profileScreen = '/profileScreen';
  static const String updateProfileScreen = '/updateProfileScreen';
  static const String providerProfileScreen = '/updateShopScreen';
  static const String reviewScreen = '/reviewScreen';

  static Route<dynamic> generateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splashScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const SplashScreen());

      case RouteNames.onBoardingScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const OnBoardingScreen());

      case RouteNames.authScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const AuthScreen());

      case RouteNames.forgotPasswordScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const ForgotPasswordScreen());
      case RouteNames.updatePasswordScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const UpdatePasswordScreen());
      case RouteNames.verificationScreen:
        final isNew = settings.arguments as bool;
        return MaterialPageRoute(
            settings: settings,
            builder: (_) => OtpVerificationScreen(isNew: isNew));

      case RouteNames.changePasswordScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const ChangePasswordScreen());

      case RouteNames.mainScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const MainScreen());

      // case RouteNames.profileScreen:
      //   return MaterialPageRoute(
      //       settings: settings, builder: (_) => const ProfileScreen());
      //

      // case RouteNames.updateProfileScreen:
      //   return MaterialPageRoute(
      //       settings: settings, builder: (_) => const UpdateProfileScreen());
      //
      // case RouteNames.privacyPolicyScreen:
      //   return MaterialPageRoute(
      //       settings: settings, builder: (_) => const PrivacyPolicyScreen());
      //
      // case RouteNames.termsConditionScreen:
      //   return MaterialPageRoute(
      //       settings: settings, builder: (_) => const TermsConditionScreen());
      //
      // case RouteNames.faqScreen:
      //   return MaterialPageRoute(
      //       settings: settings, builder: (_) => const FaqScreen());
      // case RouteNames.contactUsScreen:
      //   return MaterialPageRoute(
      //       settings: settings, builder: (_) => const ContactUsScreen());
      //
      // case RouteNames.aboutUsScreen:
      //   return MaterialPageRoute(
      //       settings: settings, builder: (_) => const AboutUsScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: FetchErrorText(
                text: 'No Route Found ${settings.name}', textColor: blackColor),
          ),
        );
    }
  }
}

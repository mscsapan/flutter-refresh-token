import 'package:flutter/material.dart';
import '../utils/logger.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static NavigatorState? get navigator => navigatorKey.currentState;
  static BuildContext? get context => navigatorKey.currentContext;
  
  // Basic navigation
  static Future<T?> navigateTo<T>(String routeName, {Object? arguments}) async {
    Logger.navigation('Navigating to: $routeName');
    return navigator?.pushNamed<T>(routeName, arguments: arguments);
  }
  
  static Future<T?> navigateToAndReplace<T>(String routeName, {Object? arguments}) async {
    Logger.navigation('Navigate and replace to: $routeName');
    return navigator?.pushReplacementNamed<T, Object?>(routeName, arguments: arguments);
  }
  
  static Future<T?> navigateToAndClearStack<T>(String routeName, {Object? arguments}) async {
    Logger.navigation('Navigate and clear stack to: $routeName');
    return navigator?.pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
  
  static void goBack<T>([T? result]) {
    Logger.navigation('Going back');
    if (canGoBack()) {
      navigator?.pop<T>(result);
    }
  }
  
  static bool canGoBack() {
    return navigator?.canPop() ?? false;
  }
  
  // Dialog navigation
  static Future<T?> showDialogRoute<T>({
    required Widget dialog,
    bool barrierDismissible = true,
  }) {
    Logger.navigation('Showing dialog');
    return showDialog<T>(
      context: context!,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) => dialog,
    );
  }
  
  // Bottom sheet navigation
  static Future<T?> showBottomSheetRoute<T>({
    required Widget bottomSheet,
    bool isScrollControlled = false,
  }) {
    Logger.navigation('Showing bottom sheet');
    return showModalBottomSheet<T>(
      context: context!,
      isScrollControlled: isScrollControlled,
      builder: (context) => bottomSheet,
    );
  }
  
  // Snackbar
  static void showSnackbar(String message, {Color? backgroundColor}) {
    if (context == null) return;
    
    Logger.navigation('Showing snackbar: $message');
    final scaffoldMessenger = ScaffoldMessenger.of(context!);
    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }
  
  static void showSuccessSnackbar(String message) {
    showSnackbar(message, backgroundColor: Colors.green);
  }
  
  static void showErrorSnackbar(String message) {
    showSnackbar(message, backgroundColor: Colors.red);
  }
}

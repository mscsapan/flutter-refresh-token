// USAGE EXAMPLES for NavigationService
// This file shows how to use the NavigationService methods

import 'package:flutter/material.dart';
import 'navigation_service.dart';

class NavigationServiceExamples {
  
  // Basic navigation examples
  static void navigateToLogin() {
    NavigationService.navigateTo('/login');
  }
  
  static void navigateToHomeAndReplace() {
    NavigationService.navigateToAndReplace('/home');
  }
  
  static void navigateToLoginAndClearStack() {
    NavigationService.navigateToAndClearStack('/login');
  }
  
  static void goBackToPrevious() {
    NavigationService.goBack();
  }
  
  // Dialog examples
  static void showConfirmDialog() {
    NavigationService.showDialogRoute(
      dialog: AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => NavigationService.goBack(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => NavigationService.goBack(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
  
  // Bottom sheet examples
  static void showSettingsBottomSheet() {
    NavigationService.showBottomSheetRoute(
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Settings'),
            ListTile(
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: false,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: const Text('Notifications'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Snackbar examples
  static void showSuccessMessage() {
    NavigationService.showSuccessSnackbar('Login successful!');
  }
  
  static void showErrorMessage() {
    NavigationService.showErrorSnackbar('Login failed. Please try again.');
  }
  
  static void showInfoMessage() {
    NavigationService.showSnackbar('Please check your internet connection');
  }
}

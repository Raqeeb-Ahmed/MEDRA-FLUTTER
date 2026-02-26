import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  static void success(String message) {
    _show(
      title: "Success",
      message: message,
      backgroundColor: Colors.green.shade600,
      icon: Icons.check_circle,
    );
  }

  static void error(String message) {
    _show(
      title: "Error",
      message: message,
      backgroundColor: Colors.red.shade600,
      icon: Icons.error,
    );
  }

  static void info(String message) {
    _show(
      title: "Info",
      message: message,
      backgroundColor: Colors.blue.shade600,
      icon: Icons.info,
    );
  }

  static void _show({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      icon: Icon(icon, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }
}

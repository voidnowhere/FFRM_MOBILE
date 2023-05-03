import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackbar {
  static SnackbarController get(String message, double fontSize) {
    return Get.snackbar(
      '',
      '',
      backgroundColor: Colors.green,
      messageText: Row(children: [
        const Icon(Icons.notifications, color: Colors.white),
        const SizedBox(width: 10),
        Text(
          message,
          style: TextStyle(color: Colors.white, fontSize: fontSize),
        ),
      ]),
    );
  }
}

import 'package:dio/dio.dart';
import 'package:ffrm/features/password/password_screen.dart';
import 'package:ffrm/features/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

class CustomAppBar extends AppBar {
  CustomAppBar(BuildContext context, String title, {super.key})
      : super(
          title: Text(title),
          actions: [
            if (context.widget is! ProfileScreen &&
                context.widget is! PasswordScreen)
              PopupMenuButton(
                offset: const Offset(0, 50),
                icon: const Icon(
                  Icons.account_circle,
                  color: Colors.white,
                ),
                onSelected: (value) {
                  // Profile
                  if (value == 0) {
                    Navigator.pushNamed(context, '/profile');
                  }
                  // Password
                  else if (value == 1) {
                    Navigator.pushNamed(context, '/password');
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 0, child: Text('Profile')),
                  PopupMenuItem(value: 1, child: Text('Update password')),
                ],
              ),
            IconButton(
              tooltip: 'Logout',
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                if (context.mounted) {
                  String refreshToken = prefs.getString('refreshToken') ?? '';
                  prefs.remove('accessToken');
                  prefs.remove('refreshToken');
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                  try {
                    await ApiService.getInstance().post(
                      'api/token/blacklist/',
                      data: {'refresh': refreshToken},
                    );
                    // ignore: empty_catches
                  } on DioError {}
                }
              },
            ),
          ],
        );
}

import 'package:ffrm/features/custom_app_bar.dart';
import 'package:ffrm/features/password/password_form.dart';
import 'package:flutter/material.dart';

class PasswordScreen extends StatelessWidget {
  const PasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(context, 'Password'),
      body: const Padding(
        padding: EdgeInsets.only(top: 25),
        child: PasswordForm(),
      ),
    );
  }
}

import 'package:ffrm/features/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'profile_form.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(context, 'Profile'),
      body: const Padding(
        padding: EdgeInsets.only(top: 25),
        child: ProfileForm(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        actions: [
          TextButton(
            child: const Text('Register',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                )),
            onPressed: () {
              Navigator.pushNamed(context, '/register');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 25),
        child: Column(
          children: [
            Image.asset('assets/logo.png', height: 100),
            const LoginForm(),
          ],
        ),
      ),
    );
  }
}

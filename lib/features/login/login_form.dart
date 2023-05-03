import 'package:dio/dio.dart';
import 'package:ffrm/features/api_service.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<StatefulWidget> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      ApiService.getInstance().post(
        'api/token/',
        data: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        },
      ).then((response) async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final responseData = response.data;
        prefs.setString('accessToken', responseData['access']);
        prefs.setString('refreshToken', responseData['refresh']);
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }).catchError((error) {
        if (error is DioError) {
          if (error.type == DioErrorType.badResponse) {
            setState(() {
              _errorMessage = 'Your email or password is invalid!';
            });
          } else if (error.type == DioErrorType.connectionTimeout) {
            setState(() {
              _errorMessage = 'Service unavailable.';
            });
          }
        }
      }).whenComplete(() {
        _passwordController.text = '';
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(label: Text('Email')),
              validator: ValidationBuilder().required().email().build(),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              decoration: const InputDecoration(
                label: Text('Password'),
              ),
              validator: ValidationBuilder().required().minLength(8).build(),
            ),
            const SizedBox(height: 5),
            if (_errorMessage.isNotEmpty)
              Column(
                children: [
                  const SizedBox(height: 15),
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            (_isLoading)
                ? Column(
                    children: const [
                      SizedBox(height: 20),
                      CircularProgressIndicator(),
                    ],
                  )
                : Column(
                    children: [
                      TextButton(
                        child: const Text("Don't have an account ?"),
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                      ),
                      ElevatedButton(
                        onPressed: _login,
                        child: const Text('Login'),
                      ),
                    ],
                  )
          ],
        ),
      ),
    );
  }
}

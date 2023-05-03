import 'package:dio/dio.dart';
import 'package:ffrm/features/api_service.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';

import '../custom_snackbar.dart';

class PasswordForm extends StatefulWidget {
  const PasswordForm({super.key});

  @override
  State<PasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends State<PasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmationController = TextEditingController();
  bool _isLoading = false;
  final Map<String, String> errors = {
    'password': '',
    'new_password': '',
    'confirmation': '',
  };

  void _update() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        errors.forEach((key, value) {
          errors[key] = '';
        });
      });

      ApiService.getInstance().patch('api/users/update_password/', data: {
        'password': _passwordController.text.trim(),
        'new_password': _newPasswordController.text.trim(),
        'confirmation': _confirmationController.text.trim(),
      }).then((value) {
        CustomSnackbar.get('Password updated.', 17);
      }).catchError((error) {
        if (error is DioError) {
          if (error.type == DioErrorType.badResponse) {
            final responseData = error.response!.data as Map;
            responseData.forEach((key, value) {
              if (value is List) {
                errors[key] = value.join(', ');
              } else {
                errors[key] = value;
              }
            });
          } else if (error.type == DioErrorType.connectionTimeout) {
            CustomSnackbar.get('Service unavailbale!', 17);
          }
        }
      }).whenComplete(() {
        _passwordController.text = '';
        _newPasswordController.text = '';
        _confirmationController.text = '';
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
                controller: _passwordController,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  label: const Text('Password'),
                  errorText: (errors['password']!.isNotEmpty)
                      ? errors['password']
                      : null,
                ),
                validator: ValidationBuilder().required().minLength(8).build(),
              ),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  label: const Text('New password'),
                  errorText: (errors['new_password']!.isNotEmpty)
                      ? errors['new_password']
                      : null,
                ),
                validator: ValidationBuilder().required().minLength(8).build(),
              ),
              TextFormField(
                controller: _confirmationController,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  label: const Text('Confirmation'),
                  errorText: (errors['confirmation']!.isNotEmpty)
                      ? errors['confirmation']
                      : null,
                ),
                validator: ValidationBuilder().required().minLength(8).add(
                  (value) {
                    if (value != _newPasswordController.text) {
                      return 'New password and confirmation do not match.';
                    }
                    return null;
                  },
                ).build(),
              ),
              const SizedBox(height: 20),
              (_isLoading)
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _update,
                      child: const Text('Update'),
                    ),
            ],
          ),
        ));
  }
}

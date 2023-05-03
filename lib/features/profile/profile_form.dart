import 'package:dio/dio.dart';
import 'package:ffrm/features/api_service.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';

import '../custom_snackbar.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nicController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isFirtLoading = true;
  bool _isLoading = false;
  final Map<String, String> errors = {
    'email': '',
    'password': '',
    'nic': '',
    'first_name': '',
    'last_name': '',
  };

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ApiService.getInstance().get('api/users/profile/').then((response) {
        final responseData = response.data;
        _emailController.text = responseData['email'];
        _nicController.text = responseData['nic'];
        _firstNameController.text = responseData['first_name'];
        _lastNameController.text = responseData['last_name'];
        setState(() {
          _isFirtLoading = false;
        });
      }).catchError((error) {
        if (error is DioError && error.type == DioErrorType.connectionTimeout) {
          CustomSnackbar.get('Service unavailbale!', 17);
        }
      });
    });
  }

  void _update() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        errors.forEach((key, value) {
          errors[key] = '';
        });
      });

      ApiService.getInstance().put('api/users/profile/', data: {
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
        'nic': _nicController.text.trim(),
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
      }).then((value) {
        CustomSnackbar.get('Profile information updated.', 17);
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
          child: (_isFirtLoading)
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        label: const Text('Email'),
                        errorText: (errors['email']!.isNotEmpty)
                            ? errors['email']
                            : null,
                      ),
                      validator: ValidationBuilder().required().email().build(),
                    ),
                    TextFormField(
                      controller: _nicController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        label: const Text('NIC'),
                        errorText:
                            (errors['nic']!.isNotEmpty) ? errors['nic'] : null,
                      ),
                      validator:
                          ValidationBuilder().required().maxLength(8).build(),
                    ),
                    TextFormField(
                      controller: _firstNameController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        label: const Text('First name'),
                        errorText: (errors['first_name']!.isNotEmpty)
                            ? errors['first_name']
                            : null,
                      ),
                      validator: ValidationBuilder().required().build(),
                    ),
                    TextFormField(
                      controller: _lastNameController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        label: const Text('Last name'),
                        errorText: (errors['last_name']!.isNotEmpty)
                            ? errors['last_name']
                            : null,
                      ),
                      validator: ValidationBuilder().required().build(),
                    ),
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
                      validator:
                          ValidationBuilder().required().minLength(8).build(),
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

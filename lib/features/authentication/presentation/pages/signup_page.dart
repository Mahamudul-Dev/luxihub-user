import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/assets.dart';
import '../../../../core/config/utils.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/text_input_field.dart';
import '../bloc/auth_bloc.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _tocAccepted = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_tocAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must accept the terms and conditions.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    context.read<AuthBloc>().add(SignupSubmitted(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          password: _passwordController.text,
          tocAccepted: _tocAccepted,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.goNamed(AppRoutes.home.name);
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          appBar: AppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(Utils.defaultPadding),
            child: Form(
              key: _formKey,
              child: Column(
                spacing: Utils.defaultPadding,
                children: [
                  Image.asset(Assets.appLogo, width: 200),

                  Text(
                    'Sign Up Here',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: TextInputField(
                          controller: _firstNameController,
                          label: 'First Name',
                          textInputAction: TextInputAction.next,
                          enabled: !isLoading,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: Utils.defaultPadding),
                      Expanded(
                        child: TextInputField(
                          controller: _lastNameController,
                          label: 'Last Name',
                          textInputAction: TextInputAction.next,
                          enabled: !isLoading,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),

                  TextInputField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email is required';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),

                  TextInputField(
                    controller: _addressController,
                    label: 'Address',
                    keyboardType: TextInputType.streetAddress,
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Address is required' : null,
                  ),

                  TextInputField(
                    controller: _phoneController,
                    label: 'Phone',
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Phone is required' : null,
                  ),

                  TextInputField(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: true,
                    showPasswordToggle: true,
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 6) return 'Minimum 6 characters';
                      return null;
                    },
                  ),

                  TextInputField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    obscureText: true,
                    showPasswordToggle: true,
                    textInputAction: TextInputAction.done,
                    enabled: !isLoading,
                    onSubmitted: (_) => _submit(),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please confirm your password';
                      if (v != _passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                  ),

                  Row(
                    children: [
                      Checkbox(
                        value: _tocAccepted,
                        onChanged: isLoading
                            ? null
                            : (v) => setState(() => _tocAccepted = v ?? false),
                      ),
                      const Text('I accept the terms and conditions'),
                      TextButton(
                        onPressed: isLoading ? null : () {},
                        child: const Text('View Terms'),
                      ),
                    ],
                  ),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Sign Up'),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?'),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => context.pushNamed(AppRoutes.login.name),
                        child: Text(
                          'Login Here',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/assets.dart';
import '../../../../core/config/utils.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/text_input_field.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Phone OTP
  final _phoneFormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  // Email/password
  final _emailFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (!_phoneFormKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          SendPhoneOtpRequested(_phoneController.text.trim()),
        );
  }

  void _verifyOtp(String phone) {
    if (_otpController.text.trim().isEmpty) return;
    context.read<AuthBloc>().add(VerifyPhoneOtpRequested(
          phone: phone,
          token: _otpController.text.trim(),
        ));
  }

  void _signInWithEmail() {
    if (!_emailFormKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(SignInWithEmailRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.goNamed(AppRoutes.home.name);
        } else if (state is AuthConfirmationEmailSent) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Confirmation email sent — check your inbox.'),
            backgroundColor: Colors.green,
          ));
        } else if (state is AuthFailure) {
          final isUnconfirmed =
              state.message.toLowerCase().contains('not confirmed') ||
              state.message.toLowerCase().contains('email_not_confirmed');

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              isUnconfirmed
                  ? 'Please confirm your email before signing in.'
                  : state.message,
            ),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: isUnconfirmed ? 6 : 3),
            action: isUnconfirmed
                ? SnackBarAction(
                    label: 'Resend',
                    textColor: Colors.white,
                    onPressed: () => context.read<AuthBloc>().add(
                          ResendConfirmationRequested(
                              _emailController.text.trim()),
                        ),
                  )
                : null,
          ));
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final otpSent = state is AuthOtpSent;
        final phone = otpSent ? state.phone : '';

        return Scaffold(
          appBar: AppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(Utils.defaultPadding),
            child: Column(
              spacing: Utils.defaultPadding,
              children: [
                Image.asset(Assets.appLogo, width: 180),
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                // ── Tab bar ────────────────────────────────────────────────
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Phone OTP'),
                    Tab(text: 'Email'),
                  ],
                ),

                SizedBox(
                  height: 320,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // ── Phone OTP tab ──────────────────────────────────
                      Form(
                        key: _phoneFormKey,
                        child: Column(
                          spacing: Utils.defaultPadding,
                          children: [
                            const SizedBox(height: Utils.defaultPadding),
                            TextInputField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              hint: '+60123456789',
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.done,
                              enabled: !isLoading && !otpSent,
                              onSubmitted: (_) => _sendOtp(),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Phone number is required';
                                }
                                return null;
                              },
                            ),
                            if (otpSent) ...[
                              TextInputField(
                                controller: _otpController,
                                label: 'OTP Code',
                                hint: '6-digit code',
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                enabled: !isLoading,
                                onSubmitted: (_) => _verifyOtp(phone),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : () => _verifyOtp(phone),
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : const Text('Verify OTP'),
                                ),
                              ),
                              TextButton(
                                onPressed: isLoading ? null : _sendOtp,
                                child: const Text('Resend OTP'),
                              ),
                            ] else
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _sendOtp,
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : const Text('Send OTP'),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // ── Email/password tab ─────────────────────────────
                      Form(
                        key: _emailFormKey,
                        child: Column(
                          spacing: Utils.defaultPadding,
                          children: [
                            const SizedBox(height: Utils.defaultPadding),
                            TextInputField(
                              controller: _emailController,
                              label: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              enabled: !isLoading,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!v.contains('@')) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            TextInputField(
                              controller: _passwordController,
                              label: 'Password',
                              obscureText: true,
                              showPasswordToggle: true,
                              textInputAction: TextInputAction.done,
                              enabled: !isLoading,
                              onSubmitted: (_) => _signInWithEmail(),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Password is required';
                                }
                                if (v.length < 6) return 'Minimum 6 characters';
                                return null;
                              },
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _signInWithEmail,
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Text('Login'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => context.pushNamed(AppRoutes.signup.name),
                      child: Text(
                        'Sign up',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).primaryColor,
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
        );
      },
    );
  }
}

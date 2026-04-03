import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luxihub_user/features/onboarding/presentation/pages/splash_page.dart';
import 'package:luxihub_user/features/service_providers/presentation/pages/service_provider_list_page.dart';

import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../widgets/error_view.dart';

part 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash.path,
  debugLogDiagnostics: true,
  errorBuilder: (context, state) => ErrorView(error: state.error),
  routes: [
    GoRoute(
      name: AppRoutes.splash.name,
      path: AppRoutes.splash.path,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      name: AppRoutes.onboarding.name,
      path: AppRoutes.onboarding.path,
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(path: AppRoutes.login.path, name: AppRoutes.login.name, builder: (context, state) => const LoginPage()),
    GoRoute(
      name: AppRoutes.home.name,
      path: AppRoutes.home.path,
      builder: (context, state) => const ServiceProviderListPage(),
    ),
  ],
);

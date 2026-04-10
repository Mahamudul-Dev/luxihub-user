import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/signup_page.dart';
import '../../core/domain/entities/service_provider_entity.dart';
import '../../features/home/data/repository_impl/home_repository_impl.dart';
import '../../features/home/domain/usecase/get_service_providers_usecase.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/service_providers/presentation/pages/service_provider_profile_page.dart';
import '../../features/job_request/presentation/pages/job_request_details_page.dart';
import '../../features/rating_review/presentation/pages/rating_page.dart';
import '../../features/onboarding/presentation/pages/splash_page.dart';
import '../widgets/error_view.dart';

part 'app_routes.dart';

/// Wraps a [Stream] as a [ChangeNotifier] so GoRouter re-evaluates
/// the [redirect] every time the auth state changes.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Stream<AuthState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Creates the app router. Call once from [main.dart], passing the
/// already-created [AuthBloc] so the redirect logic can read its state.
GoRouter createRouter(AuthBloc authBloc) {
  final notifier = _AuthChangeNotifier(authBloc.stream);

  return GoRouter(
    initialLocation: AppRoutes.splash.path,
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    errorBuilder: (context, state) => ErrorView(error: state.error),

    // redirect: (context, routerState) {
    //   final isAuthenticated = authBloc.state is AuthAuthenticated;
    //   final location = routerState.uri.path;

    //   // Auth-only routes: home and any sub-paths
    //   final goingToHome = location == AppRoutes.home.path;

    //   // Guest-only routes: everything before home
    //   final goingToGuestRoute = [
    //     AppRoutes.splash.path,
    //     AppRoutes.onboarding.path,
    //     AppRoutes.login.path,
    //     AppRoutes.signup.path,
    //   ].contains(location);

    //   if (isAuthenticated && goingToGuestRoute) {
    //     return AppRoutes.home.path;
    //   }

    //   if (!isAuthenticated && goingToHome) {
    //     return AppRoutes.login.path;
    //   }

    //   return null; // no redirect
    // },

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
      GoRoute(
        name: AppRoutes.login.name,
        path: AppRoutes.login.path,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        name: AppRoutes.signup.name,
        path: AppRoutes.signup.path,
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        name: AppRoutes.serviceProviderProfile.name,
        path: AppRoutes.serviceProviderProfile.path,
        builder: (context, state) {
          final provider = state.extra as ServiceProviderEntity;
          return ServiceProviderProfilePage(provider: provider);
        },
      ),
      GoRoute(
        name: AppRoutes.jobRequestDetails.name,
        path: AppRoutes.jobRequestDetails.path,
        builder: (context, state) {
          final provider = state.extra as ServiceProviderEntity;
          return JobRequestDetailsPage(provider: provider);
        },
      ),
      GoRoute(
        name: AppRoutes.rating.name,
        path: AppRoutes.rating.path,
        builder: (context, state) {
          final provider = state.extra as ServiceProviderEntity;
          return RatingPage(provider: provider);
        },
      ),
      GoRoute(
        name: AppRoutes.home.name,
        path: AppRoutes.home.path,
        builder: (context, state) => BlocProvider(
          create: (_) => HomeBloc(
            GetServiceProvidersUseCase(const HomeRepositoryImpl()),
          )..add(const HomeProvidersRequested()),
          child: const HomePage(),
        ),
      ),
    ],
  );
}

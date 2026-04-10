part of 'app_router.dart';

class AppRoutes {
  static const RouteModel splash = RouteModel(name: 'Splash', path: '/splash');
  static const RouteModel onboarding = RouteModel(name: 'Onboarding', path: '/onboarding');
  static const RouteModel home = RouteModel(name: 'Home', path: '/');
  static const RouteModel login = RouteModel(name: 'Login', path: '/login');
  static const RouteModel signup = RouteModel(name: 'Signup', path: '/signup');
  static const RouteModel serviceProviderProfile = RouteModel(name: 'ServiceProviderProfile', path: '/provider/:id');
  static const RouteModel jobRequestDetails = RouteModel(name: 'JobRequestDetails', path: '/job-request');
  static const RouteModel rating = RouteModel(name: 'Rating', path: '/rating');
}

class RouteModel {
  final String name;
  final String path;

  const RouteModel({
    required this.name,
    required this.path,
  }); 
  
}
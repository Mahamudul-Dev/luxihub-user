part of 'app_router.dart';

class AppRoutes {
  static const RouteModel splash = RouteModel(name: 'Splash', path: '/splash');
  static const RouteModel onboarding = RouteModel(name: 'Onboarding', path: '/onboarding');
  static const RouteModel home = RouteModel(name: 'Home', path: '/home');
  static const RouteModel login = RouteModel(name: 'Login', path: '/login');
}

class RouteModel {
  final String name;
  final String path;

  const RouteModel({
    required this.name,
    required this.path,
  }); 
  
}
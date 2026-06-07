part of 'app_router.dart';

class AppRoutes {
  static const RouteModel splash = RouteModel(name: 'Splash', path: '/splash');
  static const RouteModel onboarding = RouteModel(name: 'Onboarding', path: '/onboarding');
  static const RouteModel home = RouteModel(name: 'Home', path: '/');
  static const RouteModel login = RouteModel(name: 'Login', path: '/login');
  static const RouteModel signup = RouteModel(name: 'Signup', path: '/signup');
  static const RouteModel profile = RouteModel(name: 'Profile', path: '/profile');
  static const RouteModel editProfile = RouteModel(name: 'EditProfile', path: '/profile/edit');
  static const RouteModel serviceProviderProfile = RouteModel(name: 'ServiceProviderProfile', path: '/provider/:id');
  static const RouteModel jobRequestDetails = RouteModel(name: 'JobRequestDetails', path: '/job-request');
  static const RouteModel postJob = RouteModel(name: 'PostJob', path: '/post-job');
  static const RouteModel myJobs = RouteModel(name: 'MyJobs', path: '/my-jobs');
  static const RouteModel inbox = RouteModel(name: 'Inbox', path: '/inbox');
  static const RouteModel chat = RouteModel(name: 'Chat', path: '/chat/:conversationId');
  static const RouteModel rating = RouteModel(name: 'Rating', path: '/rating');
  static const RouteModel serviceProviderList = RouteModel(name: 'ServiceProviderList', path: '/providers');
  static const RouteModel notifications = RouteModel(name: 'Notifications', path: '/notifications');
  static const RouteModel providerReviews = RouteModel(name: 'ProviderReviews', path: '/provider/:id/reviews');
  static const RouteModel savedProviders = RouteModel(name: 'SavedProviders', path: '/saved');
}

class RouteModel {
  final String name;
  final String path;

  const RouteModel({
    required this.name,
    required this.path,
  }); 
  
}
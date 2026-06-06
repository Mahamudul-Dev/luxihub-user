import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/stripe_config.dart';
import 'core/config/supabase_config.dart';
import 'core/di/service_locator.dart';
import 'core/services/fcm_service.dart';
import 'package:go_router/go_router.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase must be initialized before anything else
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  Stripe.publishableKey = StripeConfig.publishableKey;
  await Stripe.instance.applySettings();

  setupServiceLocator();

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>()..add(const AuthCheckRequested());
    _router = createRouter(_authBloc);

    // Give FcmService the router so it can navigate on notification tap
    FcmService.instance.setRouter(_router);

    // Initialize FCM whenever the user authenticates
    _authBloc.stream.listen((state) {
      if (state is AuthAuthenticated) {
        FcmService.instance.initialize(state.user.id);
      }
    });
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: _router,
        ),
      ),
    );
  }
}

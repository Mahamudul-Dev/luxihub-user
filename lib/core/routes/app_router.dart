import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/service_locator.dart';
import '../../core/domain/entities/conversation.dart';
import '../../core/domain/entities/job_request.dart';
import '../../core/domain/entities/profile.dart';
import '../../core/domain/entities/service_provider_entity.dart';
import '../../core/widgets/scaffold_with_nav_bar.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/signup_page.dart';
import '../../features/chat/domain/usecases/get_conversations.dart';
import '../../features/chat/domain/usecases/send_message.dart';
import '../../features/chat/domain/usecases/watch_messages.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/chat/presentation/pages/inbox_page.dart';
import '../../features/home/domain/usecase/get_categories_usecase.dart';
import '../../features/home/domain/usecase/get_service_providers_usecase.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/job_request/domain/usecases/cancel_job.dart';
import '../../features/job_request/domain/usecases/complete_job.dart';
import '../../features/job_request/domain/usecases/get_my_jobs.dart';
import '../../features/job_request/domain/usecases/post_job.dart';
import '../../features/job_request/domain/usecases/save_transaction.dart';
import '../../features/job_request/domain/usecases/update_job_status.dart';
import '../../features/job_request/domain/usecases/watch_job_status.dart';
import '../../features/job_request/presentation/bloc/job_request_bloc.dart';
import '../../features/job_request/presentation/pages/job_request_details_page.dart';
import '../../features/job_request/presentation/pages/my_jobs_page.dart';
import '../../features/job_request/presentation/pages/post_job_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/onboarding/presentation/pages/splash_page.dart';
import '../../features/profile/domain/usecases/get_profile.dart';
import '../../features/profile/domain/usecases/update_profile.dart';
import '../../features/profile/domain/usecases/upload_avatar.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/rating_review/presentation/pages/rating_page.dart';
import '../../features/notifications/domain/usecases/get_notifications.dart';
import '../../features/notifications/domain/usecases/mark_all_notifications_read.dart';
import '../../features/notifications/domain/usecases/mark_notification_read.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/rating_review/presentation/pages/provider_reviews_page.dart';
import '../../features/saved_providers/presentation/pages/saved_providers_page.dart';
import '../../features/service_providers/presentation/bloc/service_provider_bloc.dart';
import '../../features/service_providers/presentation/pages/service_provider_list_page.dart';
import '../../features/transactions/presentation/pages/transaction_history_page.dart';
import '../../features/service_providers/presentation/pages/service_provider_profile_page.dart';
import '../widgets/error_view.dart';

part 'app_routes.dart';

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

GoRouter createRouter(AuthBloc authBloc) {
  final notifier = _AuthChangeNotifier(authBloc.stream);

  JobRequestBloc buildJobBloc() => JobRequestBloc(
        authBloc: authBloc,
        postJob: sl<PostJob>(),
        getMyJobs: sl<GetMyJobs>(),
        watchJobStatus: sl<WatchJobStatus>(),
        cancelJob: sl<CancelJob>(),
        completeJob: sl<CompleteJob>(),
        saveTransaction: sl<SaveTransaction>(),
        updateJobStatus: sl<UpdateJobStatus>(),
      );

  ChatBloc buildChatBloc() => ChatBloc(
        authBloc: authBloc,
        getConversations: sl<GetConversations>(),
        watchMessages: sl<WatchMessages>(),
        sendMessage: sl<SendMessage>(),
      );

  ProfileBloc buildProfileBloc() => ProfileBloc(
        getProfile: sl<GetProfile>(),
        updateProfile: sl<UpdateProfile>(),
        uploadAvatar: sl<UploadAvatar>(),
      );

  return GoRouter(
    initialLocation: AppRoutes.splash.path,
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    errorBuilder: (context, state) => ErrorView(error: state.error),

    redirect: (context, routerState) {
      final authState = authBloc.state;
      final isAuthenticated = authState is AuthAuthenticated;
      final isUnauthenticated = authState is AuthUnauthenticated;
      final location = routerState.uri.path;

      final guestOnlyRoutes = [
        AppRoutes.splash.path,
        AppRoutes.onboarding.path,
        AppRoutes.login.path,
        AppRoutes.signup.path,
      ];
      final isGuestRoute = guestOnlyRoutes.contains(location);

      if (isAuthenticated && isGuestRoute) return AppRoutes.home.path;
      if (isUnauthenticated && !isGuestRoute) return AppRoutes.login.path;

      return null;
    },

    routes: [
      // ── Guest-only routes ────────────────────────────────────────────────
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

      // ── Full-screen authenticated routes (no bottom nav) ─────────────────
      GoRoute(
        name: AppRoutes.serviceProviderProfile.name,
        path: AppRoutes.serviceProviderProfile.path,
        builder: (context, state) {
          final provider = state.extra as ServiceProviderEntity;
          return ServiceProviderProfilePage(provider: provider);
        },
      ),
      GoRoute(
        name: AppRoutes.postJob.name,
        path: AppRoutes.postJob.path,
        builder: (context, state) {
          final provider = state.extra as ServiceProviderEntity;
          return BlocProvider(
            create: (_) => buildJobBloc(),
            child: PostJobPage(provider: provider),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.jobRequestDetails.name,
        path: AppRoutes.jobRequestDetails.path,
        builder: (context, state) {
          final job = state.extra as JobRequest;
          return BlocProvider(
            create: (_) => buildJobBloc(),
            child: JobRequestDetailsPage(job: job),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.rating.name,
        path: AppRoutes.rating.path,
        builder: (context, state) {
          final job = state.extra as JobRequest;
          return RatingPage(job: job);
        },
      ),
      GoRoute(
        name: AppRoutes.transactions.name,
        path: AppRoutes.transactions.path,
        builder: (context, state) => const TransactionHistoryPage(),
      ),
      GoRoute(
        name: AppRoutes.editProfile.name,
        path: AppRoutes.editProfile.path,
        builder: (context, state) {
          final profile = state.extra as Profile;
          return BlocProvider(
            create: (_) => buildProfileBloc(),
            child: EditProfilePage(profile: profile),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.chat.name,
        path: AppRoutes.chat.path,
        builder: (context, state) {
          final conversation = state.extra as Conversation;
          return BlocProvider(
            create: (_) => buildChatBloc(),
            child: ChatPage(conversation: conversation),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.notifications.name,
        path: AppRoutes.notifications.path,
        builder: (context, state) {
          final authBloc = context.read<AuthBloc>();
          final authState = authBloc.state;
          final userId =
              authState is AuthAuthenticated ? authState.user.id : '';
          return BlocProvider(
            create: (_) => NotificationBloc(
              getNotifications: sl<GetNotifications>(),
              markRead: sl<MarkNotificationRead>(),
              markAllRead: sl<MarkAllNotificationsRead>(),
            )..add(NotificationsWatchStarted(userId)),
            child: const NotificationsPage(),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.providerReviews.name,
        path: AppRoutes.providerReviews.path,
        builder: (context, state) {
          final args = state.extra as ProviderReviewsArgs;
          return ProviderReviewsPage(args: args);
        },
      ),
      GoRoute(
        name: AppRoutes.serviceProviderList.name,
        path: AppRoutes.serviceProviderList.path,
        builder: (context, state) {
          final args = state.extra as ServiceProviderListArgs?;
          return BlocProvider(
            create: (_) => ServiceProviderBloc(
              sl<GetServiceProvidersUseCase>(),
              sl<GetCategoriesUseCase>(),
              initialQuery: args?.initialQuery ?? '',
              initialCategory: args?.initialCategory,
            )..add(const ServiceProviderFetchRequested()),
            child: ServiceProviderListPage(
              initialSearchText: args?.initialQuery ?? '',
            ),
          );
        },
      ),

      // ── Authenticated shell (bottom nav) ──────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            ScaffoldWithNavBar(shell: shell),
        branches: [
          // Tab 0 — Home
          StatefulShellBranch(routes: [
            GoRoute(
              name: AppRoutes.home.name,
              path: AppRoutes.home.path,
              builder: (context, state) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (_) => HomeBloc(sl<GetServiceProvidersUseCase>(), sl<GetCategoriesUseCase>())
                      ..add(const HomeProvidersRequested()),
                  ),
                  BlocProvider(
                    create: (_) {
                      final bloc = buildProfileBloc();
                      final uid = authBloc.state is AuthAuthenticated
                          ? (authBloc.state as AuthAuthenticated).user.id
                          : null;
                      if (uid != null) bloc.add(ProfileFetchRequested(uid));
                      return bloc;
                    },
                  ),
                ],
                child: const HomePage(),
              ),
            ),
          ]),

          // Tab 1 — My Jobs
          StatefulShellBranch(routes: [
            GoRoute(
              name: AppRoutes.myJobs.name,
              path: AppRoutes.myJobs.path,
              builder: (context, state) => BlocProvider(
                create: (_) => buildJobBloc(),
                child: const MyJobsPage(),
              ),
            ),
          ]),

          // Tab 2 — Inbox
          StatefulShellBranch(routes: [
            GoRoute(
              name: AppRoutes.inbox.name,
              path: AppRoutes.inbox.path,
              builder: (context, state) => BlocProvider(
                create: (_) => buildChatBloc(),
                child: const InboxPage(),
              ),
            ),
          ]),

          // Tab 3 — Saved Providers
          StatefulShellBranch(routes: [
            GoRoute(
              name: AppRoutes.savedProviders.name,
              path: AppRoutes.savedProviders.path,
              builder: (context, state) => const SavedProvidersPage(),
            ),
          ]),

          // Tab 4 — Profile
          StatefulShellBranch(routes: [
            GoRoute(
              name: AppRoutes.profile.name,
              path: AppRoutes.profile.path,
              builder: (context, state) => BlocProvider(
                create: (_) => buildProfileBloc(),
                child: const ProfilePage(),
              ),
            ),
          ]),
        ],
      ),
    ],
  );
}

import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/authentication/data/datasources/auth_remote_datasource.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/domain/usecases/send_phone_otp.dart';
import '../../features/authentication/domain/usecases/sign_in_with_email.dart';
import '../../features/authentication/domain/usecases/sign_out.dart';
import '../../features/authentication/domain/usecases/sign_up_with_email.dart';
import '../../features/authentication/domain/usecases/verify_phone_otp.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../features/chat/data/datasources/chat_remote_datasource.dart';
import '../../features/rating_review/data/datasources/review_remote_datasource.dart';
import '../../features/rating_review/data/repositories/review_repository_impl.dart';
import '../../features/rating_review/domain/repositories/review_repository.dart';
import '../../features/rating_review/domain/usecases/get_job_review.dart';
import '../../features/rating_review/domain/usecases/get_provider_reviews.dart';
import '../../features/rating_review/domain/usecases/submit_review.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/usecases/get_conversations.dart';
import '../../features/chat/domain/usecases/get_or_create_conversation.dart';
import '../../features/chat/domain/usecases/send_message.dart';
import '../../features/chat/domain/usecases/watch_messages.dart';
import '../../features/home/data/datasources/home_remote_datasource.dart';
import '../../features/job_request/data/datasources/job_remote_datasource.dart';
import '../../features/job_request/data/repositories/job_repository_impl.dart';
import '../../features/job_request/domain/repositories/job_repository.dart';
import '../../features/job_request/domain/usecases/cancel_job.dart';
import '../../features/job_request/domain/usecases/complete_job.dart';
import '../../features/job_request/domain/usecases/get_my_jobs.dart';
import '../../features/job_request/domain/usecases/post_job.dart';
import '../../features/job_request/domain/usecases/save_transaction.dart';
import '../../features/job_request/domain/usecases/update_job_status.dart';
import '../../features/job_request/domain/usecases/watch_job_status.dart';
import '../../features/home/data/repository_impl/home_repository_impl.dart';
import '../../features/home/domain/repository/i_home_repository.dart';
import '../../features/home/domain/usecase/get_categories_usecase.dart';
import '../../features/home/domain/usecase/get_service_providers_usecase.dart';
import '../../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/i_notification_repository.dart';
import '../../features/notifications/domain/usecases/get_notifications.dart';
import '../../features/notifications/domain/usecases/mark_all_notifications_read.dart';
import '../../features/notifications/domain/usecases/mark_notification_read.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile.dart';
import '../../features/profile/domain/usecases/update_profile.dart';
import '../../features/profile/domain/usecases/upload_avatar.dart';
import '../../features/saved_providers/data/datasources/saved_providers_datasource.dart';
import '../../features/saved_providers/data/repositories/saved_providers_repository_impl.dart';
import '../../features/saved_providers/domain/repositories/saved_providers_repository.dart';
import '../../features/saved_providers/domain/usecases/get_saved_provider_ids.dart';
import '../../features/saved_providers/domain/usecases/get_saved_providers.dart';
import '../../features/saved_providers/domain/usecases/save_provider.dart';
import '../../features/saved_providers/domain/usecases/unsave_provider.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  // ── Supabase ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // ── Auth ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => SendPhoneOtp(sl()));
  sl.registerLazySingleton(() => VerifyPhoneOtp(sl()));
  sl.registerLazySingleton(() => SignInWithEmail(sl()));
  sl.registerLazySingleton(() => SignUpWithEmail(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));

  // AuthBloc is a factory — fresh instance per widget tree entry point
  sl.registerFactory(() => AuthBloc(
        repository: sl(),
        sendPhoneOtp: sl(),
        verifyPhoneOtp: sl(),
        signInWithEmail: sl(),
        signUpWithEmail: sl(),
        signOut: sl(),
      ));

  // ── Rating & Review ───────────────────────────────────────────────────────
  sl.registerLazySingleton<ReviewRemoteDataSource>(
    () => ReviewRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => SubmitReview(sl()));
  sl.registerLazySingleton(() => GetJobReview(sl()));
  sl.registerLazySingleton(() => GetProviderReviews(sl()));

  // ── Chat ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetConversations(sl()));
  sl.registerLazySingleton(() => GetOrCreateConversation(sl()));
  sl.registerLazySingleton(() => WatchMessages(sl()));
  sl.registerLazySingleton(() => SendMessage(sl()));

  // ── Job Request ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<JobRemoteDataSource>(
    () => JobRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<JobRepository>(
    () => JobRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => PostJob(sl()));
  sl.registerLazySingleton(() => GetMyJobs(sl()));
  sl.registerLazySingleton(() => WatchJobStatus(sl()));
  sl.registerLazySingleton(() => CancelJob(sl()));
  sl.registerLazySingleton(() => CompleteJob(sl()));
  sl.registerLazySingleton(() => SaveTransaction(sl()));
  sl.registerLazySingleton(() => UpdateJobStatus(sl()));

  // ── Home ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<IHomeRepository>(
    () => HomeRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetServiceProvidersUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));

  // ── Notifications ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<INotificationRepository>(
    () => NotificationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetNotifications(sl()));
  sl.registerLazySingleton(() => MarkNotificationRead(sl()));
  sl.registerLazySingleton(() => MarkAllNotificationsRead(sl()));

  // ── Profile ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetProfile(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerLazySingleton(() => UploadAvatar(sl()));

  // ── Saved Providers ───────────────────────────────────────────────────────
  sl.registerLazySingleton<SavedProvidersDatasource>(
    () => SavedProvidersDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<SavedProvidersRepository>(
    () => SavedProvidersRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetSavedProviderIds(sl()));
  sl.registerLazySingleton(() => GetSavedProviders(sl()));
  sl.registerLazySingleton(() => SaveProvider(sl()));
  sl.registerLazySingleton(() => UnsaveProvider(sl()));
}

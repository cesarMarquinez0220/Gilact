import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Data Sources
import '../../features/ui/data/datasources/ui_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/videos/data/datasources/video_remote_data_source.dart';
import '../../features/tips/data/datasources/tip_remote_data_source.dart';
import '../../features/user/data/datasources/user_profile_remote_data_source.dart';
import '../../features/chatbot/data/datasources/chatbot_remote_data_source.dart';
import '../../features/settings/data/datasources/settings_remote_data_source.dart';
import '../../features/settings/data/datasources/settings_remote_data_source_impl.dart';
import '../../features/settings/data/datasources/settings_local_data_source.dart';

// Repositories
import '../../features/ui/data/repositories/ui_repository_impl.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/videos/data/repositories/video_repository_impl.dart';
import '../../features/tips/data/repositories/tip_repository_impl.dart';
import '../../features/user/data/repositories/user_profile_repository_impl.dart';
import '../../features/lessons/data/repositories/lesson_repository_impl.dart';
import '../../features/chatbot/data/repositories/chatbot_repository_impl.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';

// Use Cases - Solo los básicos necesarios
import '../../features/ui/domain/usecases/ui_usecases.dart' as ui_usecases;
import '../../features/auth/domain/usecases/auth_usecases.dart'
    as auth_usecases;
import '../../features/videos/domain/usecases/video_usecases.dart'
    as video_usecases;
import '../../features/tips/domain/usecases/tip_usecases.dart' as tip_usecases;
import '../../features/user/domain/usecases/user_profile_usecases.dart'
    as user_usecases;
import '../../features/lessons/domain/usecases/lesson_usecases.dart'
    as lesson_usecases;
import '../../features/chatbot/domain/usecases/chatbot_usecases.dart'
    as chatbot_usecases;
import '../../features/settings/domain/usecases/settings_usecases.dart'
    as settings_usecases;

// Services
import '../../features/onboarding/data/services/user_subcollections_service.dart';
import '../../features/videos/data/services/video_interaction_service.dart';
import '../../features/lactation/data/services/lactation_service.dart';
import '../../features/lactation/data/services/lactation_flow_service.dart';
import '../../features/lactation/data/services/sleep_notification_service.dart';
import '../../features/auth/data/services/offline_session_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/sync_queue_service.dart';
import '../../core/services/offline_sync_service.dart';
import '../../core/services/conflict_resolution_service.dart';
import '../../core/services/localization_service.dart';
import '../../core/services/sound_service.dart';
import '../../core/services/vibration_service.dart';
import '../../core/services/app_logger.dart';
import '../../core/services/auto_save_service.dart';
import '../../features/videos/data/services/video_encryption_service.dart';
import '../../features/videos/data/services/video_download_service.dart';
import '../../features/videos/data/datasources/video_offline_local_data_source.dart';
import '../../features/user/data/datasources/user_profile_offline_local_data_source.dart';

// Gamification
import '../../features/gamification/data/datasources/gamification_local_data_source.dart';
import '../../features/gamification/data/datasources/gamification_remote_data_source.dart';
import '../../features/gamification/data/repositories/gamification_repository_impl.dart';
import '../../features/gamification/domain/repositories/gamification_repository.dart';
import '../../features/gamification/domain/services/gamification_service.dart';
import '../../features/gamification/domain/services/user_statistics_service.dart';
import '../../features/gamification/domain/services/daily_challenge_service.dart';
import '../../features/gamification/presentation/bloc/gamification_bloc.dart';

// Growth Tracking Data Sources
import '../../features/lactation/data/datasources/baby_weight_offline_local_data_source.dart';
import '../../features/lactation/data/datasources/sleep_offline_local_data_source.dart';

// Providers
import '../../features/lactation/presentation/providers/lactation_provider.dart';
import '../../features/lactation/presentation/providers/lactation_flow_provider.dart';

// BLoCs
import '../../features/ui/presentation/bloc/ui_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/videos/presentation/bloc/video_bloc.dart';
import '../../features/videos/presentation/bloc/video_download_bloc.dart';
import '../../features/tips/presentation/bloc/tip_bloc.dart';
import '../../features/user/presentation/bloc/user_profile_bloc.dart';
import '../../features/lessons/presentation/bloc/lesson_bloc.dart';
import '../../features/chatbot/presentation/bloc/chatbot_bloc.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Registro manual de dependencias externas
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);

  // Services
  getIt.registerLazySingleton<UserSubcollectionsService>(
    () => UserSubcollectionsService(
      getIt<FirebaseFirestore>(),
      getIt<AppLogger>(),
    ),
  );
  getIt.registerLazySingleton<VideoInteractionService>(
    () => VideoInteractionService(getIt<FirebaseFirestore>()),
  );
  // Gamification Repository (debe estar antes de UserStatisticsService)
  getIt.registerLazySingleton<GamificationLocalDataSource>(
    () => GamificationLocalDataSource(),
  );
  getIt.registerLazySingleton<GamificationRemoteDataSource>(
    () => GamificationRemoteDataSource(),
  );
  getIt.registerLazySingleton<GamificationRepository>(
    () => GamificationRepositoryImpl(
      localDataSource: getIt<GamificationLocalDataSource>(),
      remoteDataSource: getIt<GamificationRemoteDataSource>(),
      connectivityService: getIt<ConnectivityService>(),
    ),
  );

  // LactationService (sin UserStatisticsService inicialmente)
  getIt.registerLazySingleton<LactationService>(
    () => LactationService(getIt<FirebaseFirestore>(), getIt<FirebaseAuth>()),
  );

  // User Statistics Service (después de LactationService, pero obtiene LactationService de forma lazy)
  getIt.registerLazySingleton<UserStatisticsService>(
    () => UserStatisticsService(
      lessonRepository: getIt<LessonRepositoryImpl>(),
      weightDataSource: getIt<BabyWeightOfflineLocalDataSource>(),
      sleepDataSource: getIt<SleepOfflineLocalDataSource>(),
      gamificationRepository: getIt<GamificationRepository>(),
    ),
  );

  // Actualizar LactationService para incluir UserStatisticsService
  getIt.unregister<LactationService>();
  getIt.registerLazySingleton<LactationService>(
    () => LactationService(
      getIt<FirebaseFirestore>(),
      getIt<FirebaseAuth>(),
      getIt<UserStatisticsService>(),
    ),
  );
  getIt.registerLazySingleton<LactationFlowService>(
    () => LactationFlowService(
      getIt<FirebaseFirestore>(),
      getIt<FirebaseAuth>(),
      getIt<AppLogger>(),
    ),
  );
  getIt.registerLazySingleton<SleepNotificationService>(
    () => SleepNotificationService(),
  );
  getIt.registerLazySingleton<OfflineSessionService>(
    () => OfflineSessionService(),
  );
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());

  // Growth Tracking Data Sources (deben registrarse antes de UserStatisticsService)
  getIt.registerLazySingleton<BabyWeightOfflineLocalDataSource>(
    () => BabyWeightOfflineLocalDataSource(),
  );
  getIt.registerLazySingleton<SleepOfflineLocalDataSource>(
    () => SleepOfflineLocalDataSource(),
  );

  // Settings Services
  getIt.registerLazySingleton<LocalizationService>(
    () => LocalizationService(getIt<SharedPreferences>()),
  );
  // AppLogger debe registrarse antes de servicios que lo usan
  getIt.registerLazySingleton<AppLogger>(
    () => AppLogger(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<SoundService>(
    () => SoundService(getIt<SharedPreferences>(), getIt<AppLogger>()),
  );
  getIt.registerLazySingleton<VibrationService>(
    () => VibrationService(getIt<SharedPreferences>(), getIt<AppLogger>()),
  );
  getIt.registerLazySingleton<AutoSaveService>(
    () => AutoSaveService(
      getIt<SharedPreferences>(),
      getIt<FirebaseFirestore>(),
      getIt<FirebaseAuth>(),
    ),
  );

  // Video offline services
  getIt.registerLazySingleton<VideoEncryptionService>(
    () => VideoEncryptionService(),
  );
  getIt.registerLazySingleton<VideoDownloadService>(
    () => VideoDownloadService(),
  );
  getIt.registerLazySingleton<VideoOfflineLocalDataSource>(
    () => VideoOfflineLocalDataSource(),
  );

  // Offline sync services
  getIt.registerLazySingleton<SyncQueueService>(() => SyncQueueService());
  getIt.registerLazySingleton<OfflineSyncService>(() => OfflineSyncService());
  getIt.registerLazySingleton<ConflictResolutionService>(
    () => ConflictResolutionService(),
  );

  // User profile offline
  getIt.registerLazySingleton<UserProfileOfflineLocalDataSource>(
    () => UserProfileOfflineLocalDataSource(),
  );

  // Gamification Service (después de GamificationRepository)
  getIt.registerLazySingleton<GamificationService>(
    () => GamificationService(repository: getIt<GamificationRepository>()),
  );

  // Daily Challenge Service
  getIt.registerLazySingleton<DailyChallengeService>(
    () => DailyChallengeService(
      getIt<LactationService>(),
      getIt<LessonRepositoryImpl>(),
      getIt<BabyWeightOfflineLocalDataSource>(),
      getIt<SleepOfflineLocalDataSource>(),
      getIt<GamificationService>(),
    ),
  );

  // Providers
  getIt.registerFactory<LactationProvider>(
    () => LactationProvider(getIt<LactationService>()),
  );
  getIt.registerFactory<LactationFlowProvider>(
    () => LactationFlowProvider(getIt<LactationFlowService>()),
  );

  // Data Sources
  getIt.registerLazySingleton<UILocalDataSource>(
    () => UILocalDataSourceImpl(sharedPreferences: getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      getIt<FirebaseAuth>(),
      getIt<FirebaseFirestore>(),
    ),
  );
  getIt.registerLazySingleton<VideoRemoteDataSource>(
    () => VideoRemoteDataSourceImpl(getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<TipRemoteDataSource>(
    () => TipRemoteDataSourceImpl(getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<UserProfileRemoteDataSource>(
    () => UserProfileRemoteDataSourceImpl(
      firestore: getIt<FirebaseFirestore>(),
      firebaseAuth: getIt<FirebaseAuth>(),
    ),
  );
  getIt.registerLazySingleton<ChatbotRemoteDataSource>(
    () => ChatbotRemoteDataSourceImpl(getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<SettingsRemoteDataSource>(
    () => SettingsRemoteDataSourceImpl(firestore: getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSource(getIt<SharedPreferences>()),
  );

  // Repositories
  getIt.registerLazySingleton<UIRepositoryImpl>(
    () => UIRepositoryImpl(getIt<UILocalDataSource>()),
  );
  getIt.registerLazySingleton<AuthRepositoryImpl>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );
  getIt.registerLazySingleton<VideoRepositoryImpl>(
    () => VideoRepositoryImpl(getIt<VideoRemoteDataSource>()),
  );
  getIt.registerLazySingleton<TipRepositoryImpl>(
    () => TipRepositoryImpl(getIt<TipRemoteDataSource>()),
  );
  getIt.registerLazySingleton<UserProfileRepositoryImpl>(
    () => UserProfileRepositoryImpl(getIt<UserProfileRemoteDataSource>()),
  );
  getIt.registerLazySingleton<LessonRepositoryImpl>(
    () => LessonRepositoryImpl(),
  );
  getIt.registerLazySingleton<ChatbotRepositoryImpl>(
    () => ChatbotRepositoryImpl(getIt<ChatbotRemoteDataSource>()),
  );
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      remoteDataSource: getIt<SettingsRemoteDataSource>(),
      localDataSource: getIt<SettingsLocalDataSource>(),
    ),
  );

  // Use Cases - UI
  getIt.registerLazySingleton(
    () => ui_usecases.GetSplashPagesUseCase(getIt<UIRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => ui_usecases.GetLessonProgressStateUseCase(getIt<UIRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => ui_usecases.UpdateLessonProgressUseCase(getIt<UIRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => ui_usecases.UpdateVideoProgressUseCase(getIt<UIRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => ui_usecases.MarkVideoAsWatchedUseCase(getIt<UIRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () =>
        ui_usecases.UpdateCompletedVideosListUseCase(getIt<UIRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () =>
        ui_usecases.UpdateLastCompletedLessonUseCase(getIt<UIRepositoryImpl>()),
  );

  // Use Cases - Auth
  getIt.registerLazySingleton(
    () => auth_usecases.SignInUseCase(getIt<AuthRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => auth_usecases.SignUpUseCase(getIt<AuthRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => auth_usecases.SignOutUseCase(getIt<AuthRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => auth_usecases.GetCurrentUserUseCase(getIt<AuthRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => auth_usecases.ResetPasswordUseCase(getIt<AuthRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () =>
        auth_usecases.SendEmailVerificationUseCase(getIt<AuthRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => auth_usecases.UpdateProfileUseCase(getIt<AuthRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => auth_usecases.DeleteAccountUseCase(getIt<AuthRepositoryImpl>()),
  );

  // Use Cases - Videos
  getIt.registerLazySingleton(
    () => video_usecases.GetAllVideosUseCase(getIt<VideoRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => video_usecases.GetVideoByIdUseCase(getIt<VideoRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () =>
        video_usecases.GetVideosByLessonIdUseCase(getIt<VideoRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => video_usecases.SearchVideosUseCase(getIt<VideoRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => video_usecases.MarkVideoAsCompletedUseCase(
      getIt<VideoRepositoryImpl>(),
    ),
  );
  getIt.registerLazySingleton(
    () => video_usecases.GetCompletedVideoIdsUseCase(
      getIt<VideoRepositoryImpl>(),
    ),
  );
  getIt.registerLazySingleton(
    () =>
        video_usecases.UpdateVideoProgressUseCase(getIt<VideoRepositoryImpl>()),
  );

  // Use Cases - Tips
  getIt.registerLazySingleton(
    () => tip_usecases.GetAllTipsUseCase(getIt<TipRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => tip_usecases.GetTipByIdUseCase(getIt<TipRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => tip_usecases.GetTipsByCategoryUseCase(getIt<TipRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => tip_usecases.SearchTipsUseCase(getIt<TipRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => tip_usecases.MarkTipAsFavoriteUseCase(getIt<TipRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => tip_usecases.UnmarkTipAsFavoriteUseCase(getIt<TipRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => tip_usecases.GetFavoriteTipsUseCase(getIt<TipRepositoryImpl>()),
  );

  // Use Cases - User Profile
  getIt.registerLazySingleton(
    () =>
        user_usecases.GetUserProfileUseCase(getIt<UserProfileRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => user_usecases.UpdateUserProfileUseCase(
      getIt<UserProfileRepositoryImpl>(),
    ),
  );
  getIt.registerLazySingleton(
    () => user_usecases.SignOutUseCase(getIt<UserProfileRepositoryImpl>()),
  );

  // Use Cases - Lessons
  getIt.registerLazySingleton(
    () => lesson_usecases.GetAllLessonsUseCase(getIt<LessonRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => lesson_usecases.GetLessonByIdUseCase(getIt<LessonRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => lesson_usecases.GetLessonsByCategoryUseCase(
      getIt<LessonRepositoryImpl>(),
    ),
  );
  getIt.registerLazySingleton(
    () => lesson_usecases.SearchLessonsUseCase(getIt<LessonRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => lesson_usecases.MarkLessonAsCompletedUseCase(
      getIt<LessonRepositoryImpl>(),
    ),
  );
  getIt.registerLazySingleton(
    () =>
        lesson_usecases.GetLessonProgressUseCase(getIt<LessonRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () => lesson_usecases.GetUserProgressUseCase(getIt<LessonRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
    () =>
        lesson_usecases.GetUserStatisticsUseCase(getIt<LessonRepositoryImpl>()),
  );

  // Use Cases - Chatbot
  getIt.registerLazySingleton(
    () => chatbot_usecases.SendMessageUseCase(getIt<ChatbotRepositoryImpl>()),
  );

  // Use Cases - Settings
  getIt.registerLazySingleton(
    () => settings_usecases.GetAppConfigurationUseCase(
      getIt<SettingsRepository>(),
    ),
  );
  getIt.registerLazySingleton(
    () => settings_usecases.UpdateAppConfigurationUseCase(
      getIt<SettingsRepository>(),
    ),
  );
  getIt.registerLazySingleton(
    () =>
        settings_usecases.GetUserStatisticsUseCase(getIt<SettingsRepository>()),
  );
  getIt.registerLazySingleton(
    () => settings_usecases.UpdateUserStatisticsUseCase(
      getIt<SettingsRepository>(),
    ),
  );
  getIt.registerLazySingleton(
    () => settings_usecases.SubmitFeedbackUseCase(getIt<SettingsRepository>()),
  );
  getIt.registerLazySingleton(
    () =>
        settings_usecases.GetLocalSettingsUseCase(getIt<SettingsRepository>()),
  );
  getIt.registerLazySingleton(
    () => settings_usecases.UpdateLocalSettingUseCase(
      getIt<SettingsRepository>(),
    ),
  );
  getIt.registerLazySingleton(
    () => settings_usecases.UpdateLocalSettingsUseCase(
      getIt<SettingsRepository>(),
    ),
  );

  // BLoCs - Solo los básicos necesarios para que funcione la app
  getIt.registerFactory(
    () => UIBloc(
      getSplashPagesUseCase: getIt<ui_usecases.GetSplashPagesUseCase>(),
      getLessonProgressStateUseCase:
          getIt<ui_usecases.GetLessonProgressStateUseCase>(),
      updateLessonProgressUseCase:
          getIt<ui_usecases.UpdateLessonProgressUseCase>(),
      updateVideoProgressUseCase:
          getIt<ui_usecases.UpdateVideoProgressUseCase>(),
      markVideoAsWatchedUseCase: getIt<ui_usecases.MarkVideoAsWatchedUseCase>(),
      updateCompletedVideosListUseCase:
          getIt<ui_usecases.UpdateCompletedVideosListUseCase>(),
      updateLastCompletedLessonUseCase:
          getIt<ui_usecases.UpdateLastCompletedLessonUseCase>(),
    ),
  );

  getIt.registerFactory(
    () => AuthBloc(
      signInUseCase: getIt<auth_usecases.SignInUseCase>(),
      signUpUseCase: getIt<auth_usecases.SignUpUseCase>(),
      signOutUseCase: getIt<auth_usecases.SignOutUseCase>(),
      getCurrentUserUseCase: getIt<auth_usecases.GetCurrentUserUseCase>(),
      resetPasswordUseCase: getIt<auth_usecases.ResetPasswordUseCase>(),
      sendEmailVerificationUseCase:
          getIt<auth_usecases.SendEmailVerificationUseCase>(),
      updateProfileUseCase: getIt<auth_usecases.UpdateProfileUseCase>(),
      deleteAccountUseCase: getIt<auth_usecases.DeleteAccountUseCase>(),
      offlineSessionService: getIt<OfflineSessionService>(),
      connectivityService: getIt<ConnectivityService>(),
    ),
  );

  getIt.registerFactory(
    () => VideoBloc(
      getAllVideosUseCase: getIt<video_usecases.GetAllVideosUseCase>(),
      getVideoByIdUseCase: getIt<video_usecases.GetVideoByIdUseCase>(),
      getVideosByLessonIdUseCase:
          getIt<video_usecases.GetVideosByLessonIdUseCase>(),
      searchVideosUseCase: getIt<video_usecases.SearchVideosUseCase>(),
      markVideoAsCompletedUseCase:
          getIt<video_usecases.MarkVideoAsCompletedUseCase>(),
      getCompletedVideoIdsUseCase:
          getIt<video_usecases.GetCompletedVideoIdsUseCase>(),
      updateVideoProgressUseCase:
          getIt<video_usecases.UpdateVideoProgressUseCase>(),
    ),
  );

  getIt.registerFactory(
    () => VideoDownloadBloc(
      downloadService: getIt<VideoDownloadService>(),
      localDataSource: getIt<VideoOfflineLocalDataSource>(),
    ),
  );

  getIt.registerFactory(
    () => TipBloc(
      getAllTipsUseCase: getIt<tip_usecases.GetAllTipsUseCase>(),
      getTipByIdUseCase: getIt<tip_usecases.GetTipByIdUseCase>(),
      getTipsByCategoryUseCase: getIt<tip_usecases.GetTipsByCategoryUseCase>(),
      searchTipsUseCase: getIt<tip_usecases.SearchTipsUseCase>(),
      markTipAsFavoriteUseCase: getIt<tip_usecases.MarkTipAsFavoriteUseCase>(),
      unmarkTipAsFavoriteUseCase:
          getIt<tip_usecases.UnmarkTipAsFavoriteUseCase>(),
      getFavoriteTipsUseCase: getIt<tip_usecases.GetFavoriteTipsUseCase>(),
    ),
  );

  getIt.registerFactory(
    () => UserProfileBloc(
      getUserProfileUseCase: getIt<user_usecases.GetUserProfileUseCase>(),
      updateUserProfileUseCase: getIt<user_usecases.UpdateUserProfileUseCase>(),
      signOutUseCase: getIt<user_usecases.SignOutUseCase>(),
    ),
  );

  getIt.registerFactory(
    () => LessonBloc(
      getAllLessonsUseCase: getIt<lesson_usecases.GetAllLessonsUseCase>(),
      getLessonByIdUseCase: getIt<lesson_usecases.GetLessonByIdUseCase>(),
      getLessonsByCategoryUseCase:
          getIt<lesson_usecases.GetLessonsByCategoryUseCase>(),
      searchLessonsUseCase: getIt<lesson_usecases.SearchLessonsUseCase>(),
      markLessonAsCompletedUseCase:
          getIt<lesson_usecases.MarkLessonAsCompletedUseCase>(),
      getLessonProgressUseCase:
          getIt<lesson_usecases.GetLessonProgressUseCase>(),
      getUserProgressUseCase: getIt<lesson_usecases.GetUserProgressUseCase>(),
      getUserStatisticsUseCase:
          getIt<lesson_usecases.GetUserStatisticsUseCase>(),
    ),
  );

  getIt.registerFactory(
    () => ChatbotBloc(
      sendMessageUseCase: getIt<chatbot_usecases.SendMessageUseCase>(),
    ),
  );

  getIt.registerFactory(
    () => GamificationBloc(repository: getIt<GamificationRepository>()),
  );

  getIt.registerFactory(
    () => SettingsBloc(
      getAppConfigurationUseCase:
          getIt<settings_usecases.GetAppConfigurationUseCase>(),
      updateAppConfigurationUseCase:
          getIt<settings_usecases.UpdateAppConfigurationUseCase>(),
      getUserStatisticsUseCase:
          getIt<settings_usecases.GetUserStatisticsUseCase>(),
      updateUserStatisticsUseCase:
          getIt<settings_usecases.UpdateUserStatisticsUseCase>(),
      submitFeedbackUseCase: getIt<settings_usecases.SubmitFeedbackUseCase>(),
      getLocalSettingsUseCase:
          getIt<settings_usecases.GetLocalSettingsUseCase>(),
      updateLocalSettingUseCase:
          getIt<settings_usecases.UpdateLocalSettingUseCase>(),
      updateLocalSettingsUseCase:
          getIt<settings_usecases.UpdateLocalSettingsUseCase>(),
    ),
  );
}

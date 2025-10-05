import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/settings_entities.dart';
import '../../domain/usecases/settings_usecases.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetAppConfigurationUseCase _getAppConfigurationUseCase;
  final UpdateAppConfigurationUseCase _updateAppConfigurationUseCase;
  final GetUserStatisticsUseCase _getUserStatisticsUseCase;
  final UpdateUserStatisticsUseCase _updateUserStatisticsUseCase;
  final SubmitFeedbackUseCase _submitFeedbackUseCase;

  SettingsBloc({
    required GetAppConfigurationUseCase getAppConfigurationUseCase,
    required UpdateAppConfigurationUseCase updateAppConfigurationUseCase,
    required GetUserStatisticsUseCase getUserStatisticsUseCase,
    required UpdateUserStatisticsUseCase updateUserStatisticsUseCase,
    required SubmitFeedbackUseCase submitFeedbackUseCase,
  }) : _getAppConfigurationUseCase = getAppConfigurationUseCase,
       _updateAppConfigurationUseCase = updateAppConfigurationUseCase,
       _getUserStatisticsUseCase = getUserStatisticsUseCase,
       _updateUserStatisticsUseCase = updateUserStatisticsUseCase,
       _submitFeedbackUseCase = submitFeedbackUseCase,
       super(SettingsInitial()) {
    on<GetAppConfigurationRequested>(_onGetAppConfigurationRequested);
    on<UpdateAppConfigurationRequested>(_onUpdateAppConfigurationRequested);
    on<GetUserStatisticsRequested>(_onGetUserStatisticsRequested);
    on<UpdateUserStatisticsRequested>(_onUpdateUserStatisticsRequested);
    on<SaveFeedbackMessageRequested>(_onSaveFeedbackMessageRequested);
  }

  Future<void> _onGetAppConfigurationRequested(
    GetAppConfigurationRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());

    final result = await _getAppConfigurationUseCase(
      GetAppConfigurationParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(SettingsFailure(failure.message)),
      (configuration) => emit(AppConfigurationLoaded(configuration)),
    );
  }

  Future<void> _onUpdateAppConfigurationRequested(
    UpdateAppConfigurationRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());

    // Crear un AppConfiguration con los datos del evento
    final configuration = AppConfiguration(
      id: event.userId,
      userId: event.userId,
      notificationsEnabled: event.updates['notificationsEnabled'] ?? true,
      analyticsEnabled: event.updates['analyticsEnabled'] ?? true,
      crashReportingEnabled: event.updates['crashReportingEnabled'] ?? true,
      language: event.updates['language'] ?? 'es',
      theme: event.updates['theme'] ?? 'light',
      autoSaveProgress: event.updates['autoSaveProgress'] ?? true,
      showTips: event.updates['showTips'] ?? true,
      darkMode: event.updates['darkMode'] ?? false,
      fontSize: event.updates['fontSize'] ?? 14.0,
      soundEnabled: event.updates['soundEnabled'] ?? true,
      vibrationEnabled: event.updates['vibrationEnabled'] ?? true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await _updateAppConfigurationUseCase(
      UpdateAppConfigurationParams(configuration: configuration),
    );

    result.fold(
      (failure) => emit(SettingsFailure(failure.message)),
      (_) => emit(AppConfigurationUpdated()),
    );
  }

  Future<void> _onGetUserStatisticsRequested(
    GetUserStatisticsRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());

    final result = await _getUserStatisticsUseCase(
      GetUserStatisticsParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(SettingsFailure(failure.message)),
      (statistics) => emit(UserStatisticsLoaded(statistics)),
    );
  }

  Future<void> _onUpdateUserStatisticsRequested(
    UpdateUserStatisticsRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());

    // Crear un UserStatistics con los datos del evento
    final statistics = UserStatistics(
      id: event.userId,
      userId: event.userId,
      totalVideosWatched: event.updates['totalVideosWatched'] ?? 0,
      totalLessonsCompleted: event.updates['totalLessonsCompleted'] ?? 0,
      totalContentCompleted: event.updates['totalContentCompleted'] ?? 0,
      totalTimeSpent: event.updates['totalTimeSpent'] ?? 0,
      averageSessionTime: event.updates['averageSessionTime'] ?? 0.0,
      totalSessions: event.updates['totalSessions'] ?? 0,
      videosWatchedByCategory: event.updates['videosWatchedByCategory'] ?? {},
      contentCompletedByCategory:
          event.updates['contentCompletedByCategory'] ?? {},
      lastActivity: DateTime.now(),
      firstActivity: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await _updateUserStatisticsUseCase(
      UpdateUserStatisticsParams(statistics: statistics),
    );

    result.fold(
      (failure) => emit(SettingsFailure(failure.message)),
      (_) => emit(UserStatisticsUpdated()),
    );
  }

  Future<void> _onSaveFeedbackMessageRequested(
    SaveFeedbackMessageRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());

    final result = await _submitFeedbackUseCase(
      SubmitFeedbackParams(feedback: event.message),
    );

    result.fold(
      (failure) => emit(SettingsFailure(failure.message)),
      (_) => emit(FeedbackMessageSaved()),
    );
  }
}

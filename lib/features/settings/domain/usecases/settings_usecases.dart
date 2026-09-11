import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/settings_entities.dart';
import '../repositories/settings_repository.dart';

// Casos de uso para configuración
@injectable
class GetAppConfigurationUseCase
    implements UseCase<AppConfiguration, GetAppConfigurationParams> {
  final SettingsRepository repository;

  GetAppConfigurationUseCase(this.repository);

  @override
  Future<Either<Failure, AppConfiguration>> call(
    GetAppConfigurationParams params,
  ) async {
    return await repository.getAppConfiguration(params.userId);
  }
}

@injectable
class UpdateAppConfigurationUseCase
    implements UseCase<void, UpdateAppConfigurationParams> {
  final SettingsRepository repository;

  UpdateAppConfigurationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateAppConfigurationParams params) async {
    return await repository.updateAppConfiguration(params.configuration);
  }
}

@injectable
class ResetAppConfigurationUseCase
    implements UseCase<void, ResetAppConfigurationParams> {
  final SettingsRepository repository;

  ResetAppConfigurationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ResetAppConfigurationParams params) async {
    return await repository.resetAppConfiguration(params.userId);
  }
}

// Casos de uso para estadísticas
@injectable
class GetUserStatisticsUseCase
    implements UseCase<UserStatistics, GetUserStatisticsParams> {
  final SettingsRepository repository;

  GetUserStatisticsUseCase(this.repository);

  @override
  Future<Either<Failure, UserStatistics>> call(
    GetUserStatisticsParams params,
  ) async {
    return await repository.getUserStatistics(params.userId);
  }
}

@injectable
class UpdateUserStatisticsUseCase
    implements UseCase<void, UpdateUserStatisticsParams> {
  final SettingsRepository repository;

  UpdateUserStatisticsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateUserStatisticsParams params) async {
    return await repository.updateUserStatistics(params.statistics);
  }
}

@injectable
class GetVideoViewsChartDataUseCase
    implements UseCase<List<ChartData>, GetVideoViewsChartDataParams> {
  final SettingsRepository repository;

  GetVideoViewsChartDataUseCase(this.repository);

  @override
  Future<Either<Failure, List<ChartData>>> call(
    GetVideoViewsChartDataParams params,
  ) async {
    return await repository.getVideoViewsChartData(params.userId);
  }
}

@injectable
class GetContentCompletionChartDataUseCase
    implements UseCase<List<ChartData>, GetContentCompletionChartDataParams> {
  final SettingsRepository repository;

  GetContentCompletionChartDataUseCase(this.repository);

  @override
  Future<Either<Failure, List<ChartData>>> call(
    GetContentCompletionChartDataParams params,
  ) async {
    return await repository.getContentCompletionChartData(params.userId);
  }
}

@injectable
class GetOverallProgressUseCase
    implements UseCase<Map<String, dynamic>, GetOverallProgressParams> {
  final SettingsRepository repository;

  GetOverallProgressUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    GetOverallProgressParams params,
  ) async {
    return await repository.getOverallProgress(params.userId);
  }
}

// Casos de uso para feedback
@injectable
class SubmitFeedbackUseCase implements UseCase<void, SubmitFeedbackParams> {
  final SettingsRepository repository;

  SubmitFeedbackUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SubmitFeedbackParams params) async {
    return await repository.submitFeedback(params.feedback);
  }
}

@injectable
class GetUserFeedbackUseCase
    implements UseCase<List<FeedbackMessage>, GetUserFeedbackParams> {
  final SettingsRepository repository;

  GetUserFeedbackUseCase(this.repository);

  @override
  Future<Either<Failure, List<FeedbackMessage>>> call(
    GetUserFeedbackParams params,
  ) async {
    return await repository.getUserFeedback(params.userId);
  }
}

@injectable
class UpdateFeedbackStatusUseCase
    implements UseCase<void, UpdateFeedbackStatusParams> {
  final SettingsRepository repository;

  UpdateFeedbackStatusUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateFeedbackStatusParams params) async {
    return await repository.updateFeedbackStatus(params.feedbackId, params.status);
  }
}

// Parámetros para los casos de uso
class GetAppConfigurationParams {
  final String userId;

  GetAppConfigurationParams({required this.userId});
}

class UpdateAppConfigurationParams {
  final AppConfiguration configuration;

  UpdateAppConfigurationParams({required this.configuration});
}

class ResetAppConfigurationParams {
  final String userId;

  ResetAppConfigurationParams({required this.userId});
}

class GetUserStatisticsParams {
  final String userId;

  GetUserStatisticsParams({required this.userId});
}

class UpdateUserStatisticsParams {
  final UserStatistics statistics;

  UpdateUserStatisticsParams({required this.statistics});
}

class GetVideoViewsChartDataParams {
  final String userId;

  GetVideoViewsChartDataParams({required this.userId});
}

class GetContentCompletionChartDataParams {
  final String userId;

  GetContentCompletionChartDataParams({required this.userId});
}

class GetOverallProgressParams {
  final String userId;

  GetOverallProgressParams({required this.userId});
}

class SubmitFeedbackParams {
  final FeedbackMessage feedback;

  SubmitFeedbackParams({required this.feedback});
}

class GetUserFeedbackParams {
  final String userId;

  GetUserFeedbackParams({required this.userId});
}

class UpdateFeedbackStatusParams {
  final String feedbackId;
  final String status;

  UpdateFeedbackStatusParams({
    required this.feedbackId,
    required this.status,
  });
}

// Casos de uso para configuraciones locales
@injectable
class GetLocalSettingsUseCase
    implements UseCase<Map<String, dynamic>, NoParams> {
  final SettingsRepository repository;

  GetLocalSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(NoParams params) async {
    return await repository.getLocalSettings();
  }
}

@injectable
class UpdateLocalSettingUseCase
    implements UseCase<void, UpdateLocalSettingParams> {
  final SettingsRepository repository;

  UpdateLocalSettingUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateLocalSettingParams params) async {
    return await repository.updateLocalSetting(params.key, params.value);
  }
}

@injectable
class UpdateLocalSettingsUseCase
    implements UseCase<void, UpdateLocalSettingsParams> {
  final SettingsRepository repository;

  UpdateLocalSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateLocalSettingsParams params) async {
    return await repository.updateLocalSettings(params.settings);
  }
}

class UpdateLocalSettingParams {
  final String key;
  final dynamic value;

  UpdateLocalSettingParams({required this.key, required this.value});
}

class UpdateLocalSettingsParams {
  final Map<String, dynamic> settings;

  UpdateLocalSettingsParams({required this.settings});
}
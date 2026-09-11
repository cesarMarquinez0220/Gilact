part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

// Eventos de configuración de la aplicación
class GetAppConfigurationRequested extends SettingsEvent {
  final String userId;

  const GetAppConfigurationRequested({required this.userId});

  @override
  List<Object> get props => [userId];
}

class SaveAppConfigurationRequested extends SettingsEvent {
  final AppConfiguration configuration;

  const SaveAppConfigurationRequested({required this.configuration});

  @override
  List<Object> get props => [configuration];
}

class UpdateAppConfigurationRequested extends SettingsEvent {
  final String userId;
  final Map<String, dynamic> updates;

  const UpdateAppConfigurationRequested({
    required this.userId,
    required this.updates,
  });

  @override
  List<Object> get props => [userId, updates];
}

class DeleteAppConfigurationRequested extends SettingsEvent {
  final String userId;

  const DeleteAppConfigurationRequested({required this.userId});

  @override
  List<Object> get props => [userId];
}

// Eventos de estadísticas del usuario
class GetUserStatisticsRequested extends SettingsEvent {
  final String userId;

  const GetUserStatisticsRequested({required this.userId});

  @override
  List<Object> get props => [userId];
}

class SaveUserStatisticsRequested extends SettingsEvent {
  final UserStatistics statistics;

  const SaveUserStatisticsRequested({required this.statistics});

  @override
  List<Object> get props => [statistics];
}

class UpdateUserStatisticsRequested extends SettingsEvent {
  final String userId;
  final Map<String, dynamic> updates;

  const UpdateUserStatisticsRequested({
    required this.userId,
    required this.updates,
  });

  @override
  List<Object> get props => [userId, updates];
}

class IncrementUserStatisticsRequested extends SettingsEvent {
  final String userId;
  final Map<String, dynamic> increments;

  const IncrementUserStatisticsRequested({
    required this.userId,
    required this.increments,
  });

  @override
  List<Object> get props => [userId, increments];
}

class DeleteUserStatisticsRequested extends SettingsEvent {
  final String userId;

  const DeleteUserStatisticsRequested({required this.userId});

  @override
  List<Object> get props => [userId];
}

// Eventos de mensajes de feedback
class GetUserFeedbackMessagesRequested extends SettingsEvent {
  final String userId;

  const GetUserFeedbackMessagesRequested({required this.userId});

  @override
  List<Object> get props => [userId];
}

class GetFeedbackMessageByIdRequested extends SettingsEvent {
  final String messageId;

  const GetFeedbackMessageByIdRequested({required this.messageId});

  @override
  List<Object> get props => [messageId];
}

class SaveFeedbackMessageRequested extends SettingsEvent {
  final FeedbackMessage message;

  const SaveFeedbackMessageRequested({required this.message});

  @override
  List<Object> get props => [message];
}

class UpdateFeedbackMessageRequested extends SettingsEvent {
  final String messageId;
  final Map<String, dynamic> updates;

  const UpdateFeedbackMessageRequested({
    required this.messageId,
    required this.updates,
  });

  @override
  List<Object> get props => [messageId, updates];
}

class DeleteFeedbackMessageRequested extends SettingsEvent {
  final String messageId;

  const DeleteFeedbackMessageRequested({required this.messageId});

  @override
  List<Object> get props => [messageId];
}

// Eventos de utilidad
class CheckIfConfigurationExistsRequested extends SettingsEvent {
  final String userId;

  const CheckIfConfigurationExistsRequested({required this.userId});

  @override
  List<Object> get props => [userId];
}

class CheckIfStatisticsExistRequested extends SettingsEvent {
  final String userId;

  const CheckIfStatisticsExistRequested({required this.userId});

  @override
  List<Object> get props => [userId];
}

class GetFeedbackMessageCountRequested extends SettingsEvent {
  final String userId;

  const GetFeedbackMessageCountRequested({required this.userId});

  @override
  List<Object> get props => [userId];
}

// Eventos de configuración local
class GetLocalSettingsRequested extends SettingsEvent {
  const GetLocalSettingsRequested();
}

class UpdateLocalSettingRequested extends SettingsEvent {
  final String key;
  final dynamic value;

  const UpdateLocalSettingRequested({
    required this.key,
    required this.value,
  });

  @override
  List<Object> get props => [key, value];
}

class UpdateLocalSettingsRequested extends SettingsEvent {
  final Map<String, dynamic> settings;

  const UpdateLocalSettingsRequested({required this.settings});

  @override
  List<Object> get props => [settings];
}
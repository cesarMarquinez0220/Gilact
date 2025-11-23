part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

// Estados básicos
class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsFailure extends SettingsState {
  final String message;

  const SettingsFailure(this.message);

  @override
  List<Object> get props => [message];
}

// Estados de configuración de la aplicación
class AppConfigurationLoaded extends SettingsState {
  final AppConfiguration configuration;

  const AppConfigurationLoaded(this.configuration);

  @override
  List<Object> get props => [configuration];
}

class AppConfigurationSaved extends SettingsState {
  const AppConfigurationSaved();
}

class AppConfigurationUpdated extends SettingsState {
  const AppConfigurationUpdated();
}

class AppConfigurationDeleted extends SettingsState {
  const AppConfigurationDeleted();
}

// Estados de estadísticas del usuario
class UserStatisticsLoaded extends SettingsState {
  final UserStatistics statistics;

  const UserStatisticsLoaded(this.statistics);

  @override
  List<Object> get props => [statistics];
}

class UserStatisticsSaved extends SettingsState {
  const UserStatisticsSaved();
}

class UserStatisticsUpdated extends SettingsState {
  const UserStatisticsUpdated();
}

class UserStatisticsIncremented extends SettingsState {
  const UserStatisticsIncremented();
}

class UserStatisticsDeleted extends SettingsState {
  const UserStatisticsDeleted();
}

// Estados de mensajes de feedback
class FeedbackMessagesLoaded extends SettingsState {
  final List<FeedbackMessage> messages;

  const FeedbackMessagesLoaded(this.messages);

  @override
  List<Object> get props => [messages];
}

class FeedbackMessageLoaded extends SettingsState {
  final FeedbackMessage message;

  const FeedbackMessageLoaded(this.message);

  @override
  List<Object> get props => [message];
}

class FeedbackMessageSaved extends SettingsState {
  const FeedbackMessageSaved();
}

class FeedbackMessageUpdated extends SettingsState {
  const FeedbackMessageUpdated();
}

class FeedbackMessageDeleted extends SettingsState {
  const FeedbackMessageDeleted();
}

// Estados de utilidad
class ConfigurationExistsChecked extends SettingsState {
  final bool exists;

  const ConfigurationExistsChecked(this.exists);

  @override
  List<Object> get props => [exists];
}

class StatisticsExistChecked extends SettingsState {
  final bool exists;

  const StatisticsExistChecked(this.exists);

  @override
  List<Object> get props => [exists];
}

class FeedbackMessageCountLoaded extends SettingsState {
  final int count;

  const FeedbackMessageCountLoaded(this.count);

  @override
  List<Object> get props => [count];
}

// Estados de configuración local
class LocalSettingsLoaded extends SettingsState {
  final Map<String, dynamic> settings;

  const LocalSettingsLoaded(this.settings);

  @override
  List<Object> get props => [settings];
}

class LocalSettingUpdated extends SettingsState {
  const LocalSettingUpdated();
}

class LocalSettingsUpdated extends SettingsState {
  const LocalSettingsUpdated();
}
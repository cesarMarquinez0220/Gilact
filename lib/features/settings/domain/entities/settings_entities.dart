import 'package:equatable/equatable.dart';

class AppConfiguration extends Equatable {
  final String id;
  final String userId;
  final bool notificationsEnabled;
  final bool analyticsEnabled;
  final bool crashReportingEnabled;
  final String language;
  final String theme;
  final bool autoSaveProgress;
  final bool showTips;
  final bool darkMode;
  final String fontSize;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppConfiguration({
    required this.id,
    required this.userId,
    required this.notificationsEnabled,
    required this.analyticsEnabled,
    required this.crashReportingEnabled,
    required this.language,
    required this.theme,
    required this.autoSaveProgress,
    required this.showTips,
    required this.darkMode,
    required this.fontSize,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        notificationsEnabled,
        analyticsEnabled,
        crashReportingEnabled,
        language,
        theme,
        autoSaveProgress,
        showTips,
        darkMode,
        fontSize,
        soundEnabled,
        vibrationEnabled,
        createdAt,
        updatedAt,
      ];

  AppConfiguration copyWith({
    String? id,
    String? userId,
    bool? notificationsEnabled,
    bool? analyticsEnabled,
    bool? crashReportingEnabled,
    String? language,
    String? theme,
    bool? autoSaveProgress,
    bool? showTips,
    bool? darkMode,
    String? fontSize,
    bool? soundEnabled,
    bool? vibrationEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppConfiguration(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      crashReportingEnabled: crashReportingEnabled ?? this.crashReportingEnabled,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      autoSaveProgress: autoSaveProgress ?? this.autoSaveProgress,
      showTips: showTips ?? this.showTips,
      darkMode: darkMode ?? this.darkMode,
      fontSize: fontSize ?? this.fontSize,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UserStatistics extends Equatable {
  final String id;
  final String userId;
  final int totalVideosWatched;
  final int totalLessonsCompleted;
  final int totalContentCompleted;
  final int totalTimeSpent; // en segundos
  final double averageSessionTime;
  final int totalSessions;
  final Map<String, int> videosWatchedByCategory;
  final Map<String, int> contentCompletedByCategory;
  final DateTime lastActivity;
  final DateTime firstActivity;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserStatistics({
    required this.id,
    required this.userId,
    required this.totalVideosWatched,
    required this.totalLessonsCompleted,
    required this.totalContentCompleted,
    required this.totalTimeSpent,
    required this.averageSessionTime,
    required this.totalSessions,
    required this.videosWatchedByCategory,
    required this.contentCompletedByCategory,
    required this.lastActivity,
    required this.firstActivity,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        totalVideosWatched,
        totalLessonsCompleted,
        totalContentCompleted,
        totalTimeSpent,
        averageSessionTime,
        totalSessions,
        videosWatchedByCategory,
        contentCompletedByCategory,
        lastActivity,
        firstActivity,
        createdAt,
        updatedAt,
      ];

  UserStatistics copyWith({
    String? id,
    String? userId,
    int? totalVideosWatched,
    int? totalLessonsCompleted,
    int? totalContentCompleted,
    int? totalTimeSpent,
    double? averageSessionTime,
    int? totalSessions,
    Map<String, int>? videosWatchedByCategory,
    Map<String, int>? contentCompletedByCategory,
    DateTime? lastActivity,
    DateTime? firstActivity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserStatistics(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      totalVideosWatched: totalVideosWatched ?? this.totalVideosWatched,
      totalLessonsCompleted: totalLessonsCompleted ?? this.totalLessonsCompleted,
      totalContentCompleted: totalContentCompleted ?? this.totalContentCompleted,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      averageSessionTime: averageSessionTime ?? this.averageSessionTime,
      totalSessions: totalSessions ?? this.totalSessions,
      videosWatchedByCategory: videosWatchedByCategory ?? this.videosWatchedByCategory,
      contentCompletedByCategory: contentCompletedByCategory ?? this.contentCompletedByCategory,
      lastActivity: lastActivity ?? this.lastActivity,
      firstActivity: firstActivity ?? this.firstActivity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class FeedbackMessage extends Equatable {
  final String id;
  final String userId;
  final String message;
  final String type; // 'suggestion', 'bug', 'complaint', 'compliment'
  final String status; // 'pending', 'reviewed', 'resolved'
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? response;

  const FeedbackMessage({
    required this.id,
    required this.userId,
    required this.message,
    required this.type,
    required this.status,
    required this.createdAt,
    this.reviewedAt,
    this.response,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        message,
        type,
        status,
        createdAt,
        reviewedAt,
        response,
      ];

  FeedbackMessage copyWith({
    String? id,
    String? userId,
    String? message,
    String? type,
    String? status,
    DateTime? createdAt,
    DateTime? reviewedAt,
    String? response,
  }) {
    return FeedbackMessage(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      message: message ?? this.message,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      response: response ?? this.response,
    );
  }
}

class ChartData extends Equatable {
  final String label;
  final double value;
  final String? color;

  const ChartData({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  List<Object?> get props => [label, value, color];

  ChartData copyWith({
    String? label,
    double? value,
    String? color,
  }) {
    return ChartData(
      label: label ?? this.label,
      value: value ?? this.value,
      color: color ?? this.color,
    );
  }
}

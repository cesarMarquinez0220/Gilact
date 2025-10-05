import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/settings_entities.dart';

class AppConfigurationModel extends AppConfiguration {
  const AppConfigurationModel({
    required super.id,
    required super.userId,
    required super.notificationsEnabled,
    required super.analyticsEnabled,
    required super.crashReportingEnabled,
    required super.language,
    required super.theme,
    required super.autoSaveProgress,
    required super.showTips,
    required super.darkMode,
    required super.fontSize,
    required super.soundEnabled,
    required super.vibrationEnabled,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AppConfigurationModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AppConfigurationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      analyticsEnabled: data['analyticsEnabled'] ?? true,
      crashReportingEnabled: data['crashReportingEnabled'] ?? true,
      language: data['language'] ?? 'es',
      theme: data['theme'] ?? 'system',
      autoSaveProgress: data['autoSaveProgress'] ?? true,
      showTips: data['showTips'] ?? true,
      darkMode: data['darkMode'] ?? false,
      fontSize: data['fontSize'] ?? 'medium',
      soundEnabled: data['soundEnabled'] ?? true,
      vibrationEnabled: data['vibrationEnabled'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory AppConfigurationModel.fromQueryDocument(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AppConfigurationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      analyticsEnabled: data['analyticsEnabled'] ?? true,
      crashReportingEnabled: data['crashReportingEnabled'] ?? true,
      language: data['language'] ?? 'es',
      theme: data['theme'] ?? 'system',
      autoSaveProgress: data['autoSaveProgress'] ?? true,
      showTips: data['showTips'] ?? true,
      darkMode: data['darkMode'] ?? false,
      fontSize: data['fontSize'] ?? 'medium',
      soundEnabled: data['soundEnabled'] ?? true,
      vibrationEnabled: data['vibrationEnabled'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'userId': userId,
      'notificationsEnabled': notificationsEnabled,
      'analyticsEnabled': analyticsEnabled,
      'crashReportingEnabled': crashReportingEnabled,
      'language': language,
      'theme': theme,
      'autoSaveProgress': autoSaveProgress,
      'showTips': showTips,
      'darkMode': darkMode,
      'fontSize': fontSize,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  AppConfigurationModel copyWith({
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
    return AppConfigurationModel(
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

class UserStatisticsModel extends UserStatistics {
  const UserStatisticsModel({
    required super.id,
    required super.userId,
    required super.totalVideosWatched,
    required super.totalLessonsCompleted,
    required super.totalContentCompleted,
    required super.totalTimeSpent,
    required super.averageSessionTime,
    required super.totalSessions,
    required super.videosWatchedByCategory,
    required super.contentCompletedByCategory,
    required super.lastActivity,
    required super.firstActivity,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserStatisticsModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserStatisticsModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      totalVideosWatched: data['totalVideosWatched'] ?? 0,
      totalLessonsCompleted: data['totalLessonsCompleted'] ?? 0,
      totalContentCompleted: data['totalContentCompleted'] ?? 0,
      totalTimeSpent: data['totalTimeSpent'] ?? 0,
      averageSessionTime: (data['averageSessionTime'] ?? 0.0).toDouble(),
      totalSessions: data['totalSessions'] ?? 0,
      videosWatchedByCategory: Map<String, int>.from(data['videosWatchedByCategory'] ?? {}),
      contentCompletedByCategory: Map<String, int>.from(data['contentCompletedByCategory'] ?? {}),
      lastActivity: (data['lastActivity'] as Timestamp?)?.toDate() ?? DateTime.now(),
      firstActivity: (data['firstActivity'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'userId': userId,
      'totalVideosWatched': totalVideosWatched,
      'totalLessonsCompleted': totalLessonsCompleted,
      'totalContentCompleted': totalContentCompleted,
      'totalTimeSpent': totalTimeSpent,
      'averageSessionTime': averageSessionTime,
      'totalSessions': totalSessions,
      'videosWatchedByCategory': videosWatchedByCategory,
      'contentCompletedByCategory': contentCompletedByCategory,
      'lastActivity': Timestamp.fromDate(lastActivity),
      'firstActivity': Timestamp.fromDate(firstActivity),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserStatisticsModel copyWith({
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
    return UserStatisticsModel(
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

class FeedbackMessageModel extends FeedbackMessage {
  const FeedbackMessageModel({
    required super.id,
    required super.userId,
    required super.message,
    required super.type,
    required super.status,
    required super.createdAt,
    super.reviewedAt,
    super.response,
  });

  factory FeedbackMessageModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return FeedbackMessageModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? 'suggestion',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reviewedAt: (data['reviewedAt'] as Timestamp?)?.toDate(),
      response: data['response'],
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'userId': userId,
      'message': message,
      'type': type,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'response': response,
    };
  }

  FeedbackMessageModel copyWith({
    String? id,
    String? userId,
    String? message,
    String? type,
    String? status,
    DateTime? createdAt,
    DateTime? reviewedAt,
    String? response,
  }) {
    return FeedbackMessageModel(
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

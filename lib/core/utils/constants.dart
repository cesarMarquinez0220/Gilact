class AppConstants {
  // Firebase Collections
  static const String usersCollection = 'Users';
  static const String videosCollection = 'videos';
  static const String lessonsCollection = 'lessons';
  static const String tipsCollection = 'tips';
  
  // SharedPreferences Keys
  static const String lastOpenedKey = 'last_opened';
  static const String userNameKey = 'user_name';
  static const String userEmailKey = 'user_email';
  static const String isFirstTimeKey = 'is_first_time';
  
  // App Info
  static const String appName = 'Gilact';
  static const String appVersion = '1.0.0';
  
  // Colors
  static const int primaryColorValue = 0xFF03A696;
  
  // Video Settings
  static const int maxVideoDuration = 300; // 5 minutes
  static const List<String> supportedVideoFormats = ['mp4', 'mov', 'avi'];
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  static const int minUserNameLength = 3;
  static const int maxUserNameLength = 20;
}

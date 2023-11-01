class UserDataStorage {
  static String _userName = '';
  static String _userEmail = '';

  static void setUserName(String name) {
    _userName = name;
  }

  static String getUserName() {
    return _userName;
  }

  static void setUserEmail(String email) {
    _userEmail = email;
  }

  static String getUserEmail() {
    return _userEmail;
  }

  static void updateUserName(String newName) {
    _userName = newName;
  }
}

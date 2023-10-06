class UserDataStorage {
  static String _userName = '';

  static void setUserName(String name) {
    _userName = name;
  }

  static String getUserName() {
    return _userName;
  }
}

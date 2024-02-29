// ignore_for_file: camel_case_types

class detection {
  static bool isLoggedIn = false;

  static void login() {
    isLoggedIn = true;
  }

  static void logout() {
    isLoggedIn = false;
  }
}

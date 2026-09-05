class RegistrationValidator {
  static String? validateName(String name) {
    if (name.trim().isEmpty) {
      return 'auth.register.validation.nameRequired';
    }
    return null;
  }

  static String? validateEmail(String email) {
    if (email.trim().isEmpty) {
      return 'auth.register.validation.emailRequired';
    } else if (!RegExp(r'^[\w-\.\+]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim())) {
      return 'auth.register.validation.emailInvalid';
    }
    return null;
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'auth.register.validation.passwordRequired';
    } else if (password.length < 6) {
      return 'auth.register.validation.passwordShort';
    }
    return null;
  }

  static String? validateBirthDate(String birthDate) {
    if (birthDate.trim().isEmpty) {
      return 'auth.register.validation.birthDateRequired';
    } else {
      try {
        final date = DateTime.parse(birthDate.trim());
        final now = DateTime.now();
        if (date.isAfter(now)) {
          return 'La fecha de nacimiento no puede ser futura';
        } else if (now.year - date.year < 16) {
          return 'Debes tener al menos 16 años para registrarte';
        }
      } catch (e) {
        return 'Formato de fecha inválido';
      }
    }
    return null;
  }
}
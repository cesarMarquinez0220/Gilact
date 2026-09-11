class AuthValidationService {
  // Validar email
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );
    return emailRegex.hasMatch(email);
  }

  // Validar cédula (formato panameño)
  static bool isValidCedula(String cedula) {
    // Remover guiones y espacios
    String cleanCedula = cedula.replaceAll(RegExp(r'[-\s]'), '');

    // Validar formato: 8-9 dígitos
    RegExp regex = RegExp(r'^\d{8,9}$');
    return regex.hasMatch(cleanCedula);
  }

  // Validar teléfono
  static bool isValidPhone(String phone) {
    // Remover espacios y guiones
    String cleanPhone = phone.replaceAll(RegExp(r'[\s-]'), '');

    // Validar formato: 8 dígitos
    RegExp regex = RegExp(r'^\d{8}$');
    return regex.hasMatch(cleanPhone);
  }

  // Validar edad
  static bool isValidAge(String age) {
    int? ageInt = int.tryParse(age);
    return ageInt != null && ageInt >= 16 && ageInt <= 100;
  }

  // Validar contraseña
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // Validar contraseña fuerte
  static bool isStrongPassword(String password) {
    if (password.length < 8) return false;

    bool hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowerCase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = password.contains(
      RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
    );

    return hasUpperCase && hasLowerCase && hasDigits && hasSpecialCharacters;
  }

  // Validar campo requerido
  static bool isRequiredField(String value) {
    return value.trim().isNotEmpty;
  }

  // Validar fecha de nacimiento
  static bool isValidBirthDate(String date) {
    if (date.isEmpty) return false;

    try {
      DateTime birthDate = DateTime.parse(date);
      DateTime now = DateTime.now();
      DateTime minDate = DateTime(now.year - 100);
      DateTime maxDate = DateTime(now.year - 16);

      return birthDate.isAfter(minDate) && birthDate.isBefore(maxDate);
    } catch (e) {
      return false;
    }
  }

  // Validar formulario completo de registro
  static Map<String, String> validateRegistrationForm({
    required String usuario,
    required String email,
    required String contrasena,
    required String confirmPassword,
    required String nombreMadre,
    required String fechaNacimiento,
    required String edad,
    required String cedula,
    required String ubicacion,
    required String telefono,
  }) {
    Map<String, String> errors = {};

    // Validar campos requeridos
    if (!isRequiredField(usuario)) {
      errors['usuario'] = 'El nombre de usuario es requerido';
    } else if (usuario.length < 3) {
      errors['usuario'] =
          'El nombre de usuario debe tener al menos 3 caracteres';
    }

    if (!isRequiredField(email)) {
      errors['email'] = 'El email es requerido';
    } else if (!isValidEmail(email)) {
      errors['email'] = 'Formato de email inválido';
    }

    if (!isRequiredField(contrasena)) {
      errors['contrasena'] = 'La contraseña es requerida';
    } else if (!isValidPassword(contrasena)) {
      errors['contrasena'] = 'La contraseña debe tener al menos 6 caracteres';
    }

    if (!isRequiredField(confirmPassword)) {
      errors['confirmPassword'] = 'Confirma tu contraseña';
    } else if (contrasena != confirmPassword) {
      errors['confirmPassword'] = 'Las contraseñas no coinciden';
    }

    if (!isRequiredField(nombreMadre)) {
      errors['nombreMadre'] = 'El nombre de la madre es requerido';
    }

    if (!isRequiredField(fechaNacimiento)) {
      errors['fechaNacimiento'] = 'La fecha de nacimiento es requerida';
    } else if (!isValidBirthDate(fechaNacimiento)) {
      errors['fechaNacimiento'] = 'Fecha de nacimiento inválida';
    }

    if (!isRequiredField(edad)) {
      errors['edad'] = 'La edad es requerida';
    } else if (!isValidAge(edad)) {
      errors['edad'] = 'La edad debe estar entre 16 y 100 años';
    }

    if (!isRequiredField(cedula)) {
      errors['cedula'] = 'La cédula es requerida';
    } else if (!isValidCedula(cedula)) {
      errors['cedula'] = 'Formato de cédula inválido';
    }

    if (!isRequiredField(ubicacion)) {
      errors['ubicacion'] = 'La ubicación es requerida';
    }

    if (!isRequiredField(telefono)) {
      errors['telefono'] = 'El teléfono es requerido';
    } else if (!isValidPhone(telefono)) {
      errors['telefono'] = 'Formato de teléfono inválido (8 dígitos)';
    }

    return errors;
  }

  // Validar formulario de login
  static Map<String, String> validateLoginForm({
    required String email,
    required String contrasena,
  }) {
    Map<String, String> errors = {};

    if (!isRequiredField(email)) {
      errors['email'] = 'El email es requerido';
    } else if (!isValidEmail(email)) {
      errors['email'] = 'Formato de email inválido';
    }

    if (!isRequiredField(contrasena)) {
      errors['contrasena'] = 'La contraseña es requerida';
    }

    return errors;
  }

  // Obtener mensaje de error amigable
  static String getErrorMessage(String field, String error) {
    switch (field) {
      case 'email':
        return 'Por favor, ingresa un email válido';
      case 'contrasena':
        return 'La contraseña debe tener al menos 6 caracteres';
      case 'confirmPassword':
        return 'Las contraseñas no coinciden';
      case 'cedula':
        return 'Ingresa una cédula válida (8-9 dígitos)';
      case 'telefono':
        return 'Ingresa un teléfono válido (8 dígitos)';
      case 'edad':
        return 'La edad debe estar entre 16 y 100 años';
      case 'fechaNacimiento':
        return 'Selecciona una fecha de nacimiento válida';
      case 'usuario':
        return 'El nombre de usuario debe tener al menos 3 caracteres';
      default:
        return 'Este campo es requerido';
    }
  }

  // Obtener fortaleza de contraseña
  static String getPasswordStrength(String password) {
    if (password.isEmpty) return '';
    if (password.length < 6) return 'Muy débil';
    if (password.length < 8) return 'Débil';
    if (isStrongPassword(password)) return 'Fuerte';
    return 'Media';
  }

  // Obtener color de fortaleza de contraseña
  static int getPasswordStrengthColor(String password) {
    if (password.isEmpty) return 0xFF9E9E9E; // Gris
    if (password.length < 6) return 0xFFF44336; // Rojo
    if (password.length < 8) return 0xFFFF9800; // Naranja
    if (isStrongPassword(password)) return 0xFF4CAF50; // Verde
    return 0xFFFFC107; // Amarillo
  }
}

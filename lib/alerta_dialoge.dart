import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class DialogExample {
  static void showAlertDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => _buildModernDialog(
        context: context,
        title: title,
        message: message,
        icon: Icons.warning_amber_rounded,
        iconColor: const Color.fromARGB(255, 253, 40, 40),
        primaryColor: const Color.fromARGB(255, 253, 40, 40),
      ),
    );
  }

  static void showSuccessDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback? onContinue,
  ) {
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => _buildModernDialog(
        context: context,
        title: title,
        message: message,
        icon: Icons.check_circle_rounded,
        iconColor: Colors.green,
        primaryColor: Colors.green,
        onContinue: onContinue,
        continueText: 'Continuar',
      ),
    );
  }

  static void showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => _buildModernDialog(
        context: context,
        title: title,
        message: message,
        icon: Icons.error_rounded,
        iconColor: Colors.red,
        primaryColor: Colors.red,
      ),
    );
  }

  static void showInfoDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => _buildModernDialog(
        context: context,
        title: title,
        message: message,
        icon: Icons.info_rounded,
        iconColor: const Color.fromRGBO(27, 167, 214, 1),
        primaryColor: const Color.fromRGBO(27, 167, 214, 1),
      ),
    );
  }

  static Widget _buildModernDialog({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    required Color primaryColor,
    VoidCallback? onContinue,
    String? continueText,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.9),
                    Colors.white.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icono animado
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          iconColor.withValues(alpha: 0.2),
                          iconColor.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                    child: Icon(icon, size: 40, color: iconColor),
                  ),
                  const SizedBox(height: 20),

                  // Título
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mensaje
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botones
                  Row(
                    children: [
                      if (onContinue != null) ...[
                        // Botón secundario (Cancelar)
                        Expanded(
                          child: _buildDialogButton(
                            text: 'Cancelar',
                            onPressed: () => Navigator.of(context).pop(),
                            isPrimary: false,
                            primaryColor: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],

                      // Botón principal
                      Expanded(
                        child: _buildDialogButton(
                          text: onContinue != null
                              ? (continueText ?? 'Aceptar')
                              : 'Entendido',
                          onPressed: () {
                            Navigator.of(context).pop();
                            if (onContinue != null) {
                              onContinue();
                            }
                          },
                          isPrimary: true,
                          primaryColor: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildDialogButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
    required Color primaryColor,
  }) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: isPrimary
            ? LinearGradient(
                colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        border: isPrimary
            ? null
            : Border.all(color: Colors.grey.withValues(alpha: 0.3), width: 1.5),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? Colors.transparent
              : Colors.white.withValues(alpha: 0.7),
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isPrimary ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }

  static void showUserAlreadyExistsDialog(BuildContext context) {
    showErrorDialog(
      context,
      'Email Ya Registrado',
      'Este correo electrónico ya está asociado a una cuenta existente. Por favor, utiliza otro email o inicia sesión.',
    );
  }

  static void showRegistrationSuccessDialog(
    BuildContext context,
    VoidCallback onContinue,
  ) {
    showSuccessDialog(
      context,
      '¡Registro Exitoso!',
      'Tu cuenta ha sido creada correctamente. Ya puedes iniciar sesión con tus credenciales.',
      onContinue,
    );
  }

  static void showValidationErrorDialog(BuildContext context, String field) {
    showErrorDialog(
      context,
      'Campo Requerido',
      'Por favor, completa el campo "$field" para continuar con el registro.',
    );
  }

  static void showInvalidEmailDialog(BuildContext context) {
    showErrorDialog(
      context,
      'Email Inválido',
      'Por favor, ingresa una dirección de correo electrónico válida (ejemplo: usuario@dominio.com).',
    );
  }

  static void showNetworkErrorDialog(BuildContext context) {
    showErrorDialog(
      context,
      'Error de Conexión',
      'No se pudo conectar al servidor. Verifica tu conexión a internet e inténtalo nuevamente.',
    );
  }
}

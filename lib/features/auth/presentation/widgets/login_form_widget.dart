import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/utils/responsive_helper.dart';

class LoginFormWidget extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool saveCredentials;
  final Animation<double>? slideAnimation;
  final Animation<double>? fadeAnimation;
  final VoidCallback onRecoveryTap;
  final VoidCallback onSignUpTap;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onLoginPressed;
  final VoidCallback? onBiometricPressed;
  final bool isLoading;
  final String? emailError;
  final String? passwordError;
  final bool showBiometricButton;

  const LoginFormWidget({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.saveCredentials,
    this.slideAnimation,
    this.fadeAnimation,
    required this.onRecoveryTap,
    required this.onSignUpTap,
    required this.onRememberChanged,
    required this.onLoginPressed,
    this.onBiometricPressed,
    this.isLoading = false,
    this.emailError,
    this.passwordError,
    this.showBiometricButton = false,
  });

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    // Valores responsive para pantallas pequeñas
    final isSmallScreen = ResponsiveHelper.isExtraSmall(context) || 
                         ResponsiveHelper.isSmall(context);
    final isShortScreen = ResponsiveHelper.isShortScreen(context);
    
    final topPadding = isSmallScreen ? 20.0 : (isShortScreen ? 40.0 : 80.0);
    final horizontalPadding = ResponsiveHelper.getResponsivePadding(context);
    final logoSize = isSmallScreen ? 100.0 : (isShortScreen ? 120.0 : 140.0);
    final titleFontSize = ResponsiveHelper.getResponsiveFontSize(context, isSmallScreen ? 26.0 : 32.0);
    final subtitleFontSize = ResponsiveHelper.getResponsiveFontSize(context, isSmallScreen ? 15.0 : 17.0);
    final spacingAfterLogo = isSmallScreen ? 20.0 : (isShortScreen ? 24.0 : 32.0);
    final spacingAfterTitle = isSmallScreen ? 8.0 : 12.0;
    final spacingBeforeForm = isSmallScreen ? 32.0 : (isShortScreen ? 40.0 : 48.0);
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isSmallScreen ? 16.0 : 24.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: topPadding),

          // Logo y título
          AnimatedBuilder(
            animation:
                widget.fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
            builder: (context, child) {
              return FadeTransition(
                opacity:
                    widget.fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo-completo2.png',
                      height: logoSize,
                      width: logoSize,
                    ),
                    SizedBox(height: spacingAfterLogo),
                    Text(
                      'auth.login.welcomeBack'.tr(),
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: spacingAfterTitle),
                    Text(
                      'auth.login.loginToContinue'.tr(),
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          SizedBox(height: spacingBeforeForm),
          // Formulario
          AnimatedBuilder(
            animation:
                widget.slideAnimation ?? const AlwaysStoppedAnimation(0.0),
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, widget.slideAnimation?.value ?? 0),
                child: Column(
                  children: [
                    // Campo de email
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha:0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha:0.1),
                            blurRadius: 20,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: widget.emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !widget.isLoading,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'auth.login.email'.tr(),
                          hintStyle: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Colors.white70,
                            size: 22,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: isSmallScreen ? 16.0 : 20.0),

                    // Campo de contraseña con botón biométrico al lado
                    Row(
                      children: [
                        // Campo de contraseña
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha:0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha:0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha:0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha:0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: widget.passwordController,
                              obscureText: _obscurePassword,
                              enabled: !widget.isLoading,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'auth.login.password'.tr(),
                                hintStyle: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock_outlined,
                                  color: Colors.white70,
                                  size: 22,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.white70,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Botón de autenticación biométrica (si está disponible)
                        if (widget.showBiometricButton &&
                            widget.onBiometricPressed != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, -2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: widget.isLoading
                                      ? null
                                      : widget.onBiometricPressed,
                                  child: const Center(
                                    child: Icon(
                                      Icons.fingerprint,
                                      color: Colors.white70,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: isSmallScreen ? 12.0 : 16.0),

                    // Opciones adicionales
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Checkbox(
                                value: widget.saveCredentials,
                                onChanged: widget.isLoading
                                    ? null
                                    : widget.onRememberChanged,
                                fillColor: WidgetStateProperty.all(
                                  Colors.transparent,
                                ),
                                checkColor: Colors.white,
                                activeColor: Colors.transparent,
                                side: BorderSide.none,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'auth.login.remember'.tr(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: widget.isLoading
                              ? null
                              : widget.onRecoveryTap,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'auth.login.forgotPassword'.tr(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isSmallScreen ? 20.0 : 24.0),

                    // Botón de login
                    Container(
                      width: double.infinity,
                      height: ResponsiveHelper.getResponsiveButtonHeight(context),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1A365D), // Azul marino oscuro (primario)
                            Color(
                              0xFF4FD1C7,
                            ), // Verde azulado medio vibrante (primario)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4FD1C7).withValues(alpha:0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: widget.isLoading
                            ? null
                            : widget.onLoginPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: widget.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'auth.login.login'.tr(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),

                    SizedBox(height: isSmallScreen ? 20.0 : 24.0),

                    // Enlace a registro
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha:0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'auth.login.noAccount'.tr(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextButton(
                            onPressed: widget.isLoading
                                ? null
                                : widget.onSignUpTap,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'auth.login.signUp'.tr(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

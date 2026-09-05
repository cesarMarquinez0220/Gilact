import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/utils/responsive_helper.dart';

class RegistrationFormWidget extends StatefulWidget {
  final int currentStep;
  final Animation<double>? slideAnimation;
  final Animation<double>? fadeAnimation;
  final bool isLoading;
  final Map<String, String> errors;
  final double profileCompletion;
  final VoidCallback onNextStep;
  final VoidCallback onPreviousStep;
  final VoidCallback onRegister;
  final VoidCallback onBirthDateTap;
  final ValueChanged<String> onFieldChanged;
  final VoidCallback onBackToLogin;

  // Controladores
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController phoneController;
  final TextEditingController locationController;
  final TextEditingController birthDateController;
  final TextEditingController ageController;
  final TextEditingController idNumberController;
  final TextEditingController motherNameController;

  const RegistrationFormWidget({
    super.key,
    required this.currentStep,
    this.slideAnimation,
    this.fadeAnimation,
    this.isLoading = false,
    required this.errors,
    required this.profileCompletion,
    required this.onNextStep,
    required this.onPreviousStep,
    required this.onRegister,
    required this.onBirthDateTap,
    required this.onFieldChanged,
    required this.onBackToLogin,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.phoneController,
    required this.locationController,
    required this.birthDateController,
    required this.ageController,
    required this.idNumberController,
    required this.motherNameController,
  });

  @override
  State<RegistrationFormWidget> createState() => _RegistrationFormWidgetState();
}

class _RegistrationFormWidgetState extends State<RegistrationFormWidget> {
  bool _obscurePassword = true;
  String _passwordStrength = '';
  Color _passwordStrengthColor = Colors.grey;

  void _updatePasswordStrength(String password) {
    setState(() {
      if (password.isEmpty) {
        _passwordStrength = '';
        _passwordStrengthColor = Colors.grey;
      } else if (password.length < 6) {
        _passwordStrength = 'auth.register.passwordStrength.veryWeak'.tr();
        _passwordStrengthColor = Colors.red;
      } else if (password.length < 8) {
        _passwordStrength = 'auth.register.passwordStrength.weak'.tr();
        _passwordStrengthColor = Colors.orange;
      } else if (password.length >= 8 &&
          password.contains(RegExp(r'[A-Z]')) &&
          password.contains(RegExp(r'[a-z]')) &&
          password.contains(RegExp(r'[0-9]'))) {
        _passwordStrength = 'auth.register.passwordStrength.strong'.tr();
        _passwordStrengthColor = Colors.green;
      } else {
        _passwordStrength = 'auth.register.passwordStrength.medium'.tr();
        _passwordStrengthColor = Colors.yellow;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.slideAnimation ?? const AlwaysStoppedAnimation(0.0),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, widget.slideAnimation?.value ?? 0),
          child: FadeTransition(
            opacity: widget.fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
            child: _buildCurrentStep(),
          ),
        );
      },
    );
  }

  Widget _buildCurrentStep() {
    switch (widget.currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      default:
        return _buildStep1();
    }
  }

  Widget _buildStep1() {
    // Valores responsive para pantallas pequeñas
    final isSmallScreen = ResponsiveHelper.isExtraSmall(context) || 
                         ResponsiveHelper.isSmall(context);
    final isShortScreen = ResponsiveHelper.isShortScreen(context);
    
    final topPadding = isSmallScreen ? 20.0 : (isShortScreen ? 30.0 : 40.0);
    final horizontalPadding = ResponsiveHelper.getResponsivePadding(context);
    final titleFontSize = ResponsiveHelper.getResponsiveFontSize(context, isSmallScreen ? 26.0 : 32.0);
    final subtitleFontSize = ResponsiveHelper.getResponsiveFontSize(context, isSmallScreen ? 15.0 : 17.0);
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

          // Título y subtítulo
          Column(
            children: [
              Text(
                'auth.register.createAccount'.tr(),
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  shadows: const [
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
                'auth.register.basicInfo'.tr(),
                style: TextStyle(
                  fontSize: subtitleFontSize,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),

          SizedBox(height: spacingBeforeForm),

          // Campo de nombre
          _buildTextField(
            controller: widget.nameController,
            hintText: 'auth.register.fullName'.tr(),
            icon: Icons.person_outlined,
            errorText: widget.errors['name'],
            onChanged: (value) => widget.onFieldChanged('name'),
          ),

          SizedBox(height: isSmallScreen ? 16.0 : 20.0),

          // Campo de email
          _buildTextField(
            controller: widget.emailController,
            hintText: 'auth.register.email'.tr(),
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            errorText: widget.errors['email'],
            onChanged: (value) => widget.onFieldChanged('email'),
          ),

          SizedBox(height: isSmallScreen ? 16.0 : 20.0),

          // Campo de contraseña
          _buildTextField(
            controller: widget.passwordController,
            hintText: 'auth.register.password'.tr(),
            icon: Icons.lock_outlined,
            obscureText: _obscurePassword,
            errorText: widget.errors['password'],
            onChanged: (value) {
              widget.onFieldChanged('password');
              _updatePasswordStrength(value);
            },
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
          ),

          // Indicador de fortaleza de contraseña
          if (widget.passwordController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildPasswordStrengthIndicator(),
          ],

          SizedBox(height: isSmallScreen ? 16.0 : 20.0),

          // Botón siguiente
          _buildActionButton(
            text: 'auth.register.next'.tr(),
            onPressed: widget.onNextStep,
            isLoading: widget.isLoading,
          ),

          SizedBox(height: isSmallScreen ? 20.0 : 24.0),

          // Indicador de pasos
          _buildStepIndicator(),

          SizedBox(height: isSmallScreen ? 16.0 : 20.0),

          // Botón de regreso al login
          _buildBackToLoginButton(),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    // Valores responsive para pantallas pequeñas
    final isSmallScreen = ResponsiveHelper.isExtraSmall(context) || 
                         ResponsiveHelper.isSmall(context);
    final isShortScreen = ResponsiveHelper.isShortScreen(context);
    
    final topPadding = isSmallScreen ? 20.0 : (isShortScreen ? 30.0 : 40.0);
    final horizontalPadding = ResponsiveHelper.getResponsivePadding(context);
    final titleFontSize = ResponsiveHelper.getResponsiveFontSize(context, isSmallScreen ? 26.0 : 32.0);
    final subtitleFontSize = ResponsiveHelper.getResponsiveFontSize(context, isSmallScreen ? 15.0 : 17.0);
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

          // Título y subtítulo
          Column(
            children: [
              Text(
                'auth.register.personalData'.tr(),
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  shadows: const [
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
                'auth.register.personalDataDescription'.tr(),
                style: TextStyle(
                  fontSize: subtitleFontSize,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),

          SizedBox(height: spacingBeforeForm),

          // Campo de fecha de nacimiento
          _buildTextField(
            controller: widget.birthDateController,
            hintText: '${'profile.birthDate'.tr()} *',
            icon: Icons.calendar_today_outlined,
            readOnly: true,
            onTap: widget.onBirthDateTap,
            errorText: widget.errors['birthDate'],
            onChanged: (value) => widget.onFieldChanged('birthDate'),
          ),

          SizedBox(height: isSmallScreen ? 24.0 : 32.0),

          // Términos y condiciones
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Checkbox(
                    value: true,
                    fillColor: WidgetStateProperty.all(Colors.transparent),
                    checkColor: Colors.white,
                    activeColor: Colors.transparent,
                    side: BorderSide.none,
                    onChanged: (value) {
                      // Implementar lógica de términos si es necesario
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'auth.register.acceptTerms'.tr(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Botones de navegación
          Row(
            children: [
              Expanded(
                child: _buildSecondaryButton(
                  text: 'auth.register.back'.tr(),
                  onPressed: widget.onPreviousStep,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  text: 'auth.register.register'.tr(),
                  onPressed: widget.onRegister,
                  isLoading: widget.isLoading,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Indicador de pasos
          _buildStepIndicator(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool readOnly = false,
    String? errorText,
    Widget? suffixIcon,
    VoidCallback? onTap,
    ValueChanged<String>? onChanged,
  }) {
    final fontSize = ResponsiveHelper.getResponsiveFontSize(context, 16);
    final verticalPadding = ResponsiveHelper.getResponsiveValue(context, small: 14.0, medium: 16.0, large: 18.0);
    final horizontalPadding = ResponsiveHelper.getResponsiveValue(context, small: 16.0, medium: 20.0, large: 24.0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: errorText != null
                ? Colors.red.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.3),
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
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        readOnly: readOnly,
        enabled: !widget.isLoading,
        onTap: onTap,
        onChanged: onChanged,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white70,
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(icon, color: Colors.white70, size: fontSize * 1.375), // ~22px relative to 16
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          errorText: errorText,
          errorStyle: TextStyle(color: Colors.redAccent, fontSize: fontSize * 0.75), // ~12px relative to 16
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    final buttonHeight = ResponsiveHelper.getResponsiveButtonHeight(context);
    final fontSize = ResponsiveHelper.getResponsiveFontSize(context, 18);

    return Container(
      width: double.infinity,
      height: buttonHeight,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1A365D), // Azul marino oscuro (primario)
            Color(0xFF4FD1C7), // Verde azulado medio vibrante (primario)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4FD1C7).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: fontSize * 1.33,
                width: fontSize * 1.33,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    final buttonHeight = ResponsiveHelper.getResponsiveButtonHeight(context);
    final fontSize = ResponsiveHelper.getResponsiveFontSize(context, 18);

    return Container(
      width: double.infinity,
      height: buttonHeight,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final fontSize = ResponsiveHelper.getResponsiveFontSize(context, 12);
    final iconSize = fontSize * 1.33; // ~16px relatives to 12

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getResponsiveValue(context, small: 10, medium: 12, large: 14),
        vertical: ResponsiveHelper.getResponsiveValue(context, small: 6, medium: 8, large: 10),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.security, color: _passwordStrengthColor, size: iconSize),
          SizedBox(width: ResponsiveHelper.getResponsiveValue(context, small: 6, medium: 8, large: 10)),
          Text(
            'Fortaleza: $_passwordStrength',
            style: TextStyle(
              color: _passwordStrengthColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final progress = (widget.currentStep + 1) / 3;
    final percentage = (progress * 100).round();

    return Column(
      children: [
        // Barra de progreso mejorada
        Container(
          width: double.infinity,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: Colors.white.withValues(alpha: 0.2),
          ),
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * progress,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A365D), Color(0xFF4FD1C7)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4FD1C7).withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        // Información de progreso
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Paso ${widget.currentStep + 1} de 2',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$percentage%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Puntos indicadores
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(2, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index <= widget.currentStep
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBackToLoginButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              'auth.login.alreadyHaveAccount'.tr(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Flexible(
            child: TextButton(
              onPressed: widget.isLoading ? null : widget.onBackToLogin,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'auth.login.login'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

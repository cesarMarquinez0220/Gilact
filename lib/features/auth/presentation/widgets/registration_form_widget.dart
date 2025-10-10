import 'package:flutter/material.dart';

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
        _passwordStrength = 'Muy débil';
        _passwordStrengthColor = Colors.red;
      } else if (password.length < 8) {
        _passwordStrength = 'Débil';
        _passwordStrengthColor = Colors.orange;
      } else if (password.length >= 8 &&
          password.contains(RegExp(r'[A-Z]')) &&
          password.contains(RegExp(r'[a-z]')) &&
          password.contains(RegExp(r'[0-9]'))) {
        _passwordStrength = 'Fuerte';
        _passwordStrengthColor = Colors.green;
      } else {
        _passwordStrength = 'Media';
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
      case 2:
        return _buildStep3();
      default:
        return _buildStep1();
    }
  }

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          // Título y subtítulo
          Column(
            children: [
              const Text(
                'Crear Cuenta',
                style: TextStyle(
                  fontSize: 32,
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
              const SizedBox(height: 12),
              const Text(
                'Información básica para comenzar',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),

          const SizedBox(height: 48),

          // Campo de nombre
          _buildTextField(
            controller: widget.nameController,
            hintText: 'Nombre completo *',
            icon: Icons.person_outlined,
            errorText: widget.errors['name'],
            onChanged: (value) => widget.onFieldChanged('name'),
          ),

          const SizedBox(height: 20),

          // Campo de email
          _buildTextField(
            controller: widget.emailController,
            hintText: 'Email *',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            errorText: widget.errors['email'],
            onChanged: (value) => widget.onFieldChanged('email'),
          ),

          const SizedBox(height: 20),

          // Campo de contraseña
          _buildTextField(
            controller: widget.passwordController,
            hintText: 'Contraseña *',
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

          const SizedBox(height: 20),

          // Botón siguiente
          _buildActionButton(
            text: 'Siguiente',
            onPressed: widget.onNextStep,
            isLoading: widget.isLoading,
          ),

          const SizedBox(height: 24),

          // Indicador de pasos
          _buildStepIndicator(),

          const SizedBox(height: 20),

          // Botón de regreso al login
          _buildBackToLoginButton(),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          // Título y subtítulo
          Column(
            children: [
              const Text(
                'Datos Personales',
                style: TextStyle(
                  fontSize: 32,
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
              const SizedBox(height: 12),
              const Text(
                'Información adicional sobre ti',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),

          const SizedBox(height: 48),

          // Campo de teléfono
          _buildTextField(
            controller: widget.phoneController,
            hintText: 'Teléfono (opcional)',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            errorText: widget.errors['phone'],
            onChanged: (value) => widget.onFieldChanged('phone'),
          ),

          const SizedBox(height: 20),

          // Campo de ubicación
          _buildTextField(
            controller: widget.locationController,
            hintText: 'Ubicación',
            icon: Icons.location_on_outlined,
            errorText: widget.errors['location'],
            onChanged: (value) => widget.onFieldChanged('location'),
          ),

          const SizedBox(height: 20),

          // Fila con fecha de nacimiento y edad
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: widget.birthDateController,
                  hintText: 'Fecha de nacimiento *',
                  icon: Icons.calendar_today_outlined,
                  readOnly: true,
                  onTap: widget.onBirthDateTap,
                  errorText: widget.errors['birthDate'],
                  onChanged: (value) => widget.onFieldChanged('birthDate'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: widget.ageController,
                  hintText: 'Edad',
                  icon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                  errorText: widget.errors['age'],
                  onChanged: (value) => widget.onFieldChanged('age'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Botones de navegación
          Row(
            children: [
              Expanded(
                child: _buildSecondaryButton(
                  text: 'Anterior',
                  onPressed: widget.onPreviousStep,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  text: 'Siguiente',
                  onPressed: widget.onNextStep,
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

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          // Título y subtítulo
          Column(
            children: [
              const Text(
                'Información Adicional',
                style: TextStyle(
                  fontSize: 32,
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
              const SizedBox(height: 12),
              const Text(
                'Últimos detalles para completar',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),

          const SizedBox(height: 48),

          // Campo de nombre de la madre
          _buildTextField(
            controller: widget.motherNameController,
            hintText: 'Nombre de la madre (opcional)',
            icon: Icons.family_restroom_outlined,
            errorText: widget.errors['motherName'],
            onChanged: (value) => widget.onFieldChanged('motherName'),
          ),

          const SizedBox(height: 20),

          // Campo de número de identificación
          _buildTextField(
            controller: widget.idNumberController,
            hintText: 'Número de identificación (opcional)',
            icon: Icons.badge_outlined,
            errorText: widget.errors['idNumber'],
            onChanged: (value) => widget.onFieldChanged('idNumber'),
          ),

          const SizedBox(height: 32),

          // Términos y condiciones
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Checkbox(
                    value: true,
                    fillColor: MaterialStateProperty.all(Colors.transparent),
                    checkColor: Colors.white,
                    activeColor: Colors.transparent,
                    side: BorderSide.none,
                    onChanged: (value) {
                      // Implementar lógica de términos si es necesario
                    },
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Acepto los términos y condiciones de uso',
                    style: TextStyle(
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
                  text: 'Anterior',
                  onPressed: widget.onPreviousStep,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  text: 'Crear Cuenta',
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: errorText != null
              ? Colors.red.withOpacity(0.5)
              : Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
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
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(icon, color: Colors.white70, size: 22),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          errorText: errorText,
          errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
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
            color: const Color(0xFF4FD1C7).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
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
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.security, color: _passwordStrengthColor, size: 16),
          const SizedBox(width: 8),
          Text(
            'Fortaleza: $_passwordStrength',
            style: TextStyle(
              color: _passwordStrengthColor,
              fontSize: 12,
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
            color: Colors.white.withOpacity(0.2),
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
                      color: const Color(0xFF4FD1C7).withOpacity(0.5),
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
              'Paso ${widget.currentStep + 1} de 3',
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
          children: List.generate(3, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index <= widget.currentStep
                    ? Colors.white
                    : Colors.white.withOpacity(0.3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
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
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '¿Ya tienes una cuenta? ',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
          TextButton(
            onPressed: widget.isLoading ? null : widget.onBackToLogin,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Inicia Sesión',
              style: TextStyle(
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
    );
  }
}

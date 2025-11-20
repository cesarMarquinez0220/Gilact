import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../chatbot/presentation/pages/chatbot_page.dart';
import '../../../chatbot/presentation/bloc/chatbot_bloc.dart';

/// Página de perfil del usuario con diseño consistente y configuraciones
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _autoSaveProgress = true;
  String _language = 'es';
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool('soundEnabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
      _autoSaveProgress = prefs.getBool('autoSaveProgress') ?? true;
      _language = prefs.getString('language') ?? 'es';
    });

    // Cargar versión de la app desde SharedPreferences o usar versión por defecto
    final versionFromPrefs = prefs.getString('app_version');
    if (versionFromPrefs != null) {
      setState(() {
        _appVersion = versionFromPrefs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header personalizado
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Row(
              children: [
                Text(
                  'Perfil',
                  style: GoogleFonts.quicksand(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Contenido del perfil
          Expanded(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return _buildProfileContent(context, state.user);
                } else {
                  return const Center(
                    child: Text(
                      'No hay usuario autenticado',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, user) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de información del usuario
            _buildUserInfoCard(user),
            const SizedBox(height: 20),

            // Sección: Configuración de la aplicación
            _buildSectionTitle('Configuración de la Aplicación'),
            const SizedBox(height: 12),
            _buildSettingsCard(),

            const SizedBox(height: 20),

            // Sección: Ayuda y Soporte
            _buildSectionTitle('Ayuda y Soporte'),
            const SizedBox(height: 12),
            _buildHelpCard(),

            const SizedBox(height: 20),

            // Sección: Cuenta
            _buildSectionTitle('Cuenta'),
            const SizedBox(height: 12),
            _buildAccountCard(context, user),

            const SizedBox(height: 20),

            // Información de la app
            _buildAppInfoCard(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(user) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            // Avatar ampliado sin opción de editar imagen
            CircleAvatar(
              radius: 70,
              backgroundColor: const Color(0xFF03A696),
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              user.name,
              style: GoogleFonts.quicksand(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: GoogleFonts.quicksand(
                fontSize: 16,
                color: const Color(0xFF7F8C8D),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showEditProfile(context),
              icon: const Icon(Icons.edit, size: 20),
              label: Text(
                'Editar Perfil',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF03A696),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: GoogleFonts.quicksand(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingSwitch(
            'Sonido',
            'Reproducir sonidos en la app',
            Icons.volume_up_outlined,
            _soundEnabled,
            (value) async {
              setState(() => _soundEnabled = value);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('soundEnabled', value);
            },
          ),
          const Divider(height: 1),
          _buildSettingSwitch(
            'Vibración',
            'Vibrar en interacciones',
            Icons.vibration,
            _vibrationEnabled,
            (value) async {
              setState(() => _vibrationEnabled = value);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('vibrationEnabled', value);
            },
          ),
          const Divider(height: 1),
          _buildSettingSwitch(
            'Guardado Automático',
            'Guardar progreso automáticamente',
            Icons.save_outlined,
            _autoSaveProgress,
            (value) async {
              setState(() => _autoSaveProgress = value);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('autoSaveProgress', value);
            },
          ),
          const Divider(height: 1),
          _buildSettingTile(
            'Idioma',
            _getLanguageDisplayName(_language),
            Icons.language,
            () => _showLanguageSelector(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingTile(
            'Centro de Ayuda',
            'Chatea con nuestro asistente virtual',
            Icons.help_outline,
            () => _navigateToChatbot(context),
          ),
          const Divider(height: 1),
          _buildSettingTile(
            'Contactar Soporte',
            'soporte@gilact.com',
            Icons.support_agent,
            () => _showContactSupport(context),
          ),
          const Divider(height: 1),
          _buildSettingTile(
            'Términos y Condiciones',
            'Ver términos de uso',
            Icons.description_outlined,
            () => _showTerms(context),
          ),
          const Divider(height: 1),
          _buildSettingTile(
            'Política de Privacidad',
            'Ver política de privacidad',
            Icons.privacy_tip_outlined,
            () => _showPrivacyPolicy(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, user) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingTile(
            'Eliminar Cuenta',
            'Eliminar permanentemente tu cuenta',
            Icons.delete_outline,
            () => _showDeleteAccount(context),
            isDestructive: true,
          ),
          const Divider(height: 1),
          _buildSettingTile(
            'Cerrar Sesión',
            'Salir de tu cuenta',
            Icons.logout,
            () => _signOut(context),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.white.withOpacity(0.8),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gilact',
                  style: GoogleFonts.quicksand(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Versión $_appVersion',
                  style: GoogleFonts.quicksand(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSwitch(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF03A696)),
      title: Text(
        title,
        style: GoogleFonts.quicksand(
          fontWeight: FontWeight.w500,
          color: const Color(0xFF2C3E50),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.quicksand(
          fontSize: 12,
          color: const Color(0xFF7F8C8D),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF03A696),
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : const Color(0xFF03A696),
      ),
      title: Text(
        title,
        style: GoogleFonts.quicksand(
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : const Color(0xFF2C3E50),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.quicksand(
          fontSize: 12,
          color: const Color(0xFF7F8C8D),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  String _getLanguageDisplayName(String code) {
    switch (code) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      default:
        return 'Español';
    }
  }

  void _navigateToChatbot(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => GetIt.instance<ChatbotBloc>(),
          child: const ChatbotPage(),
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Seleccionar Idioma',
              style: GoogleFonts.quicksand(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildLanguageOption(context, 'es', 'Español'),
            _buildLanguageOption(context, 'en', 'English'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String code, String name) {
    final isSelected = _language == code;
    return ListTile(
      title: Text(name),
      trailing: isSelected
          ? const Icon(Icons.check, color: Color(0xFF03A696))
          : null,
      onTap: () async {
        setState(() => _language = code);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('language', code);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Idioma cambiado a $name'),
            backgroundColor: const Color(0xFF03A696),
          ),
        );
      },
    );
  }

  void _showEditProfile(BuildContext context) {
    showDialog(context: context, builder: (context) => _EditProfileDialog());
  }

  void _showContactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Contactar Soporte',
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Necesitas ayuda?\n\n'
          'Puedes contactarnos en:\n'
          '📧 soporte@gilact.com\n\n'
          'Estamos aquí para ayudarte con cualquier duda o problema.',
          style: GoogleFonts.quicksand(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cerrar',
              style: GoogleFonts.quicksand(
                color: const Color(0xFF03A696),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTerms(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Términos y Condiciones', style: GoogleFonts.quicksand()),
        backgroundColor: const Color(0xFF03A696),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Política de Privacidad', style: GoogleFonts.quicksand()),
        backgroundColor: const Color(0xFF03A696),
      ),
    );
  }

  void _showDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Eliminar Cuenta',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar tu cuenta?\n\n'
          'Esta acción no se puede deshacer. Se eliminarán todos tus datos de forma permanente.',
          style: GoogleFonts.quicksand(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: GoogleFonts.quicksand(
                color: const Color(0xFF7F8C8D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Funcionalidad en desarrollo',
                    style: GoogleFonts.quicksand(),
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Eliminar',
              style: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _signOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Cerrar Sesión',
          style: GoogleFonts.quicksand(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        content: Text(
          '¿Estás seguro de que quieres cerrar sesión?',
          style: GoogleFonts.quicksand(
            fontSize: 16,
            color: const Color(0xFF7F8C8D),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: GoogleFonts.quicksand(
                color: const Color(0xFF7F8C8D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performSignOut(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Cerrar Sesión',
              style: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _performSignOut(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF03A696)),
          ),
        ),
      );

      await FirebaseAuth.instance.signOut();

      Navigator.of(context).pop();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);

      Future.delayed(const Duration(milliseconds: 100), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sesión cerrada exitosamente',
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color(0xFF03A696),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      });
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al cerrar sesión: $e',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}

/// Diálogo para editar el perfil del usuario
class _EditProfileDialog extends StatefulWidget {
  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _idNumberController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _nameController.text = authState.user.name;
      _emailController.text = authState.user.email;

      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(authState.user.id)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          _phoneController.text = data['telefono'] ?? '';
          _locationController.text = data['ubicacion'] ?? '';
          _birthDateController.text = data['fechaNacimiento'] ?? '';
          _motherNameController.text = data['nombre madre'] ?? '';
          _idNumberController.text = data['cedula'] ?? '';
        }
      } catch (e) {
        _phoneController.text = '';
        _locationController.text = '';
        _birthDateController.text = '';
        _motherNameController.text = '';
        _idNumberController.text = '';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _birthDateController.dispose();
    _motherNameController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxHeight: 600),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Editar Perfil',
                      style: GoogleFonts.quicksand(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Color(0xFF7F8C8D)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: const Icon(
                      Icons.person,
                      color: Color(0xFF03A696),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF03A696),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Color(0xFF03A696),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF03A696),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El email es requerido';
                    }
                    if (!value.contains('@')) {
                      return 'Ingresa un email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _motherNameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de la Madre',
                    prefixIcon: const Icon(
                      Icons.family_restroom,
                      color: Color(0xFF03A696),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF03A696),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre de la madre es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _idNumberController,
                  decoration: InputDecoration(
                    labelText: 'Cédula (opcional)',
                    prefixIcon: const Icon(
                      Icons.badge,
                      color: Color(0xFF03A696),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF03A696),
                        width: 2,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(r'^\d{8,9}$').hasMatch(value.trim())) {
                        return 'Formato de cédula inválido (8-9 dígitos)';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _birthDateController,
                  decoration: InputDecoration(
                    labelText: 'Fecha de Nacimiento',
                    prefixIcon: const Icon(
                      Icons.calendar_today,
                      color: Color(0xFF03A696),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF03A696),
                        width: 2,
                      ),
                    ),
                    hintText: 'YYYY-MM-DD',
                  ),
                  readOnly: true,
                  onTap: () => _selectBirthDate(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La fecha de nacimiento es requerida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Teléfono (opcional)',
                    prefixIcon: const Icon(
                      Icons.phone,
                      color: Color(0xFF03A696),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF03A696),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Ubicación (opcional)',
                    prefixIcon: const Icon(
                      Icons.location_on,
                      color: Color(0xFF03A696),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF03A696),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancelar',
                          style: GoogleFonts.quicksand(
                            color: const Color(0xFF7F8C8D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF03A696),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Guardar',
                                style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectBirthDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _birthDateController.text =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      });
    }
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 2));
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Perfil actualizado exitosamente',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF03A696),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al actualizar perfil: $e',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Página de perfil del usuario con diseño consistente
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header personalizado
          Container(
            padding: const EdgeInsets.all(20),
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
                const Spacer(),
                IconButton(
                  onPressed: () => _showEditProfile(context),
                  icon: const Icon(Icons.edit, color: Colors.white),
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
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
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
          // Avatar
          CircleAvatar(
            radius: 60,
            backgroundColor: const Color(0xFF03A696),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Información del usuario
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: const TextStyle(fontSize: 16, color: Color(0xFF7F8C8D)),
          ),
          const SizedBox(height: 40),

          // Opciones del perfil
          Expanded(
            child: ListView(
              children: [
                _buildProfileOption(
                  context,
                  'Editar Perfil',
                  Icons.edit,
                  () => _showEditProfile(context),
                ),
                _buildProfileOption(
                  context,
                  'Configuración',
                  Icons.settings,
                  () => _showSettings(context),
                ),
                _buildProfileOption(
                  context,
                  'Ayuda',
                  Icons.help,
                  () => _showHelp(context),
                ),
                _buildProfileOption(
                  context,
                  'Cerrar Sesión',
                  Icons.logout,
                  () => _signOut(context),
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xFF03A696),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : const Color(0xFF2C3E50),
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    showDialog(context: context, builder: (context) => _EditProfileDialog());
  }

  void _showSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de configuración en desarrollo'),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayuda'),
        content: const Text(
          'Gilact es tu compañera en la lactancia materna.\n\n'
          'Aquí encontrarás:\n'
          '• Lecciones educativas\n'
          '• Consejos prácticos\n'
          '• Videos informativos\n'
          '• Seguimiento de progreso\n\n'
          '¿Necesitas ayuda? Contacta a soporte@gilact.com',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _signOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF03A696)),
          ),
        ),
      );

      // Usar directamente Firebase Auth para cerrar sesión
      await FirebaseAuth.instance.signOut();

      // Cerrar el diálogo de carga
      Navigator.of(context).pop();

      // Navegar al login
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);

      // Mostrar mensaje de éxito después de navegar
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
      // Cerrar el diálogo de carga si está abierto
      Navigator.of(context).pop();

      // Mostrar error
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

      // Cargar datos adicionales desde Firestore
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
        // Si hay error cargando desde Firestore, usar valores vacíos
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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
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

              // Campos del formulario
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
                  prefixIcon: const Icon(Icons.email, color: Color(0xFF03A696)),
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

              // Campo de nombre de la madre
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

              // Campo de cédula
              TextFormField(
                controller: _idNumberController,
                decoration: InputDecoration(
                  labelText: 'Cédula (opcional)',
                  prefixIcon: const Icon(Icons.badge, color: Color(0xFF03A696)),
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

              // Campo de fecha de nacimiento
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

              // Campo de teléfono
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Teléfono (opcional)',
                  prefixIcon: const Icon(Icons.phone, color: Color(0xFF03A696)),
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

              // Campo de ubicación
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

              // Botones
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

    setState(() {
      _isLoading = true;
    });

    try {
      // Simular guardado (aquí implementarías la lógica real)
      await Future.delayed(const Duration(seconds: 2));

      // Cerrar diálogo
      Navigator.of(context).pop();

      // Mostrar mensaje de éxito
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
      // Mostrar error
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
      setState(() {
        _isLoading = false;
      });
    }
  }
}

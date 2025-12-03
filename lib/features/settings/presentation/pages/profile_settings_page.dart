import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../user/presentation/bloc/user_profile_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../widgets/user_info_card_widget.dart';
import '../widgets/app_settings_card_widget.dart';
import '../widgets/help_support_card_widget.dart';
import '../widgets/account_card_widget.dart';
import '../widgets/app_info_card_widget.dart';
import '../../../../core/services/sound_service.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/interactive_button.dart';

/// Página de perfil y configuraciones usando clean architecture
class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  Map<String, dynamic> _localSettings = {};
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadLocalSettings();
  }

  void _loadLocalSettings() {
    context.read<SettingsBloc>().add(const GetLocalSettingsRequested());
  }

  void _handleSettingChanged(String key, dynamic value) async {
    // Feedback háptico y sonoro al cambiar configuración
    final soundService = GetIt.instance<SoundService>();
    final vibrationService = GetIt.instance<VibrationService>();

    await Future.wait([
      soundService.playClickSound(),
      vibrationService.selectionClick(),
    ]);

    if (!mounted) return;

    context.read<SettingsBloc>().add(
      UpdateLocalSettingRequested(key: key, value: value),
    );

    // Si se cambió el idioma, actualizar EasyLocalization
    if (key == 'language') {
      await context.setLocale(Locale(value));

      if (!mounted) return;
    }
  }

  void _showPasswordDialogForReauthentication(BuildContext context) {
    final passwordController = TextEditingController();
    bool isProcessing = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthUnauthenticated) {
                // La cuenta fue eliminada exitosamente
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'account.deleteAccountSuccess'.tr(),
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: const Color(0xFF03A696),
                    duration: const Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              } else if (state is AuthFailure) {
                setDialogState(() {
                  isProcessing = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
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
              } else if (state is AuthLoading) {
                setDialogState(() {
                  isProcessing = true;
                });
              }
            },
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Reautenticación Requerida',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Para eliminar tu cuenta, necesitamos verificar tu identidad. Por favor, ingresa tu contraseña:',
                    style: GoogleFonts.quicksand(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    enabled: !isProcessing,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  if (isProcessing) ...[
                    const SizedBox(height: 16),
                    const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF03A696)),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isProcessing
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.quicksand(
                      color: const Color(0xFF7F8C8D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isProcessing
                      ? null
                      : () {
                          final password = passwordController.text.trim();
                          if (password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Por favor ingresa tu contraseña'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          // Intentar eliminar cuenta con la contraseña
                          context.read<AuthBloc>().add(
                            DeleteAccountRequested(password: password),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Eliminar',
                          style: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleDeleteAccount() async {
    try {
      // Mostrar diálogo de confirmación
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'account.deleteAccountConfirmTitle'.tr(),
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: Text(
            'account.deleteAccountConfirmMessage'.tr(),
            style: GoogleFonts.quicksand(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'account.cancel'.tr(),
                style: GoogleFonts.quicksand(
                  color: const Color(0xFF7F8C8D),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'account.delete'.tr(),
                style: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );

      if (confirm != true || !mounted) return;

      // Mostrar loading (se cerrará automáticamente cuando el BlocListener reciba el resultado)
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF03A696)),
          ),
        ),
      );

      // Eliminar cuenta usando AuthBloc
      // El BlocListener cerrará el loading y navegará al login cuando termine
      context.read<AuthBloc>().add(const DeleteAccountRequested());
    } catch (e) {
      if (mounted) {
        // Cerrar loading si está abierto
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al eliminar cuenta: ${e.toString()}',
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

  void _handleSignOut() async {
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

      // Resetear UserProfileBloc antes de cerrar sesión
      context.read<UserProfileBloc>().add(const ResetUserProfileRequested());
      
      // Esperar un momento para que el reset se complete
      await Future.delayed(const Duration(milliseconds: 100));

      await FirebaseAuth.instance.signOut();

      if (mounted) {
        Navigator.of(context).pop(); // Cerrar loading
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);

        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'account.signOutSuccess'.tr(),
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
          }
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${'account.signOutError'.tr()}: $e',
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocListener(
        listeners: [
          BlocListener<SettingsBloc, SettingsState>(
            listener: (context, state) {
              if (state is LocalSettingsLoaded) {
                setState(() {
                  _localSettings = state.settings;
                  _appVersion = state.settings['appVersion'] ?? '1.0.0';
                });
              } else if (state is LocalSettingUpdated) {
                // Recargar configuraciones después de actualizar
                _loadLocalSettings();
              } else if (state is SettingsFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthUnauthenticated) {
                // Cerrar el diálogo de loading si está abierto
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
                
                // La cuenta fue eliminada exitosamente, navegar al login
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
                
                // Mostrar mensaje de éxito después de un pequeño delay
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'account.deleteAccountSuccess'.tr(),
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: const Color(0xFF03A696),
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }
                });
              } else if (state is AuthFailure) {
                // Cerrar el diálogo de loading si está abierto
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
                
                // Si el error es que requiere reautenticación, mostrar diálogo para pedir contraseña
                if (state.message.contains('REQUIRES_RECENT_LOGIN') || 
                    state.message.contains('reautenticación')) {
                  _showPasswordDialogForReauthentication(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.message,
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
            },
          ),
        ],
        child: Column(
          children: [
            // Header personalizado
            Container(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Row(
                children: [
                  Text(
                    'profile.title'.tr(),
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
                builder: (context, authState) {
                  if (authState is AuthAuthenticated) {
                    return _buildProfileContent(context, authState.user);
                  } else {
                    return Center(
                      child: Text(
                        'profile.noUserAuthenticated'.tr(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, user) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth > 600
                  ? (constraints.maxWidth - 600) / 2
                  : 20,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tarjeta de información del usuario
                UserInfoCardWidget(
                  userName: user.name,
                  userEmail: user.email,
                  onEditProfile: () => _showEditProfile(context, user),
                ),
                const SizedBox(height: 20),

                // Sección: Configuración de la aplicación
                _buildSectionTitle('settings.title'.tr(), constraints),
                const SizedBox(height: 12),
                AppSettingsCardWidget(
                  localSettings: _localSettings,
                  onSettingChanged: _handleSettingChanged,
                ),

                const SizedBox(height: 20),

                // Sección: Ayuda y Soporte
                _buildSectionTitle('help.title'.tr(), constraints),
                const SizedBox(height: 12),
                const HelpSupportCardWidget(),

                const SizedBox(height: 20),

                // Sección: Cuenta
                _buildSectionTitle('account.title'.tr(), constraints),
                const SizedBox(height: 12),
                AccountCardWidget(
                  onSignOut: _handleSignOut,
                  onDeleteAccount: _handleDeleteAccount,
                ),

                const SizedBox(height: 20),

                // Información de la app
                AppInfoCardWidget(appVersion: _appVersion),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, BoxConstraints constraints) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: constraints.maxWidth > 600 ? 0 : 4,
      ),
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

  void _showEditProfile(BuildContext context, user) {
    showDialog(
      context: context,
      builder: (context) => _EditProfileDialog(user: user),
    );
  }
}

/// Diálogo para editar el perfil del usuario
class _EditProfileDialog extends StatefulWidget {
  final dynamic user;

  const _EditProfileDialog({required this.user});

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final AppLogger _logger = getIt<AppLogger>();
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
    _nameController.text = widget.user.name;
    _emailController.text = widget.user.email;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.user.id)
          .get();

      if (!mounted) return;

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        _phoneController.text = data['telefono'] ?? '';
        _locationController.text = data['ubicacion'] ?? '';
        _birthDateController.text = data['fechaNacimiento'] ?? '';
        _motherNameController.text = data['nombre madre'] ?? '';
        _idNumberController.text = data['cedula'] ?? '';
      }
    } catch (e) {
      if (!mounted) return;
      // Ignorar errores
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
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'profile.editProfile'.tr(),
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
                    labelText: 'profile.name'.tr(),
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
                      return 'validation.nameRequired'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'profile.email'.tr(),
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
                      return 'validation.emailRequired'.tr();
                    }
                    if (!value.contains('@')) {
                      return 'validation.validEmail'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _motherNameController,
                  decoration: InputDecoration(
                    labelText: 'profile.motherName'.tr(),
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
                      return 'validation.motherNameRequired'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _idNumberController,
                  decoration: InputDecoration(
                    labelText: 'profile.idNumberOptional'.tr(),
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
                        return 'validation.invalidIdNumber'.tr();
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _birthDateController,
                  decoration: InputDecoration(
                    labelText: 'profile.birthDate'.tr(),
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
                      return 'validation.birthDateRequired'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'profile.phoneOptional'.tr(),
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
                    labelText: 'profile.locationOptional'.tr(),
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
                          'common.cancel'.tr(),
                          style: GoogleFonts.quicksand(
                            color: const Color(0xFF7F8C8D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InteractiveButton(
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
                                'common.save'.tr(),
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

    if (!mounted) return;

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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      // Obtener el ID del documento del usuario en Firestore
      String? userDocId;
      if (user.email != null) {
        final userQuery = await FirebaseFirestore.instance
            .collection('Users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();

        if (!mounted) return;

        if (userQuery.docs.isNotEmpty) {
          userDocId = userQuery.docs.first.id;
        }
      }
      userDocId ??= user.uid;

      // Actualizar nombre en Firebase Auth
      if (_nameController.text.trim() != user.displayName) {
        await user.updateDisplayName(_nameController.text.trim());

        if (!mounted) return;
      }

      // Actualizar email en Firebase Auth si cambió
      if (_emailController.text.trim() != user.email) {
        await user.verifyBeforeUpdateEmail(_emailController.text.trim());

        if (!mounted) return;
      }

      // Calcular edad si hay fecha de nacimiento
      int? age;
      if (_birthDateController.text.isNotEmpty) {
        try {
          final birthDate = DateTime.parse(_birthDateController.text);
          final today = DateTime.now();
          age = today.year - birthDate.year;
          if (today.month < birthDate.month ||
              (today.month == birthDate.month && today.day < birthDate.day)) {
            age--;
          }
        } catch (e) {
          // Ignorar error de parsing
        }
      }

      // Actualizar en Firestore
      final userDocRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(userDocId);

      await userDocRef.update({
        'usuario': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'nombre madre': _motherNameController.text.trim(),
        'cedula': _idNumberController.text.trim(),
        'fechaNacimiento': _birthDateController.text.trim(),
        if (age != null) 'edad': age,
        'telefono': _phoneController.text.trim(),
        'ubicacion': _locationController.text.trim(),
      });

      if (!mounted) return;

      // Actualizar perfil usando UserProfileBloc si está disponible
      try {
        context.read<UserProfileBloc>().add(
          UpdateUserProfileRequested(
            userId: user.uid,
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            location: _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim(),
            birthDate: _birthDateController.text.isNotEmpty
                ? DateTime.tryParse(_birthDateController.text)
                : null,
            age: age,
            idNumber: _idNumberController.text.trim().isEmpty
                ? null
                : _idNumberController.text.trim(),
          ),
        );
      } catch (e) {
        // Si no hay UserProfileBloc disponible, continuar sin error
        _logger.w('UserProfileBloc no disponible: $e');
      }

      // Feedback de éxito
      final soundService = GetIt.instance<SoundService>();
      final vibrationService = GetIt.instance<VibrationService>();
      await Future.wait([
        soundService.playSuccessSound(),
        vibrationService.vibrateOnSuccess(),
      ]);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'messages.profileUpdatedSuccess'.tr(),
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
      }
    } catch (e) {
      // Feedback de error
      final soundService = GetIt.instance<SoundService>();
      final vibrationService = GetIt.instance<VibrationService>();
      await Future.wait([
        soundService.playErrorSound(),
        vibrationService.vibrateOnError(),
      ]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${'messages.profileUpdateError'.tr()}: ${e.toString()}',
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

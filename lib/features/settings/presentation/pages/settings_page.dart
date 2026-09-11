 import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/settings_entities.dart';
import '../bloc/settings_bloc.dart';
import '../widgets/settings_widget.dart';
import '../widgets/feedback_form_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  void _loadUserSettings() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<SettingsBloc>().add(
        GetAppConfigurationRequested(userId: user.uid),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Configuración',
          style: GoogleFonts.quicksand(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is AppConfigurationSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Configuración guardada exitosamente'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is FeedbackMessageSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mensaje enviado exitosamente'),
                backgroundColor: AppColors.success,
              ),
            );
            _feedbackController.clear();
          }
        },
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            if (state is SettingsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección de cuenta
                  _buildSectionHeader('Cuenta'),
                  const SizedBox(height: 16),

                  // Formulario de sugerencias
                  _buildFeedbackSection(),

                  const SizedBox(height: 24),

                  // Sección de configuración de la aplicación
                  _buildSectionHeader('Configuración de la Aplicación'),
                  const SizedBox(height: 16),

                  // Widget de configuración
                  if (state is AppConfigurationLoaded)
                    SettingsWidget(
                      configuration: state.configuration,
                      onConfigurationChanged: (updates) {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          context.read<SettingsBloc>().add(
                            UpdateAppConfigurationRequested(
                              userId: user.uid,
                              updates: updates,
                            ),
                          );
                        }
                      },
                    ),

                  const SizedBox(height: 24),

                  // Botón de cerrar sesión
                  _buildLogoutButton(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.quicksand(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enviar un formulario de sugerencias de la aplicación',
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            FeedbackFormWidget(
              controller: _feedbackController,
              onSend: _sendFeedback,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _logout,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Cerrar Sesión',
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _sendFeedback() {
    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, escribe un mensaje'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final feedbackMessage = FeedbackMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.uid,
        message: _feedbackController.text.trim(),
        type: 'suggestion',
        status: 'pending',
        createdAt: DateTime.now(),
      );

      context.read<SettingsBloc>().add(
        SaveFeedbackMessageRequested(message: feedbackMessage),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
}

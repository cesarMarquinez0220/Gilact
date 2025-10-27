import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import '../../../chatbot/presentation/pages/chatbot_page.dart';
import '../../../chatbot/presentation/bloc/chatbot_bloc.dart';

/// Página de salud del bebé con diseño consistente
class HealthPage extends StatelessWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header personalizado
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    'Salud del Bebé',
                    style: GoogleFonts.quicksand(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      // Mostrar estadísticas de salud
                    },
                    icon: const Icon(Icons.analytics, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Tarjetas de funcionalidades de salud
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Seguimiento de peso
                  _buildHealthCard(
                    'Peso del Bebé',
                    'Registra el peso diario',
                    Icons.monitor_weight,
                    const Color(0xFF4CAF50),
                    () {
                      _showDevelopmentMessage(context, 'Registro de Peso');
                    },
                  ),
                  const SizedBox(height: 16),

                  // Registro de temperatura
                  _buildHealthCard(
                    'Temperatura',
                    'Control de fiebre',
                    Icons.thermostat,
                    const Color(0xFFFF9800),
                    () {
                      _showDevelopmentMessage(
                        context,
                        'Registro de Temperatura',
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // ChatBot
                  _buildHealthCard(
                    'ChatBot',
                    'Chat con el chatbot',
                    Icons.chat,
                    const Color(0xFF03A696),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => GetIt.instance<ChatbotBloc>(),
                            child: const ChatbotPage(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Emergencias
                  _buildHealthCard(
                    'Emergencias',
                    'Contactos de emergencia',
                    Icons.emergency,
                    const Color(0xFFF44336),
                    () {
                      _showDevelopmentMessage(
                        context,
                        'Contactos de Emergencia',
                      );
                    },
                  ),
                  const SizedBox(height: 100), // Espacio para el bottom bar
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  /// Muestra un mensaje de que la funcionalidad está en desarrollo
  void _showDevelopmentMessage(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$featureName está en desarrollo. Pronto estará disponible.',
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF03A696),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

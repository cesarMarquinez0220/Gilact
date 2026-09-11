import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/settings_bloc.dart';
import '../widgets/statistics_widget.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  void initState() {
    super.initState();
    _loadUserStatistics();
  }

  void _loadUserStatistics() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<SettingsBloc>().add(
        GetUserStatisticsRequested(userId: user.uid),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Estadísticas',
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
          }
        },
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            if (state is SettingsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is UserStatisticsLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título principal
                    Text(
                      'Cantidad de Vistas por Video',
                      style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Widget de estadísticas
                    StatisticsWidget(statistics: state.statistics),

                    const SizedBox(height: 24),

                    // Resumen de estadísticas
                    _buildStatisticsSummary(state.statistics),
                  ],
                ),
              );
            }

            return const Center(
              child: Text(
                'No se pudieron cargar las estadísticas',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatisticsSummary(statistics) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de Actividad',
              style: GoogleFonts.quicksand(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            _buildSummaryItem(
              'Videos Vistos',
              statistics.totalVideosWatched.toString(),
              Icons.play_circle_outline,
            ),
            const SizedBox(height: 12),

            _buildSummaryItem(
              'Lecciones Completadas',
              statistics.totalLessonsCompleted.toString(),
              Icons.school_outlined,
            ),
            const SizedBox(height: 12),

            _buildSummaryItem(
              'Contenido Completado',
              statistics.totalContentCompleted.toString(),
              Icons.check_circle_outline,
            ),
            const SizedBox(height: 12),

            _buildSummaryItem(
              'Tiempo Total',
              _formatTime(statistics.totalTimeSpent),
              Icons.access_time,
            ),
            const SizedBox(height: 12),

            _buildSummaryItem(
              'Sesiones Totales',
              statistics.totalSessions.toString(),
              Icons.timeline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.quicksand(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}

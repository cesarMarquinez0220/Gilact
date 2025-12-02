import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gilact/features/lactation/presentation/pages/daily_sleep_form_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../chatbot/presentation/pages/chatbot_page.dart';
import '../../../chatbot/presentation/bloc/chatbot_bloc.dart';
import '../../../lactation/data/datasources/baby_weight_offline_local_data_source.dart';
import '../../../lactation/domain/entities/baby_weight_record.dart';
import '../../../lactation/data/datasources/sleep_offline_local_data_source.dart';
import '../../../lactation/domain/entities/sleep_record.dart';
import '../../../user/presentation/bloc/user_profile_bloc.dart';

/// Página de salud del bebé con diseño mejorado y funcionalidades adicionales
class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  BabyWeightRecord? _lastWeightRecord;
  SleepRecord? _lastSleepRecord;

  @override
  void initState() {
    super.initState();
    _loadRecentData();
  }

  Future<void> _loadRecentData() async {
    try {
      // Cargar último registro de peso
      final weightDataSource = BabyWeightOfflineLocalDataSource();
      final weightRecords = await weightDataSource.getAllRecords();
      if (weightRecords.isNotEmpty) {
        weightRecords.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
        if (mounted) {
          setState(() {
            _lastWeightRecord = weightRecords.first;
          });
        }
      }

      // Cargar último registro de sueño
      final sleepDataSource = SleepOfflineLocalDataSource();
      final sleepRecords = await sleepDataSource.getAllRecords();
      if (sleepRecords.isNotEmpty) {
        sleepRecords.sort(
          (a, b) => b.sleepStartTime.compareTo(a.sleepStartTime),
        );
        if (mounted) {
          setState(() {
            _lastSleepRecord = sleepRecords.first;
          });
        }
      }
    } catch (e) {
      // Si hay error, continuar sin datos recientes
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, userState) {
          // Determinar si es preparto o postparto
          bool isPrePartum = false;
          bool isPostPartum = false;
          
          if (userState is UserProfileLoaded) {
            isPrePartum = userState.profile.isPrePartum;
            isPostPartum = userState.profile.isPostPartum;
          } else if (userState is UserProfileUpdated) {
            isPrePartum = userState.profile.isPrePartum;
            isPostPartum = userState.profile.isPostPartum;
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: Row(
                  children: [
                    Text(
                      'health.title'.tr(),
                      style: GoogleFonts.quicksand(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _loadRecentData(),
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      tooltip: 'health.refresh'.tr(),
                    ),
                  ],
                ),
              ),
              // Contenido scrollable
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Solo mostrar "Seguimiento de Crecimiento" si es postparto
                        if (isPostPartum) ...[
                          _buildSectionTitle('health.growthTracking'.tr()),
                          const SizedBox(height: 12),
                          _buildEnhancedHealthCard(
                            context,
                            title: 'health.babyWeight'.tr(),
                            subtitle: 'health.babyWeightDescription'.tr(),
                            icon: Icons.monitor_weight_rounded,
                            color: const Color(0xFF4CAF50),
                            onTap: () {
                              Navigator.of(context).pushNamed('/baby-weight-form');
                            },
                            lastRecord: _lastWeightRecord != null
                                ? '${'health.last'.tr()} ${_lastWeightRecord!.weight.toStringAsFixed(2)} kg'
                                : 'lactation.calendar.noRecordsText'.tr(),
                            recordDate: _lastWeightRecord?.recordedAt,
                            badge: _lastWeightRecord != null ? 'health.active'.tr() : null,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Solo mostrar "Bienestar Diario" si es postparto
                        if (isPostPartum) ...[
                          _buildSectionTitle('health.dailyWellness'.tr()),
                          const SizedBox(height: 12),
                          _buildEnhancedHealthCard(
                            context,
                            title: 'health.sleep'.tr(),
                            subtitle: 'health.sleepDescription'.tr(),
                            icon: Icons.bedtime_rounded,
                            color: const Color(0xFFFF9800),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DailySleepFormPage(),
                                ),
                              );
                            },
                            lastRecord: _lastSleepRecord != null
                                ? '${'health.last'.tr()} ${_lastSleepRecord!.totalSleepDuration.inHours.toStringAsFixed(1)} horas'
                                : 'lactation.calendar.noRecordsText'.tr(),
                            recordDate: _lastSleepRecord?.sleepStartTime,
                            badge: _lastSleepRecord != null ? 'health.active'.tr() : null,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Sección: Asistencia (para ambos perfiles)
                        _buildSectionTitle('health.assistanceHelp'.tr()),
                        const SizedBox(height: 12),
                        _buildEnhancedHealthCard(
                          context,
                          title: 'health.assistant'.tr(),
                          subtitle: 'health.assistantDescription'.tr(),
                          icon: Icons.smart_toy_rounded,
                          color: const Color(0xFF03A696),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) =>
                                      GetIt.instance<ChatbotBloc>(),
                                  child: const ChatbotPage(),
                                ),
                              ),
                            );
                          },
                          lastRecord: 'health.available247'.tr(),
                          badge: 'health.new'.tr(),
                          badgeColor: Colors.blue,
                        ),
                        const SizedBox(height: 100), // Espacio para el bottom bar
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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

  Widget _buildEnhancedHealthCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? lastRecord,
    DateTime? recordDate,
    String? badge,
    Color? badgeColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icono con fondo degradado
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.quicksand(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                        ),
                        if (badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: (badgeColor ?? color).withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: (badgeColor ?? color).withValues(
                                  alpha: 0.3,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              badge,
                              style: GoogleFonts.quicksand(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: badgeColor ?? color,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        color: const Color(0xFF7F8C8D),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (lastRecord != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            lastRecord,
                            style: GoogleFonts.quicksand(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (recordDate != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(recordDate),
                              style: GoogleFonts.quicksand(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Flecha
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[600],
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDay = DateTime(date.year, date.month, date.day);
    final difference = today.difference(recordDay).inDays;

    if (difference == 0) {
      return 'health.today'.tr();
    } else if (difference == 1) {
      return 'health.yesterday'.tr();
    } else if (difference < 7) {
      return 'health.daysAgo'.tr(namedArgs: {'days': difference.toString()});
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
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
import '../widgets/home_feature_card.dart';
import '../providers/health_provider.dart';
import '../../../../core/theme/app_colors.dart';

/// Página de salud del bebé con diseño mejorado y funcionalidades adicionales
class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  bool _hasLoadedInitialData = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar datos cuando la página se vuelve visible (útil cuando se guarda un registro)
    // Usar addPostFrameCallback para evitar llamar notifyListeners durante el build
    if (!_hasLoadedInitialData) {
      _hasLoadedInitialData = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final provider = context.read<HealthProvider>();
          provider.loadRecentData();
        }
      });
    } else {
      // Si ya se cargó inicialmente, recargar cuando cambian las dependencias
      // (útil cuando se vuelve a la página después de guardar un registro)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final provider = context.read<HealthProvider>();
          provider.loadRecentData();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, userState) {
          // Determinar si es postparto
          bool isPostPartum = false;

          if (userState is UserProfileLoaded) {
            isPostPartum = userState.profile.isPostPartum;
          } else if (userState is UserProfileUpdated) {
            isPostPartum = userState.profile.isPostPartum;
          }

          return Consumer<HealthProvider>(
            builder: (context, healthProvider, _) {
              final lastWeightRecord = healthProvider.lastWeightRecord;
              final lastSleepRecord = healthProvider.lastSleepRecord;

              final screenWidth = MediaQuery.of(context).size.width;
              final screenHeight = MediaQuery.of(context).size.height;
              final isSmallScreen = screenWidth < 360;
              final isShortScreen = screenHeight < 700;

              return Column(
                children: [
                  // Header consistente con padding igual a Companion
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.favorite_rounded,
                                color: Colors.white,
                                size: isSmallScreen ? 22 : 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'health.title'.tr(),
                                    style: GoogleFonts.quicksand(
                                      fontSize: isSmallScreen ? 22 : 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.2,
                                          ),
                                          offset: const Offset(0, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: isShortScreen ? 2 : 4),
                                  Text(
                                    'health.subtitle'.tr(),
                                    style: GoogleFonts.quicksand(
                                      fontSize: isSmallScreen ? 13 : 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isShortScreen ? 12 : 16),
                        // Separador inferior completamente blanco
                        Container(height: 1, color: Colors.white),
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
                              _buildHealthCardWithRecords(
                                context,
                                title: 'health.babyWeight'.tr(),
                                subtitle: 'health.babyWeightDescription'.tr(),
                                icon: Icons.monitor_weight_rounded,
                                color: const Color(0xFF4CAF50),
                                onTap: () async {
                                  final result = await Navigator.of(
                                    context,
                                  ).pushNamed('/baby-weight-form');
                                  // Recargar datos cuando se vuelve de guardar un registro
                                  if (result == true || result != null) {
                                    healthProvider.refresh();
                                  }
                                },
                                lastRecord: lastWeightRecord != null
                                    ? '${'health.last'.tr()} ${lastWeightRecord!.weight.toStringAsFixed(2)} kg'
                                    : 'lactation.calendar.noRecordsText'.tr(),
                                recordDate: lastWeightRecord?.recordedAt,
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Solo mostrar "Bienestar Diario" si es postparto
                            if (isPostPartum) ...[
                              _buildSectionTitle('health.dailyWellness'.tr()),
                              const SizedBox(height: 12),
                              _buildHealthCardWithRecords(
                                context,
                                title: 'health.sleep'.tr(),
                                subtitle: 'health.sleepDescription'.tr(),
                                icon: Icons.bedtime_rounded,
                                color: const Color(0xFFFF9800),
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DailySleepFormPage(),
                                    ),
                                  );
                                  // Recargar datos cuando se vuelve de guardar un registro
                                  if (result == true || result != null) {
                                    healthProvider.refresh();
                                  }
                                },
                                lastRecord: lastSleepRecord != null
                                    ? '${'health.last'.tr()} ${lastSleepRecord!.totalSleepDuration.inHours.toStringAsFixed(1)} horas'
                                    : 'lactation.calendar.noRecordsText'.tr(),
                                recordDate: lastSleepRecord?.sleepStartTime,
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Sección: Asistencia (para ambos perfiles)
                            _buildSectionTitle('health.assistanceHelp'.tr()),
                            const SizedBox(height: 12),
                            HomeFeatureCard(
                              title: 'health.assistant'.tr(),
                              icon: Icons.smart_toy_rounded,
                              description: 'health.assistantDescription'.tr(),
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
                              color: const Color(0xFF03A696),
                            ),
                            const SizedBox(
                              height: 100,
                            ), // Espacio para el bottom bar
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
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

  Widget _buildHealthCardWithRecords(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? lastRecord,
    DateTime? recordDate,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Icono en la esquina superior derecha
            Positioned(
              top: 15,
              right: 15,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 22),
              ),
            ),

            // Contenido principal
            Positioned(
              bottom: 15,
              left: 15,
              right: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF7F8C8D),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (lastRecord != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            lastRecord,
                            style: GoogleFonts.quicksand(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (recordDate != null) ...[
                          Text(
                            _formatDate(recordDate),
                            style: GoogleFonts.quicksand(
                              fontSize: 10,
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
          ],
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

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;
import '../../../user/presentation/bloc/user_profile_bloc.dart';
import '../../../lactation/domain/entities/lactation_record.dart';
import '../../../lactation/presentation/providers/lactation_provider.dart';
import '../../../lactation/presentation/widgets/smart_lactation_button.dart';
import '../widgets/modern_header.dart';
import '../widgets/home_feature_card.dart';
import '../widgets/countdown_card.dart';
import '../widgets/postparto_profile_widget.dart';
import '../widgets/offline_badge.dart';
import '../widgets/sync_indicator.dart';
import '../../domain/services/navigation_service.dart';
import '../../domain/services/app_color_service.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/offline_sync_service.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/utils/responsive_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../../../onboarding/data/services/user_subcollections_service.dart';
import '../../../gamification/presentation/bloc/gamification_bloc.dart';
import '../../../gamification/presentation/bloc/gamification_state.dart';
import '../../../gamification/presentation/bloc/gamification_event.dart';
import '../../../gamification/domain/repositories/gamification_repository.dart';
import '../../../gamification/domain/entities/daily_streak.dart';
import '../../../gamification/domain/entities/user_gamification_profile.dart';
import '../../../gamification/domain/services/level_service.dart';
import '../../../gamification/domain/services/streak_service.dart';
import 'package:percent_indicator/percent_indicator.dart';

/// Página principal de inicio con diseño consistente y arquitectura limpia
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppLogger _logger = getIt<AppLogger>();
  final ConnectivityService _connectivityService = ConnectivityService();
  StreamSubscription<bool>? _connectivitySubscription;
  bool _wasOffline = false;

  @override
  void initState() {
    super.initState();
    // Cargar datos iniciales usando el Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LactationProvider>();
      provider.loadTodayData();
      provider.loadWeekData();

      // Cargar perfil de gamificación inmediatamente para actualización instantánea
      _loadGamificationProfileIfNeeded();
    });

    // Escuchar cambios de conectividad
    _connectivitySubscription = _connectivityService.connectivityStream.listen((
      isConnected,
    ) async {
      // Si estaba offline y ahora hay conexión, recargar datos
      if (_wasOffline && isConnected) {
        if (mounted) {
          _logger.d('HomePage: Conexión restaurada, recargando datos...');
          await _reloadDataOnConnectionRestored();
        }
      }
      _wasOffline = !isConnected;
    });

    // Verificar estado inicial de conectividad
    _connectivityService.isConnected().then((isConnected) {
      _wasOffline = !isConnected;
    });
  }

  /// Carga el perfil de gamificación si es necesario
  void _loadGamificationProfileIfNeeded() {
    if (!mounted) return;

    try {
      final userProfileBloc = context.read<UserProfileBloc>();
      final userState = userProfileBloc.state;

      String? userId;
      if (userState is UserProfileLoaded) {
        userId = userState.profile.id;
      } else if (userState is UserProfileUpdated) {
        userId = userState.profile.id;
      }

      if (userId != null && userId.isNotEmpty) {
        final gamificationBloc = context.read<GamificationBloc>();
        final currentState = gamificationBloc.state;

        // Cargar perfil si:
        // 1. El estado es inicial (después de reset o primera carga)
        // 2. El estado no está cargado
        // 3. El userId no coincide con el perfil actual
        if (currentState is GamificationInitial) {
          gamificationBloc.add(LoadGamificationProfile(userId));
        } else if (currentState is! GamificationLoaded) {
          gamificationBloc.add(LoadGamificationProfile(userId));
        } else if (currentState.profile.userId != userId) {
          gamificationBloc.add(LoadGamificationProfile(userId));
        }
      }
    } catch (e) {
      // Ignorar errores silenciosamente
      if (kDebugMode) {
        _logger.w('Error cargando perfil de gamificación: $e');
      }
    }
  }

  /// Recarga los datos cuando se restaura la conexión
  Future<void> _reloadDataOnConnectionRestored() async {
    if (!mounted) return;

    try {
      _logger.d(
        'HomePage: Iniciando recarga de datos después de restaurar conexión...',
      );

      // 1. Obtener userId correcto (buscando por email si es necesario)
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _logger.w('HomePage: No hay usuario autenticado');
        return;
      }

      String? userId = await _getUserDocumentId(user);

      if (!mounted) return;

      if (userId == null || userId.isEmpty) {
        _logger.w(
          'HomePage: No se pudo obtener userId, intentando desde estado...',
        );
        // Fallback: intentar obtener del estado del bloc
        final userProfileBloc = context.read<UserProfileBloc>();
        final currentState = userProfileBloc.state;

        if (currentState is UserProfileLoaded) {
          userId = currentState.profile.id;
        } else if (currentState is UserProfileUpdated) {
          userId = currentState.profile.id;
        }
      }

      if (userId == null || userId.isEmpty) {
        _logger.e('HomePage: No se pudo obtener userId de ninguna fuente');
        return;
      }

      _logger.d('HomePage: userId obtenido: $userId');

      // 2. Recargar perfil de usuario desde Firestore
      final userProfileBloc = context.read<UserProfileBloc>();
      _logger.d('HomePage: Solicitando recarga de perfil...');
      userProfileBloc.add(GetUserProfileRequested(userId: userId));

      // 3. Esperar a que el perfil se cargue (con timeout)
      await _waitForProfileToLoad(userProfileBloc, timeoutSeconds: 10);

      // 3.5. Cargar y actualizar información de situación (CRÍTICO para mostrar PostpartoProfileWidget)
      if (mounted) {
        await _reloadSituationData(userId, userProfileBloc);
      }

      // 4. Recargar datos de lactancia
      if (mounted) {
        final provider = context.read<LactationProvider>();
        provider.loadTodayData();
        provider.loadWeekData();
      }

      // 5. Forzar sincronización de datos pendientes
      final offlineSyncService = getIt<OfflineSyncService>();
      offlineSyncService.forceSync();

      _logger.success(
        'HomePage: Datos recargados exitosamente después de restaurar conexión',
      );
    } catch (e, stackTrace) {
      _logger.e('HomePage: Error recargando datos', e, stackTrace);
      // Intentar recargar desde cache como fallback
      if (mounted) {
        await _reloadFromCache();
      }
    }
  }

  /// Obtiene el ID del documento del usuario en Firestore (buscando por email primero)
  Future<String?> _getUserDocumentId(User user) async {
    try {
      // PRIORIDAD 1: Buscar por email (más confiable)
      if (user.email != null) {
        _logger.d('HomePage: Buscando usuario por email: ${user.email}');

        final userQuery = await FirebaseFirestore.instance
            .collection('Users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get()
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                _logger.w('HomePage: Timeout buscando usuario por email');
                return FirebaseFirestore.instance
                    .collection('Users')
                    .where('email', isEqualTo: user.email)
                    .limit(1)
                    .get();
              },
            );

        if (userQuery.docs.isNotEmpty) {
          final userDocId = userQuery.docs.first.id;
          _logger.d('HomePage: Usuario encontrado por email, ID: $userDocId');
          return userDocId;
        } else {
          _logger.w(
            'HomePage: No se encontró usuario por email: ${user.email}',
          );
        }
      }

      // PRIORIDAD 2: Intentar con UID directamente (fallback)
      _logger.d('HomePage: Intentando con UID como fallback: ${user.uid}');
      final docSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              _logger.w('HomePage: Timeout buscando usuario por UID');
              return FirebaseFirestore.instance
                  .collection('Users')
                  .doc(user.uid)
                  .get();
            },
          );

      if (docSnapshot.exists) {
        _logger.w(
          'HomePage: Usuario encontrado con UID (fallback): ${user.uid}',
        );
        return user.uid;
      }

      _logger.e('HomePage: No se encontró usuario en Firestore');
      return null;
    } catch (e, stackTrace) {
      _logger.e('HomePage: Error obteniendo userId', e, stackTrace);
      return null;
    }
  }

  /// Espera a que el perfil se cargue completamente
  Future<void> _waitForProfileToLoad(
    UserProfileBloc bloc, {
    int timeoutSeconds = 10,
  }) async {
    if (!mounted) return;

    try {
      final completer = Completer<void>();
      StreamSubscription? subscription;
      Timer? timeoutTimer;

      // Configurar timeout
      timeoutTimer = Timer(Duration(seconds: timeoutSeconds), () {
        if (!completer.isCompleted) {
          _logger.w('HomePage: Timeout esperando perfil');
          subscription?.cancel();
          completer.complete();
        }
      });

      // Escuchar cambios de estado
      subscription = bloc.stream.listen((state) {
        if (state is UserProfileLoaded || state is UserProfileUpdated) {
          _logger.success('HomePage: Perfil cargado exitosamente');
          timeoutTimer?.cancel();
          subscription?.cancel();
          if (!completer.isCompleted) {
            completer.complete();
          }
        } else if (state is UserProfileFailure) {
          _logger.e('HomePage: Error cargando perfil: ${state.message}');
          timeoutTimer?.cancel();
          subscription?.cancel();
          if (!completer.isCompleted) {
            completer.complete();
          }
        }
      });

      await completer.future;
    } catch (e, stackTrace) {
      _logger.e('HomePage: Error esperando perfil', e, stackTrace);
    }
  }

  /// Construye la tarjeta compacta de gamificación con XP y Racha
  Widget _buildGamificationCard(BuildContext context, UserProfileState state) {
    // Obtener userId del estado
    String? userId;
    if (state is UserProfileLoaded) {
      userId = state.profile.id;
    } else if (state is UserProfileUpdated) {
      userId = state.profile.id;
    }

    if (userId == null || userId.isEmpty) {
      return const SizedBox.shrink();
    }

    // userId ya está verificado como no-null arriba
    final validUserId = userId;

    return BlocBuilder<GamificationBloc, GamificationState>(
      builder: (context, gamificationState) {
        // Cargar perfil inmediatamente si no está cargado
        if (gamificationState is! GamificationLoaded &&
            gamificationState is! GamificationLoading) {
          // Cargar inmediatamente sin esperar PostFrameCallback
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final gamificationBloc = context.read<GamificationBloc>();
              gamificationBloc.add(LoadGamificationProfile(validUserId));
            }
          });
        }

        if (gamificationState is GamificationLoaded) {
          final isSmallScreen =
              ResponsiveHelper.isExtraSmall(context) ||
              ResponsiveHelper.isSmall(context);
          final padding = ResponsiveHelper.getResponsivePadding(context);

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 0),
            padding: EdgeInsets.all(isSmallScreen ? padding * 0.75 : padding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Barra de XP compacta (horizontal)
                _buildCompactXPBar(gamificationState.profile),
                SizedBox(height: isSmallScreen ? 10 : 12),
                // Divider sutil
                Container(height: 1, color: Colors.grey[200]),
                SizedBox(height: isSmallScreen ? 10 : 12),
                // Racha compacta (horizontal)
                FutureBuilder<DailyStreak?>(
                  future: _getStreak(validUserId),
                  builder: (context, snapshot) {
                    return _buildCompactStreak(
                      gamificationState.profile,
                      snapshot.data,
                    );
                  },
                ),
              ],
            ),
          );
        } else if (gamificationState is GamificationLoading) {
          final padding = ResponsiveHelper.getResponsivePadding(context);
          return Container(
            margin: EdgeInsets.symmetric(horizontal: padding),
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        // Estado inicial o error - no mostrar nada
        return const SizedBox.shrink();
      },
    );
  }

  /// Construye la barra de XP compacta (versión horizontal)
  Widget _buildCompactXPBar(UserGamificationProfile profile) {
    final isSmallScreen =
        ResponsiveHelper.isExtraSmall(context) ||
        ResponsiveHelper.isSmall(context);
    final levelService = LevelService();
    final progress = profile.levelProgress;
    final tierNameKey = levelService.getLevelTier(profile.currentLevel);
    final tierName = tierNameKey.tr();

    // Obtener el badge del nivel (mapear a los badges disponibles)
    String levelBadgePath;
    if (profile.currentLevel >= 20) {
      levelBadgePath = 'assets/images/badges/badge_level_20.png';
    } else if (profile.currentLevel >= 15) {
      levelBadgePath = 'assets/images/badges/badge_level_15.png';
    } else if (profile.currentLevel >= 10) {
      levelBadgePath = 'assets/images/badges/badge_level_10.png';
    } else if (profile.currentLevel >= 5) {
      levelBadgePath = 'assets/images/badges/badge_level_5.png';
    } else if (profile.currentLevel >= 3) {
      levelBadgePath = 'assets/images/badges/badge_level_3.png';
    } else {
      levelBadgePath = 'assets/images/badges/badge_level_1.png';
    }

    final badgeSize = isSmallScreen ? 36.0 : 40.0;
    final spacing = isSmallScreen ? 6.0 : 8.0;

    return Row(
      children: [
        // Badge del nivel
        Container(
          width: badgeSize,
          height: badgeSize,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.asset(
            levelBadgePath,
            width: badgeSize,
            height: badgeSize,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              final tierEmoji = levelService.getLevelTierEmoji(
                profile.currentLevel,
              );
              return Center(
                child: Text(
                  tierEmoji,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      isSmallScreen ? 18.0 : 20.0,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(width: spacing),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${'gamification.level'.tr()} ${profile.currentLevel}',
              style: GoogleFonts.quicksand(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  isSmallScreen ? 14.0 : 16.0,
                ),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
            ),
            Text(
              tierName,
              style: GoogleFonts.quicksand(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  isSmallScreen ? 9.0 : 10.0,
                ),
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const Spacer(),
        // Barra de progreso
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${profile.currentLevelXP} XP',
                style: GoogleFonts.quicksand(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    isSmallScreen ? 12.0 : 14.0,
                  ),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3498DB),
                ),
              ),
              SizedBox(height: isSmallScreen ? 3 : 4),
              LinearPercentIndicator(
                lineHeight: isSmallScreen ? 5.0 : 6.0,
                percent: progress,
                backgroundColor: Colors.grey[200]!,
                progressColor: const Color(0xFF3498DB),
                barRadius: const Radius.circular(3),
                animation: true,
                animationDuration: 500,
              ),
              SizedBox(height: isSmallScreen ? 1 : 2),
              Text(
                '${profile.currentLevelXP}/${profile.nextLevelXP}',
                style: GoogleFonts.quicksand(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    isSmallScreen ? 9.0 : 10.0,
                  ),
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Construye la racha compacta (versión horizontal)
  Widget _buildCompactStreak(
    UserGamificationProfile profile,
    DailyStreak? streak,
  ) {
    final isSmallScreen =
        ResponsiveHelper.isExtraSmall(context) ||
        ResponsiveHelper.isSmall(context);
    final streakService = StreakService();
    final streakStatus = streak != null
        ? streakService.checkStreakStatus(streak)
        : StreakStatus.noActivity;
    final message = streak != null
        ? streakService.getEmpatheticMessage(
            streakStatus,
            profile.currentStreak,
          )
        : '¡Comienza tu primera racha hoy!';

    Color streakColor;
    IconData streakIcon;
    String streakEmoji;

    switch (streakStatus) {
      case StreakStatus.active:
        streakColor = const Color(0xFFE74C3C);
        streakIcon = Icons.local_fire_department;
        streakEmoji = '🔥';
        break;
      case StreakStatus.atRisk:
        streakColor = const Color(0xFFF39C12);
        streakIcon = Icons.warning_amber_rounded;
        streakEmoji = '⚠️';
        break;
      case StreakStatus.lost:
        streakColor = Colors.grey;
        streakIcon = Icons.refresh;
        streakEmoji = '💙';
        break;
      case StreakStatus.paused:
        streakColor = const Color(0xFF3498DB);
        streakIcon = Icons.pause_circle;
        streakEmoji = '⏸️';
        break;
      case StreakStatus.noActivity:
        streakColor = Colors.grey;
        streakIcon = Icons.local_fire_department_outlined;
        streakEmoji = '💤';
        break;
    }

    final iconSize = isSmallScreen ? 36.0 : 40.0;
    final spacing = isSmallScreen ? 6.0 : 8.0;

    return Row(
      children: [
        // Icono de racha
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: streakColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              streakEmoji,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  isSmallScreen ? 20.0 : 24.0,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: spacing),
        // Información de racha
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    streakIcon,
                    color: streakColor,
                    size: ResponsiveHelper.getResponsiveIconSize(
                      context,
                      isSmallScreen ? 14.0 : 16.0,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 3 : 4),
                  Text(
                    'gamification.streak'.tr(),
                    style: GoogleFonts.quicksand(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        isSmallScreen ? 10.0 : 12.0,
                      ),
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 1 : 2),
              Text(
                '${profile.currentStreak} ${'home.days'.tr()}',
                style: GoogleFonts.quicksand(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    isSmallScreen ? 16.0 : 18.0,
                  ),
                  fontWeight: FontWeight.bold,
                  color: streakColor,
                ),
              ),
              SizedBox(height: isSmallScreen ? 1 : 2),
              Text(
                message,
                style: GoogleFonts.quicksand(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    isSmallScreen ? 9.0 : 10.0,
                  ),
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Días de descanso si aplica
        if (profile.canUseRestDay && !profile.isPauseModeActive)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 6 : 8,
              vertical: isSmallScreen ? 3 : 4,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF3498DB).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${profile.restDaysAvailable}\n${'home.days'.tr()}',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  isSmallScreen ? 8.0 : 9.0,
                ),
                color: const Color(0xFF3498DB),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  /// Obtiene la racha del usuario desde el repositorio
  Future<DailyStreak?> _getStreak(String userId) async {
    try {
      final repository = getIt<GamificationRepository>();
      final result = await repository.getStreak(userId);
      return result.fold((error) {
        _logger.e('Error obteniendo racha: $error');
        return null;
      }, (streak) => streak);
    } catch (e, stackTrace) {
      _logger.e('Excepción obteniendo racha', e, stackTrace);
      return null;
    }
  }

  /// Recarga la información de situación del usuario
  Future<void> _reloadSituationData(
    String userId,
    UserProfileBloc userProfileBloc,
  ) async {
    if (!mounted) return;

    try {
      _logger.d('HomePage: Cargando información de situación...');

      final userSubcollectionsService = UserSubcollectionsService(
        FirebaseFirestore.instance,
        _logger,
      );

      final situationData = await userSubcollectionsService
          .getUserSituationData(userId)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              _logger.w('HomePage: Timeout cargando información de situación');
              return null;
            },
          );

      if (situationData != null) {
        _logger.d('HomePage: Información de situación cargada: $situationData');

        // Determinar si es preparto o postparto
        final situationType = situationData['situationType'] as String?;
        final isPrePartum = situationType == 'preparto';
        final isPostPartum = situationType == 'postparto';

        _logger.d(
          'HomePage: situationType = $situationType, isPrePartum = $isPrePartum, isPostPartum = $isPostPartum',
        );

        // Actualizar el UserProfileBloc con la información de situación
        if (mounted) {
          userProfileBloc.add(
            UpdateUserSituationRequested(
              userId: userId,
              isPrePartum: isPrePartum,
              isPostPartum: isPostPartum,
              situationData: situationData,
            ),
          );
          _logger.success('HomePage: Información de situación actualizada');
        }
      } else {
        _logger.w('HomePage: No se encontró información de situación');
      }
    } catch (e, stackTrace) {
      _logger.e(
        'HomePage: Error cargando información de situación',
        e,
        stackTrace,
      );
      // No es crítico, continuar sin actualizar la situación
    }
  }

  /// Recarga desde cache como fallback
  Future<void> _reloadFromCache() async {
    if (!mounted) return;

    try {
      _logger.d('HomePage: Intentando recargar desde cache...');
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userProfileBloc = context.read<UserProfileBloc>();
      final currentState = userProfileBloc.state;

      // Si ya hay un perfil cargado, no hacer nada
      if (currentState is UserProfileLoaded ||
          currentState is UserProfileUpdated) {
        _logger.d('HomePage: Perfil ya está cargado');
        return;
      }

      // Intentar obtener userId y recargar
      final userId = await _getUserDocumentId(user);
      if (userId != null && userId.isNotEmpty) {
        userProfileBloc.add(GetUserProfileRequested(userId: userId));
      }
    } catch (e, stackTrace) {
      _logger.e('HomePage: Error recargando desde cache', e, stackTrace);
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  /// Maneja el estado cuando no hay registros
  Widget _buildEmptyState(LactationProvider lactationProvider) {
    final isSmallScreen =
        ResponsiveHelper.isExtraSmall(context) ||
        ResponsiveHelper.isSmall(context);
    final padding = ResponsiveHelper.getResponsivePadding(context);

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? padding * 1.2 : padding * 1.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.child_care,
            size: ResponsiveHelper.getResponsiveIconSize(context, 48.0),
            color: Colors.grey[400],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Text(
            'home.welcome'.tr(),
            style: GoogleFonts.quicksand(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                isSmallScreen ? 18.0 : 20.0,
              ),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            'home.welcomeMessage'.tr(),
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                isSmallScreen ? 12.0 : 14.0,
              ),
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          SmartLactationButton(
            onSuccess: () {
              // Refrescar datos después de registrar lactancia
              lactationProvider.refreshTodayData();
              lactationProvider.loadWeekData();
            },
            onCancel: () {
              // Opcional: manejar cancelación
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Elementos decorativos de fondo
          _buildBackgroundElements(context),

          // Contenido principal usando BlocBuilder
          BlocBuilder<UserProfileBloc, UserProfileState>(
            builder: (context, state) {
              _logger.d('HomePage: Estado recibido: ${state.runtimeType}');
              if (state is UserProfileLoaded) {
                _logger.d(
                  'HomePage: UserProfileLoaded - isPostPartum: ${state.profile.isPostPartum}',
                );
              } else if (state is UserProfileUpdated) {
                _logger.d(
                  'HomePage: UserProfileUpdated - isPostPartum: ${state.profile.isPostPartum}',
                );
              } else if (state is UserProfileFailure) {
                _logger.e('HomePage: UserProfileFailure - ${state.message}');
              } else {
                _logger.w('HomePage: Estado inesperado: $state');
              }
              return _buildHomeContent(context, state);
            },
          ),

          // Badge de estado offline (discreto, no intrusivo)
          const OfflineBadge(),

          // Indicador de sincronización
          const SyncIndicator(),
        ],
      ),
    );
  }

  Widget _buildBackgroundElements(BuildContext context) {
    final screenHeight = ResponsiveHelper.screenHeight(context);
    final screenWidth = ResponsiveHelper.screenWidth(context);

    return Stack(
      children: [
        // Círculos decorativos
        Positioned(
          top: -screenHeight * 0.1,
          right: -screenWidth * 0.1,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Partículas decorativas
        ...List.generate(8, (index) => _buildAnimatedParticle(context, index)),
      ],
    );
  }

  Widget _buildAnimatedParticle(BuildContext context, int index) {
    final screenWidth = ResponsiveHelper.screenWidth(context);
    final screenHeight = ResponsiveHelper.screenHeight(context);
    final left = (index * 50.0) % screenWidth;
    final top = (index * 80.0) % screenHeight;

    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: 4 + (index % 3) * 2.0,
        height: 4 + (index % 3) * 2.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, UserProfileState state) {
    // Detección de tamaños responsive
    final isSmallScreen =
        ResponsiveHelper.isExtraSmall(context) ||
        ResponsiveHelper.isSmall(context);
    final isShortScreen = ResponsiveHelper.isShortScreen(context);
    final padding = ResponsiveHelper.getResponsivePadding(context);

    // Mostrar skeleton mientras el perfil está inicializando/cargando para evitar parpadeos de UI
    if (state is UserProfileInitial || state is UserProfileLoading) {
      return _buildHomeSkeleton(context);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        children: [
          SizedBox(height: isSmallScreen ? 16 : (isShortScreen ? 18 : 20)),
          // Header modernizado movido al contenido scrolleable
          ModernHeader(
            userName: NavigationService.getUserName(state),
            onNavigateToLessons: () =>
                NavigationService.navigateToLessons(context),
          ),
          SizedBox(height: isSmallScreen ? 16 : (isShortScreen ? 18 : 20)),
          _buildHomeContentSections(context, state),
          SizedBox(
            height: isSmallScreen ? 80 : 100,
          ), // Espacio para el bottom bar
        ],
      ),
    );
  }

  /// Skeleton sencillo para cubrir el contenido de Home mientras carga el perfil
  Widget _buildHomeSkeleton(BuildContext context) {
    // Gradiente para el efecto shimmer
    final LinearGradient shimmerGradient = LinearGradient(
      colors: [Colors.grey[200]!, Colors.grey[300]!, Colors.grey[200]!],
      stops: const [0.1, 0.5, 0.9],
      begin: const Alignment(-1.0, -0.3),
      end: const Alignment(1.0, 0.3),
    );

    Widget skeletonCard({double height = 120}) {
      return Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ShimmerLoading(
          isLoading: true,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
    }

    final isSmallScreen =
        ResponsiveHelper.isExtraSmall(context) ||
        ResponsiveHelper.isSmall(context);
    final isShortScreen = ResponsiveHelper.isShortScreen(context);
    final padding = ResponsiveHelper.getResponsivePadding(context);

    return Shimmer(
      linearGradient: shimmerGradient,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Column(
          children: [
            SizedBox(height: isSmallScreen ? 16 : (isShortScreen ? 18 : 20)),
            // Header placeholder
            skeletonCard(height: isSmallScreen ? 80 : 90),
            SizedBox(height: isSmallScreen ? 16 : (isShortScreen ? 18 : 20)),
            // Tarjeta principal (countdown o dashboard)
            skeletonCard(height: isSmallScreen ? 200 : 220),
            SizedBox(height: isSmallScreen ? 12 : 15),
            // Card Lecciones
            skeletonCard(height: isSmallScreen ? 80 : 88),
            SizedBox(height: isSmallScreen ? 12 : 15),
            // Grid/segunda fila
            skeletonCard(height: isSmallScreen ? 80 : 88),
            SizedBox(height: isSmallScreen ? 16 : 20),
            // Sección de perfil
            skeletonCard(height: isSmallScreen ? 110 : 120),
            SizedBox(height: isSmallScreen ? 80 : 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContentSections(
    BuildContext context,
    UserProfileState state,
  ) {
    final isSmallScreen =
        ResponsiveHelper.isExtraSmall(context) ||
        ResponsiveHelper.isSmall(context);
    final isPostPartum = NavigationService.getUserPostPartumStatus(state);
    _logger.d(
      'HomePage: _buildHomeContentSections - isPostPartum: $isPostPartum, state: ${state.runtimeType}',
    );

    final spacing = isSmallScreen ? 12.0 : 15.0;
    final largeSpacing = isSmallScreen ? 16.0 : 20.0;

    return Column(
      children: [
        // Tarjeta compacta de gamificación
        _buildGamificationCard(context, state),
        SizedBox(height: spacing),

        // Contenido específico según el tipo de usuario
        if (isPostPartum) ...[
          // Dashboard de lactancia para usuarios postparto
          _buildLactationDashboard(context, state),
          SizedBox(height: spacing),
        ] else ...[
          // Contador de cuenta regresiva para usuarios preparto
          _buildCountdownSection(context, state),
          SizedBox(height: spacing),
        ],

        // Tarjeta de Lecciones (arriba de Tips e Historial)
        HomeFeatureCard(
          title: 'home.lessons'.tr(),
          icon: Icons.school,
          description: 'home.lessonsDescription'.tr(),
          onTap: () => NavigationService.navigateToLessons(context),
          color: AppColorService.getFeatureColor('Lecciones'),
        ),

        SizedBox(height: spacing),

        // Grid de funcionalidades basado en el estado del usuario
        _buildFeatureGrid(context, isPostPartum),

        SizedBox(height: largeSpacing),

        // Secciones de perfil específicas
        _buildProfileSections(context, state),
      ],
    );
  }

  Widget _buildFeatureGrid(BuildContext context, bool isPostPartum) {
    final isSmallScreen =
        ResponsiveHelper.isExtraSmall(context) ||
        ResponsiveHelper.isSmall(context);
    final spacing = isSmallScreen ? 12.0 : 15.0;

    // Para ambos perfiles: Tips e Historial en fila
    return Row(
      children: [
        Expanded(
          child: HomeFeatureCard(
            title: 'home.tips'.tr(),
            icon: Icons.lightbulb,
            description: 'home.tipsDescription'.tr(),
            onTap: () => NavigationService.navigateToTips(context),
            color: AppColorService.getFeatureColor('Tips'),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: HomeFeatureCard(
            title: 'home.history'.tr(),
            icon: Icons.video_library,
            description: 'home.historyDescription'.tr(),
            onTap: () => NavigationService.navigateToUserVideos(context),
            color: AppColorService.getFeatureColor('Historial'),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSections(BuildContext context, UserProfileState state) {
    return Column(
      children: [
        // Secciones específicas según el estado
        _buildPostPartumSection(state),
      ],
    );
  }

  /// Construye la sección de postparto con logs detallados
  Widget _buildPostPartumSection(UserProfileState state) {
    if (state is UserProfileLoaded) {
      _logger.d(
        'HomePage: UserProfileLoaded - isPostPartum: ${state.profile.isPostPartum}',
      );
      // Solo mostrar PostpartoProfileWidget para usuarios postparto
      // Los usuarios preparto ya tienen CountdownCard que muestra toda la información necesaria
      if (state.profile.isPostPartum) {
        _logger.d(
          'HomePage: Mostrando PostpartoProfileWidget para UserProfileLoaded',
        );
        return PostpartoProfileWidget(userProfile: state.profile);
      } else {
        _logger.d(
          'HomePage: NO mostrando PostpartoProfileWidget para UserProfileLoaded (no es postparto)',
        );
        return const SizedBox.shrink();
      }
    } else if (state is UserProfileUpdated) {
      _logger.d(
        'HomePage: UserProfileUpdated - isPostPartum: ${state.profile.isPostPartum}',
      );
      // Solo mostrar PostpartoProfileWidget para usuarios postparto
      // Los usuarios preparto ya tienen CountdownCard que muestra toda la información necesaria
      if (state.profile.isPostPartum) {
        _logger.d(
          'HomePage: Mostrando PostpartoProfileWidget para UserProfileUpdated',
        );
        return PostpartoProfileWidget(userProfile: state.profile);
      } else {
        _logger.d(
          'HomePage: NO mostrando PostpartoProfileWidget para UserProfileUpdated (no es postparto)',
        );
        return const SizedBox.shrink();
      }
    } else {
      _logger.w(
        'HomePage: Estado no reconocido para mostrar PostpartoProfileWidget: ${state.runtimeType}',
      );
      return const SizedBox.shrink();
    }
  }

  /// Extrae la fecha esperada de nacimiento desde los datos del usuario
  String? _getExpectedBirthDate(UserProfileState state) {
    // Buscar en los datos de situación del usuario
    if (state is UserProfileLoaded) {
      final situationData = state.profile.situationData;
      if (situationData != null &&
          situationData.containsKey('expectedBirthDate')) {
        return situationData['expectedBirthDate'] as String;
      }
    } else if (state is UserProfileUpdated) {
      final situationData = state.profile.situationData;
      if (situationData != null &&
          situationData.containsKey('expectedBirthDate')) {
        return situationData['expectedBirthDate'] as String;
      }
    }

    // No hay fecha disponible
    return null;
  }

  /// Maneja la transición automática de preparto a postparto cuando el timer llega a 0
  void _handleCountdownReached(BuildContext context, UserProfileState state) {
    // Solo procesar una vez
    if (state is UserProfileLoaded || state is UserProfileUpdated) {
      final profile = (state as dynamic).profile;

      // Solo hacer la transición si aún está en preparto
      if (profile.isPrePartum && !profile.isPostPartum) {
        _logger.d('HomePage: Timer llegó a 0, transicionando a postparto...');

        // Actualizar situación del usuario
        context.read<UserProfileBloc>().add(
          UpdateUserSituationRequested(
            userId: profile.id,
            isPrePartum: false,
            isPostPartum: true,
            situationData: {
              ...?profile.situationData,
              'transitionDate': DateTime.now().toIso8601String(),
            },
          ),
        );

        // Mostrar mensaje de felicitación
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'gamification.messages.congratulations'.tr(),
              style: GoogleFonts.quicksand(),
            ),
            backgroundColor: const Color(0xFF03A696),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Maneja la actualización manual de preparto a postparto
  void _handleUpdateToPostpartum(BuildContext context, UserProfileState state) {
    if (state is UserProfileLoaded || state is UserProfileUpdated) {
      final profile = (state as dynamic).profile;

      // Solo hacer la transición si aún está en preparto
      if (profile.isPrePartum && !profile.isPostPartum) {
        _logger.d('HomePage: Usuario actualizando manualmente a postparto...');

        // Mostrar diálogo de confirmación
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.celebration, color: Colors.amber[700], size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'countdown.updateToPostpartum'.tr(),
                    style: GoogleFonts.quicksand(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              'countdown.updateToPostpartumConfirm'.tr(),
              style: GoogleFonts.quicksand(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  'common.close'.tr(),
                  style: GoogleFonts.quicksand(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();

                  // Actualizar situación del usuario
                  context.read<UserProfileBloc>().add(
                    UpdateUserSituationRequested(
                      userId: profile.id,
                      isPrePartum: false,
                      isPostPartum: true,
                      situationData: {
                        ...?profile.situationData,
                        'transitionDate': DateTime.now().toIso8601String(),
                        'manualUpdate': true,
                      },
                    ),
                  );

                  // Mostrar pantalla de felicitaciones
                  _showCongratulationsScreen(context, profile.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF03A696),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'countdown.updateToPostpartum'.tr(),
                  style: GoogleFonts.quicksand(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  /// Muestra la pantalla de felicitaciones cuando se actualiza a postparto
  void _showCongratulationsScreen(BuildContext context, String userId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2C5F5D), // Azul teal oscuro
                Color(0xFF1A365D), // Azul marino oscuro
                Color(0xFF4FD1C7), // Verde azulado medio vibrante
              ],
              stops: [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono de celebración animado
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.celebration,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              // Título
              Text(
                'countdown.congratulationsTitle'.tr(),
                style: GoogleFonts.quicksand(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Mensaje principal
              Text(
                'countdown.congratulationsMessage'.tr(),
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Mensaje adicional de cuidado
              Text(
                'countdown.congratulationsCareMessage'.tr(),
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Botón de acción
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  // Navegar al formulario de postparto
                  Navigator.of(context).pushNamed('/postpartum-form');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF03A696),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_circle_outline, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'countdown.registerBaby'.tr(),
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye la sección del contador con manejo de casos
  Widget _buildCountdownSection(BuildContext context, UserProfileState state) {
    // Evitar "flash" del mensaje de Información Pendiente:
    // Si el perfil ya está cargado pero aún no tenemos situación (postparto/preparto),
    // mostramos un placeholder en lugar del mensaje final hasta que llegue la situación.
    if (state is UserProfileLoaded || state is UserProfileUpdated) {
      final dynamic profile = (state as dynamic).profile;
      final situationData = profile.situationData;
      final situationUnknown =
          situationData == null ||
          (situationData is Map && situationData.isEmpty);
      if (situationUnknown) {
        return Container(
          width: double.infinity,
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
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Placeholder gris simple (coincide con el diseño general)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 18,
                width: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 40,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        );
      }
    }

    final expectedBirthDate = _getExpectedBirthDate(state);

    if (expectedBirthDate != null) {
      // Mostrar CountdownCard con fecha real y callback para transición
      return CountdownCard(
        expectedBirthDate: expectedBirthDate,
        onCountdownReached: () {
          _handleCountdownReached(context, state);
        },
        onUpdateToPostpartum: () {
          _handleUpdateToPostpartum(context, state);
        },
      );
    } else {
      // Mostrar mensaje informativo cuando no hay fecha
      return Container(
        width: double.infinity,
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
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.orange[400]),
            const SizedBox(height: 16),
            Text(
              'Información Pendiente',
              style: GoogleFonts.quicksand(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Para mostrar el contador de tu bebé, necesitas completar la información de tu embarazo en el perfil.',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navegar al perfil o onboarding
                Navigator.of(context).pushNamed('/profile');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF03A696),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Completar Información',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }
  }

  /// Dashboard específico para usuarios postparto enfocado en lactancia
  Widget _buildLactationDashboard(
    BuildContext context,
    UserProfileState state,
  ) {
    return Consumer<LactationProvider>(
      builder: (context, lactationProvider, child) {
        // Si está cargando, mostrar loading
        if (lactationProvider.isLoading) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFF03A696)),
            ),
          );
        }

        // Si hay error, mostrar error
        if (lactationProvider.errorMessage != null) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.error_outline, color: Colors.red[400], size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error cargando datos',
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  lactationProvider.errorMessage!,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => lactationProvider.refreshTodayData(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF03A696),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Reintentar',
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
        }

        // Si no hay registros, mostrar estado vacío
        if (lactationProvider.todayRecords.isEmpty) {
          return Column(
            children: [
              _buildEmptyState(lactationProvider),
              const SizedBox(height: 20),
            ],
          );
        }

        // Si hay registros, mostrar dashboard normal
        return Column(
          children: [
            // Calendario horizontal con countdown integrado
            _buildIntegratedCalendarAndCountdown(context, lactationProvider),

            const SizedBox(height: 20),

            // Resumen del día actual (más compacto)
            _buildCompactTodaySummary(context, lactationProvider),
          ],
        );
      },
    );
  }

  /// Calendario horizontal con countdown integrado en un solo contenedor
  Widget _buildIntegratedCalendarAndCountdown(
    BuildContext context,
    LactationProvider lactationProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Calendario horizontal
          _buildHorizontalCalendar(context, lactationProvider),

          const SizedBox(height: 24),

          // Divider sutil
          Container(height: 1, color: Colors.grey[200]),

          const SizedBox(height: 20),

          // Countdown integrado
          _buildIntegratedCountdown(context, lactationProvider),
          const SizedBox(height: 30),

          // Botón inteligente de registro de lactancia
          SmartLactationButton(
            onSuccess: () async {
              _logger.d('onSuccess: Refrescando datos...');
              // Refrescar datos después de registrar lactancia
              await lactationProvider.refreshTodayData();
              await lactationProvider.loadWeekData();
              _logger.d('onSuccess: Datos refrescados');
            },
          ),
        ],
      ),
    );
  }

  /// Calendario horizontal consistente con el diseño de la app
  Widget _buildHorizontalCalendar(
    BuildContext context,
    LactationProvider lactationProvider,
  ) {
    final now = DateTime.now();
    final todayWeekday = now.weekday; // Lunes=1, Domingo=7
    final weekDays = ['D', 'L', 'M', 'M', 'J', 'V', 'S'];

    // Obtener los días de la semana actual
    final startOfWeek = now.subtract(Duration(days: todayWeekday % 7));
    _logger.d(
      'Inicio de semana (DOMINGO): ${startOfWeek.day}/${startOfWeek.month}/${startOfWeek.year}',
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final date = startOfWeek.add(Duration(days: index));
        final isToday = date.day == now.day && date.month == now.month;
        // Verificar si el día tiene registros según la base de datos
        final isMarked = lactationProvider.hasRecordsForDate(date);

        // Debug solo para domingo y lunes para verificar el bug
        if (index == 0 || index == 1) {
          _logger.d(
            '${index == 0 ? "DOMINGO" : "LUNES"}: ${date.day}/${date.month} - Marcado: $isMarked',
          );
        }

        return Expanded(
          child: Column(
            children: [
              // Día de la semana con estilo consistente
              Text(
                isToday ? 'HOY' : weekDays[date.weekday % 7],
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isToday
                      ? const Color(0xFF03A696) // Color primario de la app
                      : const Color(0xFF7F8C8D), // Color secundario consistente
                ),
              ),
              const SizedBox(height: 12),

              // Fecha con diseño consistente
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isToday
                      ? const Color(0xFF03A696) // Color primario para hoy
                      : isMarked
                      ? const Color(0xFF03A696).withValues(
                          alpha: 0.1,
                        ) // Sutil para días marcados
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: isToday
                      ? null
                      : isMarked
                      ? Border.all(
                          color: const Color(0xFF03A696).withValues(alpha: 0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isToday
                          ? Colors.white
                          : const Color(
                              0xFF2C3E50,
                            ), // Color de texto consistente
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Indicador de actividad consistente
              if (isMarked)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF03A696),
                    shape: BoxShape.circle,
                  ),
                )
              else
                const SizedBox(height: 6),
            ],
          ),
        );
      }),
    );
  }

  /// Countdown integrado más compacto
  Widget _buildIntegratedCountdown(
    BuildContext context,
    LactationProvider lactationProvider,
  ) {
    // Verificar si hay registros hoy
    final hasRecords = lactationProvider.todayRecords.isNotEmpty;
    final isLoading = lactationProvider.isLoading;

    return Column(
      children: [
        if (!hasRecords && !isLoading)
          // Mensaje cuando no hay registros
          Column(
            children: [
              Text(
                '¡Comienza tu registro!',
                style: GoogleFonts.quicksand(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF03A696),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Registra tu primera toma de lactancia',
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  color: const Color(0xFF7F8C8D),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          )
        else
          // Timer normal cuando hay registros
          Column(
            children: [
              Text(
                'Próxima toma en',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  color: const Color(0xFF7F8C8D),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isLoading ? '...' : lactationProvider.getNextFeedTime(),
                style: GoogleFonts.quicksand(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF03A696),
                ),
              ),
            ],
          ),
        const SizedBox(height: 12),
        // Banner de progreso solo si hay registros
        if (hasRecords && !isLoading)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF03A696).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Color(0xFF03A696),
                ),
                const SizedBox(width: 4),
                Text(
                  '${lactationProvider.getFeedStatus()}. ${lactationProvider.getDurationInfo()}',
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    color: const Color(0xFF03A696),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else if (isLoading)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF03A696).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Cargando...',
              style: GoogleFonts.quicksand(
                fontSize: 12,
                color: const Color(0xFF03A696),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  /// Resumen compacto del día actual
  Widget _buildCompactTodaySummary(
    BuildContext context,
    LactationProvider lactationProvider,
  ) {
    if (lactationProvider.isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF03A696)),
        ),
      );
    }

    if (lactationProvider.errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 24),
            const SizedBox(height: 8),
            Text(
              'Error cargando datos',
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lactationProvider.errorMessage!,
              style: GoogleFonts.quicksand(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => lactationProvider.refreshTodayData(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF03A696),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Reintentar',
                style: GoogleFonts.quicksand(fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    final stats =
        lactationProvider.todayStats ??
        LactationStats(
          totalFeeds: 0,
          totalDuration: Duration.zero,
          averageDuration: Duration.zero,
          feedsToday: 0,
          durationToday: Duration.zero,
        );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCompactSummaryItem(
            '${stats.feedsToday}',
            'Tomas',
            Icons.restaurant,
          ),
          _buildCompactSummaryItem(
            stats.durationToday.inHours > 0
                ? '${stats.durationToday.inHours}h ${stats.durationToday.inMinutes.remainder(60)}m'
                : '${stats.durationToday.inMinutes}m',
            'Total',
            Icons.access_time,
          ),
          _buildCompactSummaryItem(
            lactationProvider.todayRecords.isNotEmpty
                ? lactationProvider.formatLastFeedTime(
                    lactationProvider.todayRecords.last.fechaRegistro,
                  )
                : 'N/A',
            'Última',
            Icons.schedule,
          ),
        ],
      ),
    );
  }

  /// Item compacto del resumen
  Widget _buildCompactSummaryItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF03A696), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.quicksand(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

// ===== Shimmer utilidades (basado en la guía oficial) =====
// Referencia: https://docs.flutter.dev/cookbook/effects/shimmer-loading
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.linearGradient, required this.child});

  final LinearGradient linearGradient;
  final Widget child;

  static ShimmerState? of(BuildContext context) {
    return context.findAncestorStateOfType<ShimmerState>();
  }

  @override
  ShimmerState createState() => ShimmerState();
}

class ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  LinearGradient get gradient => LinearGradient(
    colors: widget.linearGradient.colors,
    stops: widget.linearGradient.stops,
    begin: widget.linearGradient.begin,
    end: widget.linearGradient.end,
    transform: _SlidingGradientTransform(slidePercent: _controller.value),
  );

  bool get isSized =>
      (context.findRenderObject() as RenderBox?)?.hasSize ?? false;
  Size get size => (context.findRenderObject() as RenderBox).size;

  Offset getDescendantOffset({
    required RenderBox descendant,
    Offset offset = Offset.zero,
  }) {
    final shimmerBox = context.findRenderObject() as RenderBox?;
    return descendant.localToGlobal(offset, ancestor: shimmerBox);
  }

  Listenable get shimmerChanges => _controller;

  @override
  Widget build(BuildContext context) => widget.child;
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});
  final double slidePercent;
  @override
  Matrix4? transform(Rect bounds, {ui.TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    super.key,
    required this.isLoading,
    required this.child,
  });
  final bool isLoading;
  final Widget child;
  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> {
  Listenable? _shimmerChanges;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _shimmerChanges?.removeListener(_onShimmerChange);
    _shimmerChanges = Shimmer.of(context)?.shimmerChanges;
    _shimmerChanges?.addListener(_onShimmerChange);
  }

  @override
  void dispose() {
    _shimmerChanges?.removeListener(_onShimmerChange);
    super.dispose();
  }

  void _onShimmerChange() {
    if (widget.isLoading) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    final shimmer = Shimmer.of(context);
    if (shimmer == null || !shimmer.isSized) return const SizedBox();

    final shimmerSize = shimmer.size;
    final gradient = shimmer.gradient;
    final offsetWithinShimmer = shimmer.getDescendantOffset(
      descendant: context.findRenderObject() as RenderBox,
    );

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return gradient.createShader(
          Rect.fromLTWH(
            -offsetWithinShimmer.dx,
            -offsetWithinShimmer.dy,
            shimmerSize.width,
            shimmerSize.height,
          ),
        );
      },
      child: widget.child,
    );
  }
}

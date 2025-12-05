import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../gamification/domain/entities/user_gamification_profile.dart';
import '../../../gamification/domain/services/achievement_service.dart';
import '../../../gamification/presentation/bloc/gamification_bloc.dart';
import '../../../gamification/presentation/bloc/gamification_event.dart';
import '../../../gamification/presentation/services/achievement_queue_service.dart';
import '../../../../core/di/injection.dart';

/// Widget para mostrar animación de logros nuevos
class CompanionNewAchievementsAnimation {
  // Variable estática para evitar mostrar logros múltiples veces
  static bool _isShowing = false;
  static Set<String> _shownAchievementIds = {};

  static Future<void> show(
    BuildContext context,
    UserGamificationProfile profile,
    String userId,
  ) async {
    final newAchievementIds = profile.newAchievements;

    if (newAchievementIds.isEmpty) {
      // Si no hay logros nuevos, limpiar el estado
      _isShowing = false;
      _shownAchievementIds.clear();
      return;
    }

    // Filtrar logros que ya se mostraron para evitar duplicados
    final unseenAchievementIds = newAchievementIds
        .where((id) => !_shownAchievementIds.contains(id))
        .toList();

    if (unseenAchievementIds.isEmpty) {
      // Si todos los logros ya se mostraron, limpiar la lista de todos modos
      if (!context.mounted) return;
      final gamificationBloc = context.read<GamificationBloc>();
      final updatedProfile = profile.copyWith(
        newAchievements: [],
        updatedAt: DateTime.now(),
      );
      gamificationBloc.add(UpdateGamificationProfile(updatedProfile));
      return;
    }

    // Evitar mostrar múltiples veces simultáneamente
    if (_isShowing) {
      if (kDebugMode) {
        print('⚠️ [CompanionNewAchievementsAnimation] Ya se está mostrando una animación, ignorando...');
      }
      return;
    }

    _isShowing = true;

    final achievementService = AchievementService();
    final allAchievements = achievementService.getAllAchievements();

    // Obtener los logros nuevos que no se han mostrado
    final newAchievements = allAchievements
        .where((a) => unseenAchievementIds.contains(a.id))
        .toList();

    // Marcar estos logros como mostrados ANTES de mostrarlos
    _shownAchievementIds.addAll(unseenAchievementIds);

    // Limpiar la lista de logros nuevos INMEDIATAMENTE para que el badge desaparezca
    if (!context.mounted) {
      _isShowing = false;
      return;
    }

    final gamificationBloc = context.read<GamificationBloc>();
    final updatedProfile = profile.copyWith(
      newAchievements: [],
      updatedAt: DateTime.now(),
    );
    gamificationBloc.add(UpdateGamificationProfile(updatedProfile));

    // Mostrar logros uno a la vez usando el servicio de cola
    if (newAchievements.isNotEmpty) {
      final achievementQueueService = getIt<AchievementQueueService>();
      achievementQueueService.queueAchievements(context, newAchievements);
      
      // Resetear el flag después de un delay para permitir mostrar nuevos logros en el futuro
      Future.delayed(const Duration(seconds: 5), () {
        _isShowing = false;
        _shownAchievementIds.clear();
      });
    } else {
      _isShowing = false;
    }
  }

  /// Limpia el estado estático (útil para testing o reset)
  static void reset() {
    _isShowing = false;
    _shownAchievementIds.clear();
  }
}

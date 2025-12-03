import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../gamification/domain/entities/user_gamification_profile.dart';
import '../../../gamification/domain/services/achievement_service.dart';
import '../../../gamification/presentation/bloc/gamification_bloc.dart';
import '../../../gamification/presentation/bloc/gamification_event.dart';
import '../../../gamification/presentation/services/achievement_queue_service.dart';
import '../../../../core/di/injection.dart';

/// Widget para mostrar animación de logros nuevos
class CompanionNewAchievementsAnimation {
  static Future<void> show(
    BuildContext context,
    UserGamificationProfile profile,
    String userId,
  ) async {
    final achievementService = AchievementService();
    final allAchievements = achievementService.getAllAchievements();
    final newAchievementIds = profile.newAchievements;

    if (newAchievementIds.isEmpty) return;

    // Obtener los logros nuevos
    final newAchievements = allAchievements
        .where((a) => newAchievementIds.contains(a.id))
        .toList();

    // Mostrar logros uno a la vez usando el servicio de cola
    if (newAchievements.isNotEmpty) {
      final achievementQueueService = getIt<AchievementQueueService>();
      achievementQueueService.queueAchievements(context, newAchievements);
    }

    if (!context.mounted) return;

    // Limpiar la lista de logros nuevos (marcar como vistos)
    final gamificationBloc = context.read<GamificationBloc>();
    final updatedProfile = profile.copyWith(
      newAchievements: [],
      updatedAt: DateTime.now(),
    );
    gamificationBloc.add(UpdateGamificationProfile(updatedProfile));
  }
}

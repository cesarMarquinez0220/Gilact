import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../gamification/domain/entities/user_gamification_profile.dart';
import '../../../gamification/domain/services/achievement_service.dart';
import '../../../gamification/presentation/bloc/gamification_bloc.dart';
import '../../../gamification/presentation/bloc/gamification_event.dart';
import '../../../gamification/presentation/widgets/achievement_unlocked_dialog.dart';

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

    // Mostrar animación del primer logro
    if (newAchievements.isNotEmpty) {
      AchievementUnlockedDialog.show(
        context,
        newAchievements.first,
        newAchievements.first.xpReward,
      );

      // Si hay más logros, mostrar los siguientes después de un delay
      if (newAchievements.length > 1) {
        for (int i = 1; i < newAchievements.length; i++) {
          await Future.delayed(const Duration(milliseconds: 1500));
          if (context.mounted) {
            AchievementUnlockedDialog.show(
              context,
              newAchievements[i],
              newAchievements[i].xpReward,
            );
          }
        }
      }
    }

    // Limpiar la lista de logros nuevos (marcar como vistos)
    final gamificationBloc = context.read<GamificationBloc>();
    final updatedProfile = profile.copyWith(
      newAchievements: [],
      updatedAt: DateTime.now(),
    );
    gamificationBloc.add(UpdateGamificationProfile(updatedProfile));
  }
}


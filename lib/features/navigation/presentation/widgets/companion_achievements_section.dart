import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../gamification/domain/entities/achievement.dart';
import '../../../gamification/domain/entities/user_gamification_profile.dart';
import '../../../gamification/domain/services/achievement_service.dart';
import 'companion_achievement_badge.dart';

/// Sección de logros/badges de la página de compañera
class CompanionAchievementsSection extends StatelessWidget {
  final UserGamificationProfile profile;
  final List<Achievement> unlockedAchievements;

  const CompanionAchievementsSection({
    required this.profile,
    required this.unlockedAchievements,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final achievementService = AchievementService();
    final allAchievements = achievementService.getAllAchievements();
    final totalAchievements = allAchievements.length;
    final unlockedCount = unlockedAchievements.length;
    final progress = totalAchievements > 0
        ? unlockedCount / totalAchievements
        : 0.0;

    // Si no hay logros desbloqueados, mostrar mensaje motivacional
    if (unlockedAchievements.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
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
            Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber[700], size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'companion.achievements'.tr(),
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      Text(
                        'companion.startUnlocking'.tr(),
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'companion.startJourney'.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de logros
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber[700], size: 24),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'companion.unlockedAchievements'.tr(),
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      Text(
                        '$unlockedCount ${'companion.of'.tr()} $totalAchievements',
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[700]!),
            ),
          ),
          const SizedBox(height: 16),
          // Botón informativo "¿Cómo ganar XP?"
          _XPInfoButton(),
          const SizedBox(height: 20),
          // Tabs para Desbloqueados y Todos
          DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  labelColor: const Color(0xFF03A696),
                  unselectedLabelColor: Colors.grey[600],
                  indicatorColor: const Color(0xFF03A696),
                  tabs: [
                    Tab(text: 'companion.unlocked'.tr()),
                    Tab(text: 'companion.all'.tr()),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: TabBarView(
                    children: [
                      // Tab de logros desbloqueados
                      _AchievementsGrid(
                        achievements: unlockedAchievements,
                        isUnlocked: true,
                        profile: profile,
                      ),
                      // Tab de todos los logros (desbloqueados + bloqueados)
                      _AllAchievementsGrid(
                        allAchievements: allAchievements,
                        profile: profile,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón informativo sobre cómo ganar XP
class _XPInfoButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showXPInfoDialog(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF03A696).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF03A696).withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color:  Color(0xFF03A696), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'companion.howToEarnXP'.tr(),
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF03A696),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color:  Color(0xFF03A696),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showXPInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF03A696), Color(0xFF26A69A), Color(0xFF4DB6AC)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'companion.howToEarnXP'.tr(),
                    style: GoogleFonts.quicksand(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _XPInfoItem(
                'companion.quickRecord'.tr(),
                'companion.baseXP'.tr(namedArgs: {'xp': '10'}),
                'companion.firstOfDay'.tr(),
              ),
              _XPInfoItem(
                'companion.fullRecord'.tr(),
                'companion.baseXP'.tr(namedArgs: {'xp': '20'}),
                'companion.firstOfDaySleep'.tr(),
              ),
              _XPInfoItem(
                'companion.completeLesson'.tr(),
                'companion.baseXP'.tr(namedArgs: {'xp': '30'}),
                'companion.firstLessonOfDay'.tr(),
              ),
              _XPInfoItem(
                'companion.completeTrivia'.tr(),
                'companion.perQuestion'.tr(),
                'companion.allCorrect'.tr(),
              ),
              _XPInfoItem(
                'companion.weightRecord'.tr(),
                'companion.baseXP'.tr(namedArgs: {'xp': '15'}),
                '',
              ),
              _XPInfoItem(
                'companion.sleepRecord'.tr(),
                'companion.baseXP'.tr(namedArgs: {'xp': '10'}),
                '',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${'companion.specialBonuses'.tr()}:',
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• ${'companion.milestones'.tr()}\n'
                      '• ${'companion.streaks'.tr()}\n'
                      '• ${'companion.unlockedAchievementsBonus'.tr()}',
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: Text(
                    'companion.understood'.tr(),
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _XPInfoItem extends StatelessWidget {
  final String action;
  final String baseXP;
  final String bonus;

  const _XPInfoItem(this.action, this.baseXP, this.bonus);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      action,
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      baseXP,
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                if (bonus.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      bonus,
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Grid de logros desbloqueados
class _AchievementsGrid extends StatelessWidget {
  final List<Achievement> achievements;
  final bool isUnlocked;
  final UserGamificationProfile profile;

  const _AchievementsGrid({
    required this.achievements,
    required this.isUnlocked,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    // Ordenar por tipo y luego por requiredValue
    final sortedAchievements = List<Achievement>.from(achievements)
      ..sort((a, b) {
        if (a.type != b.type) {
          return a.type.index.compareTo(b.type.index);
        }
        return a.requiredValue.compareTo(b.requiredValue);
      });

    // Calcular columnas responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 360 ? 3 : 4;
    final spacing = screenWidth < 360 ? 8.0 : 12.0;
    final aspectRatio = screenWidth < 360 ? 0.9 : 0.85;

    return GridView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(), // Permitir scroll como en "Todos"
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: aspectRatio,
      ),
      itemCount: sortedAchievements.length,
      itemBuilder: (context, index) {
        final achievement = sortedAchievements[index];
        return CompanionAchievementBadge(
          achievement: achievement,
          isUnlocked: isUnlocked,
          profile: profile,
        );
      },
    );
  }
}

/// Grid de todos los logros (desbloqueados + bloqueados)
class _AllAchievementsGrid extends StatelessWidget {
  final List<Achievement> allAchievements;
  final UserGamificationProfile profile;

  const _AllAchievementsGrid({
    required this.allAchievements,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final unlockedIds = profile.unlockedAchievements.toSet();
    final sortedAchievements = List<Achievement>.from(allAchievements)
      ..sort((a, b) {
        // Primero desbloqueados, luego bloqueados
        final aUnlocked = unlockedIds.contains(a.id);
        final bUnlocked = unlockedIds.contains(b.id);
        if (aUnlocked != bUnlocked) {
          return aUnlocked ? -1 : 1;
        }
        // Luego por tipo
        if (a.type != b.type) {
          return a.type.index.compareTo(b.type.index);
        }
        // Finalmente por valor requerido
        return a.requiredValue.compareTo(b.requiredValue);
      });

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 360 ? 3 : 4;
    final spacing = screenWidth < 360 ? 8.0 : 12.0;
    final aspectRatio = screenWidth < 360 ? 0.9 : 0.85;

    return GridView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: aspectRatio,
      ),
      itemCount: sortedAchievements.length,
      itemBuilder: (context, index) {
        final achievement = sortedAchievements[index];
        final isUnlocked = unlockedIds.contains(achievement.id);
        return CompanionAchievementBadge(
          achievement: achievement,
          isUnlocked: isUnlocked,
          profile: profile,
        );
      },
    );
  }
}

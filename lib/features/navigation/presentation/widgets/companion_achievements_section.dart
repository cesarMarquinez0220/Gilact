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
            const Icon(Icons.info_outline, color: Color(0xFF03A696), size: 20),
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
              color: Color(0xFF03A696),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showXPInfoDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        // Quitamos el padding inferior manual y usamos padding simétrico básico
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: SafeArea(
          // SafeArea: Esto arregla que el botón salga detrás de la barra de navegación
          top: false, // No necesitamos proteger arriba
          bottom: true, // Sí necesitamos proteger abajo
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Manija visual
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 2. Título
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'companion.howToEarnXP'.tr(),
                    style: GoogleFonts.quicksand(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. Grid de Acciones Diarias
              _buildSectionTitle('companion.dailyActions'.tr()),
              const SizedBox(height: 10),

              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                childAspectRatio: 2.7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildCompactXPItem(
                    Icons.flash_on,
                    'companion.quickRecord',
                    '10',
                  ),
                  _buildCompactXPItem(
                    Icons.edit_note,
                    'companion.fullRecord',
                    '20',
                  ),
                  _buildCompactXPItem(
                    Icons.school,
                    'companion.completeLesson',
                    '30',
                  ),
                  _buildCompactXPItem(
                    Icons.quiz,
                    'companion.completeTrivia',
                    '5',
                  ),
                  _buildCompactXPItem(
                    Icons.monitor_weight,
                    'companion.weightRecord',
                    '15',
                  ),
                  _buildCompactXPItem(
                    Icons.bedtime,
                    'companion.sleepRecord',
                    '10',
                  ),
                ],
              ),

              // --- AJUSTE DE ESPACIO ---
              // Aquí controlas la distancia entre el Grid y los Bonos.
              // Estaba muy grande o ausente, con 12px se ve limpio y unido.
              const SizedBox(height: 12),

              // 4. Sección de Bonos
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF3498DB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF3498DB).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFF3498DB),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'companion.specialBonuses'.tr(),
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF3498DB),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildBonusRow(
                      'companion.dailyStreaks'.tr(),
                      'companion.streaks'.tr().split(':')[1].trim(),
                    ),
                    _buildBonusRow(
                      'companion.recordMilestones'.tr(),
                      'companion.milestones'.tr().split(':')[1].trim(),
                    ),
                    _buildBonusRow(
                      'companion.unlockedAchievements'.tr(),
                      'companion.unlockedAchievementsBonus'
                          .tr()
                          .split(':')[1]
                          .trim(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Botón Entendido
              // Al estar dentro del SafeArea, este botón subirá automáticamente
              // si hay una barra de navegación en el celular.
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'companion.understood'.tr(),
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Un pequeño margen extra al final para que no pegue con el borde de la pantalla
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // Widgets auxiliares para limpiar el código
  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.quicksand(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildCompactXPItem(IconData icon, String labelKey, String xpValue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF3498DB)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  labelKey.tr(),
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'companion.baseXP'.tr(namedArgs: {'xp': xpValue}),
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBonusRow(String label, String xp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.quicksand(fontSize: 13, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              xp,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3498DB),
              ),
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
    // Ajustado para badges más grandes (60x60 + texto) - reducido para evitar overflow
    final aspectRatio = screenWidth < 360 ? 0.65 : 0.6;

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
    // Ajustado para badges más grandes (60x60 + texto) - reducido para evitar overflow
    final aspectRatio = screenWidth < 360 ? 0.65 : 0.6;

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

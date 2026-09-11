import 'package:flutter/material.dart';
import '../../domain/entities/achievement.dart';
import '../widgets/achievement_unlocked_dialog.dart';
import '../../../../core/services/app_initialization_service.dart';

/// Servicio para mostrar logros desbloqueados uno a la vez en una cola
/// Evita que múltiples diálogos se solapen
class AchievementQueueService {
  static final AchievementQueueService _instance =
      AchievementQueueService._internal();
  factory AchievementQueueService() => _instance;
  AchievementQueueService._internal();

  final List<_QueuedAchievement> _queue = [];
  bool _isShowing = false;
  BuildContext? _currentContext;
  final Set<String> _recentlyShownAchievements = {}; // Prevenir duplicados

  /// Obtiene un contexto válido del Navigator global
  BuildContext? _getValidContext() {
    // Intentar usar el contexto guardado si está montado
    if (_currentContext != null && _currentContext!.mounted) {
      return _currentContext;
    }

    // Si no, intentar obtener un contexto del Navigator global
    final navigatorKey = AppInitializationService.navigationKey;
    final navigatorState = navigatorKey.currentState;
    if (navigatorState != null) {
      final overlay = navigatorState.overlay;
      if (overlay != null && overlay.context.mounted) {
        return overlay.context;
      }
    }

    return null;
  }

  /// Agrega logros a la cola y los muestra secuencialmente
  void queueAchievements(BuildContext context, List<Achievement> achievements) {
    if (achievements.isEmpty) return;

    // Filtrar logros que ya se mostraron recientemente (prevenir duplicados)
    final newAchievements = achievements
        .where(
          (achievement) => !_recentlyShownAchievements.contains(achievement.id),
        )
        .toList();

    if (newAchievements.isEmpty) return;

    // Agregar todos los logros nuevos a la cola
    for (final achievement in newAchievements) {
      _queue.add(
        _QueuedAchievement(
          achievement: achievement,
          xpReward: achievement.xpReward,
        ),
      );
      // Marcar como mostrado para prevenir duplicados
      _recentlyShownAchievements.add(achievement.id);
    }

    _currentContext = context;
    _processQueue();
  }

  /// Procesa la cola de logros, mostrándolos uno a la vez
  void _processQueue() {
    if (_isShowing || _queue.isEmpty) return;

    // Obtener un contexto válido
    final context = _getValidContext();
    if (context == null) {
      // Si no hay contexto válido, limpiar la cola
      _queue.clear();
      _isShowing = false;
      _currentContext = null;
      return;
    }

    _isShowing = true;
    final queuedAchievement = _queue.removeAt(0);

    // No mostrar animación de celebración para nivel 1 (es el nivel inicial)
    if (queuedAchievement.achievement.id == 'level_1') {
      // Saltar este logro y continuar con el siguiente
      _isShowing = false;
      Future.delayed(const Duration(milliseconds: 100), () {
        _processQueue();
      });
      return;
    }

    // Mostrar el diálogo y esperar a que se cierre
    AchievementUnlockedDialog.show(
          context,
          queuedAchievement.achievement,
          queuedAchievement.xpReward,
        )
        .then((_) {
          // Cuando se cierra el diálogo, procesar el siguiente
          _isShowing = false;

          // Verificar que haya un contexto válido antes de continuar
          final validContext = _getValidContext();
          if (validContext != null) {
            // Pequeño delay para suavizar la transición
            Future.delayed(const Duration(milliseconds: 300), () {
              if (_getValidContext() != null) {
                _processQueue();
              } else {
                // Si no hay contexto válido, limpiar la cola
                _queue.clear();
                _isShowing = false;
                _currentContext = null;
              }
            });
          } else {
            // Si no hay contexto válido, limpiar la cola
            _queue.clear();
            _isShowing = false;
            _currentContext = null;
          }
        })
        .catchError((error) {
          // Si hay un error, continuar con el siguiente logro
          _isShowing = false;
          final validContext = _getValidContext();
          if (validContext != null) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (_getValidContext() != null) {
                _processQueue();
              } else {
                _queue.clear();
                _currentContext = null;
              }
            });
          } else {
            _queue.clear();
            _currentContext = null;
          }
        });
  }

  /// Limpia la cola (útil para resetear)
  void clearQueue() {
    _queue.clear();
    _isShowing = false;
    _currentContext = null;
  }

  /// Limpia el registro de logros recientemente mostrados
  /// Útil para permitir que se muestren nuevamente después de un tiempo
  void clearRecentlyShown() {
    _recentlyShownAchievements.clear();
  }
}

/// Clase auxiliar para almacenar logros en la cola
class _QueuedAchievement {
  final Achievement achievement;
  final int xpReward;

  _QueuedAchievement({required this.achievement, required this.xpReward});
}

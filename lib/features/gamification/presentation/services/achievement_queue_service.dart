import 'package:flutter/material.dart';
import '../../domain/entities/achievement.dart';
import '../widgets/achievement_unlocked_dialog.dart';

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

  /// Agrega logros a la cola y los muestra secuencialmente
  void queueAchievements(
    BuildContext context,
    List<Achievement> achievements,
  ) {
    if (achievements.isEmpty) return;

    // Agregar todos los logros a la cola
    for (final achievement in achievements) {
      _queue.add(_QueuedAchievement(
        achievement: achievement,
        xpReward: achievement.xpReward,
      ));
    }

    _currentContext = context;
    _processQueue();
  }

  /// Procesa la cola de logros, mostrándolos uno a la vez
  void _processQueue() {
    if (_isShowing || _queue.isEmpty || _currentContext == null) return;

    final context = _currentContext!;
    if (!context.mounted) {
      _queue.clear();
      _isShowing = false;
      _currentContext = null;
      return;
    }

    _isShowing = true;
    final queuedAchievement = _queue.removeAt(0);

    // Mostrar el diálogo y esperar a que se cierre
    AchievementUnlockedDialog.show(
      context,
      queuedAchievement.achievement,
      queuedAchievement.xpReward,
    ).then((_) {
      // Cuando se cierra el diálogo, procesar el siguiente
      _isShowing = false;
      
      // Verificar que el contexto aún esté montado antes de continuar
      if (_currentContext != null && _currentContext!.mounted) {
        // Pequeño delay para suavizar la transición
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_currentContext != null && _currentContext!.mounted) {
            _processQueue();
          } else {
            // Si el contexto se desmontó, limpiar la cola
            _queue.clear();
            _isShowing = false;
            _currentContext = null;
          }
        });
      } else {
        // Si el contexto se desmontó, limpiar la cola
        _queue.clear();
        _isShowing = false;
        _currentContext = null;
      }
    }).catchError((error) {
      // Si hay un error, continuar con el siguiente logro
      _isShowing = false;
      if (_currentContext != null && _currentContext!.mounted) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _processQueue();
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
}

/// Clase auxiliar para almacenar logros en la cola
class _QueuedAchievement {
  final Achievement achievement;
  final int xpReward;

  _QueuedAchievement({
    required this.achievement,
    required this.xpReward,
  });
}


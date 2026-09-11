/// Servicio para calcular y gestionar las etapas del bebé
/// Basado en el progreso de lecciones completadas
class BabyStageService {
  /// Calcula la etapa del bebé según lecciones completadas
  /// 
  /// - 0-6 lecciones: baby_born (recién nacido)
  /// - 7-13 lecciones: baby_3months (3 meses)
  /// - 14+ lecciones: baby_6months (6 meses)
  String calculateBabyStage(int completedLessons) {
    if (completedLessons >= 14) {
      return 'baby_6months';
    }
    if (completedLessons >= 7) {
      return 'baby_3months';
    }
    return 'baby_born';
  }

  /// Verifica si debe actualizarse la etapa del bebé
  /// 
  /// Retorna true si la nueva etapa es diferente a la actual
  bool shouldUpdateStage(String currentStage, int completedLessons) {
    final newStage = calculateBabyStage(completedLessons);
    return newStage != currentStage;
  }

  /// Obtiene el nombre de la etapa siguiente
  /// 
  /// Retorna null si ya está en la etapa máxima
  String? getNextStage(String currentStage) {
    switch (currentStage) {
      case 'baby_born':
        return 'baby_3months';
      case 'baby_3months':
        return 'baby_6months';
      case 'baby_6months':
        return null; // Ya está en la etapa máxima
      default:
        return 'baby_3months';
    }
  }

  /// Obtiene el número mínimo de lecciones necesarias para desbloquear la siguiente etapa
  /// 
  /// Retorna null si ya está en la etapa máxima
  int? getRequiredLessonsForNextStage(String currentStage) {
    switch (currentStage) {
      case 'baby_born':
        return 7;
      case 'baby_3months':
        return 14;
      case 'baby_6months':
        return null; // Ya está en la etapa máxima
      default:
        return 7;
    }
  }
}


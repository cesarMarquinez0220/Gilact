/// Árbol de decisiones inteligente para el registro de lactancia
class LactationDecisionTree {
  /// Determina el siguiente paso basado en la respuesta del usuario
  static LactationStep getNextStep({
    required LactationStep currentStep,
    required String userResponse,
    Map<String, dynamic>? context,
  }) {
    switch (currentStep) {
      case LactationStep.initial:
        return _handleInitialStep(userResponse);

      case LactationStep.breastOrBottle:
        return _handleBreastOrBottleStep(userResponse, context);

      case LactationStep.breastSide:
        return _handleBreastSideStep(userResponse, context);

      case LactationStep.breastDuration:
        return _handleBreastDurationStep(userResponse, context);

      case LactationStep.bottleVolume:
        return _handleBottleVolumeStep(userResponse, context);

      case LactationStep.sleepTime:
        return _handleSleepTimeStep(userResponse, context);

      case LactationStep.extractionVolume:
        return _handleExtractionVolumeStep(userResponse, context);

      case LactationStep.confirmation:
        return LactationStep.completed;

      case LactationStep.completed:
        return LactationStep.completed;
    }
  }

  /// Maneja el paso inicial - pregunta si es pecho, biberón o mixto
  static LactationStep _handleInitialStep(String response) {
    switch (response.toLowerCase()) {
      case 'pecho':
      case 'materna':
      case 'lactancia':
        return LactationStep
            .breastSide; // Ir directamente a seleccionar lado del pecho
      case 'biberon':
      case 'formula':
        return LactationStep
            .bottleVolume; // Ir directamente a volumen del biberón
      case 'mixto':
      case 'mixta':
        return LactationStep
            .breastSide; // Empezar con el pecho en alimentación mixta
      default:
        return LactationStep.breastSide;
    }
  }

  /// Maneja la decisión entre pecho y biberón
  static LactationStep _handleBreastOrBottleStep(
    String response,
    Map<String, dynamic>? context,
  ) {
    switch (response.toLowerCase()) {
      case 'pecho':
      case 'materna':
        return LactationStep.breastSide;
      case 'biberon':
      case 'formula':
        return LactationStep.bottleVolume;
      case 'ambos':
      case 'mixta':
        // Si es mixta, preguntamos primero por el pecho
        return LactationStep.breastSide;
      default:
        return LactationStep.breastSide;
    }
  }

  /// Maneja la selección del lado del pecho
  static LactationStep _handleBreastSideStep(
    String response,
    Map<String, dynamic>? context,
  ) {
    // Después de seleccionar el lado, preguntamos por la duración
    return LactationStep.breastDuration;
  }

  /// Maneja la duración de la lactancia materna
  static LactationStep _handleBreastDurationStep(
    String response,
    Map<String, dynamic>? context,
  ) {
    // Verificar si es alimentación mixta basado en la respuesta inicial
    final initialChoice = context?['initial']?.toString().toLowerCase();
    final isMixed = initialChoice == 'mixto' || initialChoice == 'mixta';

    if (isMixed) {
      return LactationStep
          .bottleVolume; // Después del pecho, preguntar por biberón
    } else {
      return LactationStep.confirmation; // Si solo pecho, ir a confirmación
    }
  }

  /// Maneja el volumen del biberón
  static LactationStep _handleBottleVolumeStep(
    String response,
    Map<String, dynamic>? context,
  ) {
    // Después del biberón, ir directamente a confirmación
    return LactationStep.confirmation;
  }

  /// Maneja el tiempo de sueño
  static LactationStep _handleSleepTimeStep(
    String response,
    Map<String, dynamic>? context,
  ) {
    // Después del sueño, preguntamos por extracción si es relevante
    final hasBreastfeeding = context?['hasBreastfeeding'] ?? false;

    if (hasBreastfeeding) {
      return LactationStep.extractionVolume;
    } else {
      return LactationStep.confirmation;
    }
  }

  /// Maneja el volumen de extracción
  static LactationStep _handleExtractionVolumeStep(
    String response,
    Map<String, dynamic>? context,
  ) {
    return LactationStep.confirmation;
  }

  /// Obtiene las opciones disponibles para un paso específico
  static List<LactationOption> getOptionsForStep(LactationStep step) {
    switch (step) {
      case LactationStep.initial:
        return [
          LactationOption(
            id: 'pecho',
            title: 'Pecho',
            description: 'Lactancia materna directa',
            icon: '🤱',
            color: 0xFF4CAF50,
          ),
          LactationOption(
            id: 'biberon',
            title: 'Biberón',
            description: 'Fórmula o leche extraída',
            icon: '🍶',
            color: 0xFF2196F3,
          ),
          LactationOption(
            id: 'mixto',
            title: 'Mixto',
            description: 'Combinación de pecho y biberón',
            icon: '🥛',
            color: 0xFFFF9800,
          ),
        ];

      case LactationStep.breastSide:
        return const [
          LactationOption(
            id: 'izquierdo',
            title: 'Pecho Izquierdo',
            description: 'Lado izquierdo',
            icon: '👈',
            color: 0xFF4CAF50,
          ),
          LactationOption(
            id: 'derecho',
            title: 'Pecho Derecho',
            description: 'Lado derecho',
            icon: '👉',
            color: 0xFF4CAF50,
          ),
          LactationOption(
            id: 'ambos',
            title: 'Ambos Pechos',
            description: 'Los dos lados',
            icon: '🤱',
            color: 0xFF4CAF50,
          ),
        ];

      case LactationStep.breastDuration:
        return const [
          LactationOption(
            id: '5',
            title: '5 minutos',
            description: 'Corta duración',
            icon: '⏱️',
            color: 0xFF4CAF50,
          ),
          LactationOption(
            id: '10',
            title: '10 minutos',
            description: 'Duración media',
            icon: '⏱️',
            color: 0xFF4CAF50,
          ),
          LactationOption(
            id: '15',
            title: '15 minutos',
            description: 'Duración normal',
            icon: '⏱️',
            color: 0xFF4CAF50,
          ),
          LactationOption(
            id: '20',
            title: '20+ minutos',
            description: 'Duración larga',
            icon: '⏱️',
            color: 0xFF4CAF50,
          ),
        ];

      case LactationStep.bottleVolume:
        return [
          LactationOption(
            id: '30ml',
            title: '30 ml',
            description: '1 oz',
            icon: '🍶',
            color: 0xFF2196F3,
          ),
          LactationOption(
            id: '60ml',
            title: '60 ml',
            description: '2 oz',
            icon: '🍶',
            color: 0xFF2196F3,
          ),
          LactationOption(
            id: '90ml',
            title: '90 ml',
            description: '3 oz',
            icon: '🍶',
            color: 0xFF2196F3,
          ),
          LactationOption(
            id: '120ml',
            title: '120 ml',
            description: '4 oz',
            icon: '🍶',
            color: 0xFF2196F3,
          ),
          LactationOption(
            id: '150ml',
            title: '150 ml',
            description: '5 oz',
            icon: '🍶',
            color: 0xFF2196F3,
          ),
          LactationOption(
            id: '180ml',
            title: '180 ml',
            description: '6 oz',
            icon: '🍶',
            color: 0xFF2196F3,
          ),
          LactationOption(
            id: '240ml',
            title: '240 ml',
            description: '8 oz',
            icon: '🍶',
            color: 0xFF2196F3,
          ),
        ];

      case LactationStep.sleepTime:
        return [
          LactationOption(
            id: '0',
            title: 'Sin sueño',
            description: 'No durmió',
            icon: '😴',
            color: 0xFF9C27B0,
          ),
          LactationOption(
            id: '30',
            title: '30 minutos',
            description: 'Siesta corta',
            icon: '😴',
            color: 0xFF9C27B0,
          ),
          LactationOption(
            id: '60',
            title: '1 hora',
            description: 'Siesta normal',
            icon: '😴',
            color: 0xFF9C27B0,
          ),
          LactationOption(
            id: '120',
            title: '2 horas',
            description: 'Siesta larga',
            icon: '😴',
            color: 0xFF9C27B0,
          ),
          LactationOption(
            id: '180',
            title: '3+ horas',
            description: 'Sueño prolongado',
            icon: '😴',
            color: 0xFF9C27B0,
          ),
        ];

      case LactationStep.extractionVolume:
        return [
          LactationOption(
            id: '0',
            title: 'Sin extracción',
            description: 'No extraje leche',
            icon: '💧',
            color: 0xFF00BCD4,
          ),
          LactationOption(
            id: '30',
            title: '30 ml',
            description: '1 onza',
            icon: '💧',
            color: 0xFF00BCD4,
          ),
          LactationOption(
            id: '60',
            title: '60 ml',
            description: '2 onzas',
            icon: '💧',
            color: 0xFF00BCD4,
          ),
          LactationOption(
            id: '90',
            title: '90 ml',
            description: '3 onzas',
            icon: '💧',
            color: 0xFF00BCD4,
          ),
          LactationOption(
            id: '120',
            title: '120 ml',
            description: '4 onzas',
            icon: '💧',
            color: 0xFF00BCD4,
          ),
        ];

      case LactationStep.confirmation:
        return [
          LactationOption(
            id: 'confirm',
            title: 'Guardar',
            description: 'Guardar registro de lactancia',
            icon: '💾',
            color: 0xFF4CAF50,
          ),
        ];

      default:
        return [];
    }
  }

  /// Obtiene el mensaje para un paso específico
  static String getMessageForStep(LactationStep step) {
    switch (step) {
      case LactationStep.initial:
        return '¿Cómo alimentaste a tu bebé esta vez?';

      case LactationStep.breastSide:
        return '¿Qué pecho le diste?';

      case LactationStep.breastDuration:
        return '¿Cuánto tiempo duró la lactancia?';

      case LactationStep.bottleVolume:
        return '¿Cuánta leche tomó?';

      case LactationStep.sleepTime:
        return '¿Cuánto tiempo durmió después?';

      case LactationStep.extractionVolume:
        return '¿Extrajiste leche materna?';

      case LactationStep.confirmation:
        return '¿Guardar este registro de lactancia?';

      default:
        return '';
    }
  }
}

/// Pasos del flujo de registro
enum LactationStep {
  initial,
  breastOrBottle,
  breastSide,
  breastDuration,
  bottleVolume,
  sleepTime,
  extractionVolume,
  confirmation,
  completed,
}

/// Opción disponible en un paso
class LactationOption {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int color;

  const LactationOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

/// Contexto del flujo de registro
class LactationFlowContext {
  final Map<String, dynamic> data;
  final LactationStep currentStep;
  final List<String> history;

  LactationFlowContext({
    required this.data,
    required this.currentStep,
    required this.history,
  });

  LactationFlowContext copyWith({
    Map<String, dynamic>? data,
    LactationStep? currentStep,
    List<String>? history,
  }) {
    return LactationFlowContext(
      data: data ?? this.data,
      currentStep: currentStep ?? this.currentStep,
      history: history ?? this.history,
    );
  }

  /// Agrega una respuesta al contexto
  LactationFlowContext addResponse(String stepId, String response) {
    final newData = Map<String, dynamic>.from(data);
    newData[stepId] = response;

    final newHistory = List<String>.from(history);
    newHistory.add('$stepId: $response');

    return copyWith(data: newData, history: newHistory);
  }

  /// Verifica si tiene lactancia materna
  bool get hasBreastfeeding {
    final initial = data['initial']?.toString().toLowerCase();
    final breastOrBottle = data['breastOrBottle']?.toString().toLowerCase();

    return initial == 'pecho' ||
        initial == 'ambos' ||
        breastOrBottle == 'pecho' ||
        breastOrBottle == 'ambos';
  }

  /// Verifica si es alimentación mixta
  bool get isMixed {
    final initial = data['initial']?.toString().toLowerCase();
    return initial == 'ambos';
  }
}

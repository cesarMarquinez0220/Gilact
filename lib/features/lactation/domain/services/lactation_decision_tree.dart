import 'package:easy_localization/easy_localization.dart';

/// Árbol de decisiones inteligente para el registro de lactancia
class LactationDecisionTree {
  static String _tr(String key) => key.tr();

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
            title: _tr('lactation.decisionTree.options.pecho'),
            description: _tr('lactation.decisionTree.options.pechoDescription'),
            icon: '🤱',
            color: 0xFF4CAF50,
          ),
          LactationOption(
            id: 'biberon',
            title: _tr('lactation.decisionTree.options.biberon'),
            description: _tr(
              'lactation.decisionTree.options.biberonDescription',
            ),
            icon: '🍶',
            color: 0xFF2196F3,
          ),
          LactationOption(
            id: 'mixto',
            title: _tr('lactation.decisionTree.options.mixto'),
            description: _tr('lactation.decisionTree.options.mixtoDescription'),
            icon: '🥛',
            color: 0xFFFF9800,
          ),
        ];

      case LactationStep.breastSide:
        return [
          LactationOption(
            id: 'izquierdo',
            title: _tr('lactation.decisionTree.options.izquierdo'),
            description: _tr(
              'lactation.decisionTree.options.izquierdoDescription',
            ),
            icon: '👈',
            color: 0xFF4CAF50,
          ),
          LactationOption(
            id: 'derecho',
            title: _tr('lactation.decisionTree.options.derecho'),
            description: _tr(
              'lactation.decisionTree.options.derechoDescription',
            ),
            icon: '👉',
            color: 0xFF4CAF50,
          ),
          LactationOption(
            id: 'ambos',
            title: _tr('lactation.decisionTree.options.ambos'),
            description: _tr('lactation.decisionTree.options.ambosDescription'),
            icon: '🤱',
            color: 0xFF4CAF50,
          ),
        ];

      case LactationStep.breastDuration:
        return [
          LactationOption(
            id: '5',
            title: _tr('lactation.decisionTree.options.5min'),
            description: _tr('lactation.decisionTree.options.5minDescription'),
            icon: '⏱️',
            color: 0xFF4CAF50,
          ),
          LactationOption(
            id: '10',
            title: _tr('lactation.decisionTree.options.10min'),
            description: _tr('lactation.decisionTree.options.10minDescription'),
            icon: '⏱️',
            color: 0xFF4CAF50,
          ),
          LactationOption(
            id: '15',
            title: _tr('lactation.decisionTree.options.15min'),
            description: _tr('lactation.decisionTree.options.15minDescription'),
            icon: '⏱️',
            color: 0xFF4CAF50,
          ),
          LactationOption(
            id: '20',
            title: _tr('lactation.decisionTree.options.20min'),
            description: _tr('lactation.decisionTree.options.20minDescription'),
            icon: '⏱️',
            color: 0xFF4CAF50,
          ),
        ];

      case LactationStep.bottleVolume:
        return [
          LactationOption(
            id: '30ml',
            title: _tr('lactation.decisionTree.options.30ml'),
            description: '1 oz',
            icon: '🍶',
            color: 0xFF2196F3,
          ),
          LactationOption(
            id: '60ml',
            title: _tr('lactation.decisionTree.options.60ml'),
            description: '2 oz',
            icon: '🍶',
            color: 0xFF2196F3,
          ),
          LactationOption(
            id: '90ml',
            title: _tr('lactation.decisionTree.options.90ml'),
            description: '3 oz',
            icon: '🍶',
            color: 0xFF2196F3,
          ),
          LactationOption(
            id: '120ml',
            title: _tr('lactation.decisionTree.options.120ml'),
            description: '4 oz',
            icon: '🍶',
            color: 0xFF2196F3,
          ),
          LactationOption(
            id: '150ml',
            title: _tr('lactation.decisionTree.options.150ml'),
            description: '5 oz',
            icon: '🍶',
            color: 0xFF2196F3,
          ),
          LactationOption(
            id: '180ml',
            title: _tr('lactation.decisionTree.options.180ml'),
            description: '6 oz',
            icon: '🍶',
            color: 0xFF2196F3,
          ),
          LactationOption(
            id: '240ml',
            title: _tr('lactation.decisionTree.options.240ml'),
            description: '8 oz',
            icon: '🍶',
            color: 0xFF2196F3,
          ),
        ];

      case LactationStep.sleepTime:
        return [
          LactationOption(
            id: '0',
            title: _tr('lactation.decisionTree.options.noSleep'),
            description: _tr(
              'lactation.decisionTree.options.noSleepDescription',
            ),
            icon: '😴',
            color: 0xFF9C27B0,
          ),
          LactationOption(
            id: '30',
            title: _tr('lactation.decisionTree.options.30min'),
            description: _tr('lactation.decisionTree.options.30minDescription'),
            icon: '😴',
            color: 0xFF9C27B0,
          ),
          LactationOption(
            id: '60',
            title: _tr('lactation.decisionTree.options.1hour'),
            description: _tr('lactation.decisionTree.options.1hourDescription'),
            icon: '😴',
            color: 0xFF9C27B0,
          ),
          LactationOption(
            id: '120',
            title: _tr('lactation.decisionTree.options.2hours'),
            description: _tr(
              'lactation.decisionTree.options.2hoursDescription',
            ),
            icon: '😴',
            color: 0xFF9C27B0,
          ),
          LactationOption(
            id: '180',
            title: _tr('lactation.decisionTree.options.3hours'),
            description: _tr(
              'lactation.decisionTree.options.3hoursDescription',
            ),
            icon: '😴',
            color: 0xFF9C27B0,
          ),
        ];

      case LactationStep.extractionVolume:
        return [
          LactationOption(
            id: '0',
            title: _tr('lactation.decisionTree.options.noExtraction'),
            description: _tr(
              'lactation.decisionTree.options.noExtractionDescription',
            ),
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
            title: _tr('lactation.decisionTree.options.guardar'),
            description: _tr(
              'lactation.decisionTree.options.guardarDescription',
            ),
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
        return _tr('lactation.decisionTree.initial');

      case LactationStep.breastSide:
        return _tr('lactation.decisionTree.breastSide');

      case LactationStep.breastDuration:
        return _tr('lactation.decisionTree.breastDuration');

      case LactationStep.bottleVolume:
        return _tr('lactation.decisionTree.bottleVolume');

      case LactationStep.sleepTime:
        return _tr('lactation.decisionTree.sleepTime');

      case LactationStep.extractionVolume:
        return _tr('lactation.decisionTree.extractionVolume');

      case LactationStep.confirmation:
        return _tr('lactation.decisionTree.confirmation');

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

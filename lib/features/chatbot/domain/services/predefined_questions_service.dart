import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import '../entities/predefined_question.dart';

/// Servicio que maneja las preguntas predefinidas y sus relaciones
class PredefinedQuestionsService {
  static final PredefinedQuestionsService _instance =
      PredefinedQuestionsService._internal();
  factory PredefinedQuestionsService() => _instance;
  PredefinedQuestionsService._internal();

  /// Obtiene la pregunta traducida según el idioma actual
  String _getTranslatedQuestion(String questionId) {
    try {
      return 'chatbot.questions.$questionId.question'.tr();
    } catch (e) {
      // Si no hay traducción, retornar la pregunta original en español
      return _getDefaultQuestion(questionId);
    }
  }

  /// Obtiene la respuesta traducida según el idioma actual
  String _getTranslatedAnswer(String questionId) {
    try {
      return 'chatbot.questions.$questionId.answer'.tr();
    } catch (e) {
      // Si no hay traducción, retornar la respuesta original en español
      return _getDefaultAnswer(questionId);
    }
  }

  // Preguntas base en español como fallback
  static const Map<String, Map<String, String>> _defaultQuestions = {
    'q1': {
      'question': '¿Qué es el calostro?',
      'answer':
          'El calostro es la primera leche que produce tu cuerpo después del parto. Es rico en proteínas, anticuerpos y nutrientes esenciales que protegen a tu bebé de enfermedades. Es de color amarillento y espeso, y se produce en pequeñas cantidades durante los primeros días.',
    },
    'q2': {
      'question': '¿Cómo inicio la lactancia?',
      'answer':
          'Para iniciar la lactancia, coloca a tu bebé piel con piel inmediatamente después del parto si es posible. Busca un ambiente tranquilo, coloca al bebé cerca del pecho y espera a que abra la boca. Asegúrate de que el bebé tenga un buen agarre, con la boca cubriendo la mayor parte de la areola.',
    },
    'q3': {
      'question': '¿Cómo mejorar el agarre?',
      'answer':
          'Para mejorar el agarre, asegúrate de que el bebé tenga la boca bien abierta antes de acercarlo al pecho. El labio inferior debe estar volteado hacia afuera, y la nariz y el mentón deben tocar el pecho. El bebé debe tener más areola en la parte inferior de la boca que en la superior.',
    },
    'q4': {
      'question': '¿Cuántas veces debe comer un bebé?',
      'answer':
          'Los recién nacidos deben alimentarse entre 8 y 12 veces al día, aproximadamente cada 2-3 horas. Es importante alimentar al bebé a demanda, es decir, cuando muestre señales de hambre como llevarse las manos a la boca, hacer movimientos de succión o estar inquieto.',
    },
    'q5': {
      'question': '¿Qué es la mastitis?',
      'answer':
          'La mastitis es una inflamación del tejido mamario que puede causar dolor, enrojecimiento, hinchazón y fiebre. Puede ocurrir cuando la leche no se drena completamente del pecho. Es importante continuar amamantando o extrayendo leche del pecho afectado, aplicar compresas calientes y descansar.',
    },
    'q6': {
      'question': '¿Cómo tratar grietas en los pezones?',
      'answer':
          'Para tratar grietas en los pezones, asegúrate de que el bebé tenga un buen agarre. Después de cada toma, aplica un poco de tu propia leche materna en los pezones y déjalos secar al aire. Usa pezoneras si es necesario temporalmente. Evita jabones fuertes y cremas con alcohol.',
    },
    'q7': {
      'question': '¿Cómo saber si mi bebé come suficiente?',
      'answer':
          'Señales de que tu bebé come suficiente: moja 6-8 pañales al día, tiene deposiciones regulares, aumenta de peso adecuadamente, está alerta y activo cuando está despierto, y se ve satisfecho después de las tomas. Si tienes dudas, consulta con un profesional de la salud.',
    },
    'q8': {
      'question': '¿Cómo guardar leche materna?',
      'answer':
          'La leche materna puede guardarse en el refrigerador hasta 4 días a 4°C o menos, en el congelador hasta 6 meses (idealmente 3 meses), y a temperatura ambiente hasta 4 horas. Usa recipientes limpios y etiquétalos con la fecha. Descongela en el refrigerador o bajo agua tibia, nunca en microondas.',
    },
    'q9': {
      'question': '¿Cómo extraer leche materna?',
      'answer':
          'Puedes extraer leche manualmente o con un extractor. Lávate las manos antes, masajea suavemente el pecho, y coloca el extractor o tu mano en forma de C alrededor de la areola. Extrae hasta que el flujo disminuya, luego cambia al otro pecho. Alterna entre ambos pechos varias veces.',
    },
    'q10': {
      'question': '¿Qué beneficios tiene la lactancia?',
      'answer':
          'La lactancia materna beneficia tanto al bebé como a la madre. Para el bebé: protege contra infecciones, reduce el riesgo de alergias, favorece el desarrollo cerebral, y proporciona nutrientes ideales. Para la madre: ayuda a recuperar el peso, reduce el riesgo de cáncer de mama y ovario, y fortalece el vínculo con el bebé.',
    },
    'q11': {
      'question': '¿Qué debo comer durante la lactancia?',
      'answer':
          'Durante la lactancia, es importante mantener una dieta equilibrada y variada. Incluye frutas, verduras, proteínas magras, granos integrales y lácteos. Bebe mucha agua (al menos 8-10 vasos al día). Evita el alcohol y limita la cafeína. No necesitas una dieta especial, solo come de forma saludable.',
    },
    'q12': {
      'question': '¿Puedo tomar medicamentos?',
      'answer':
          'Muchos medicamentos son seguros durante la lactancia, pero siempre consulta con tu médico o farmacéutico antes de tomar cualquier medicamento. Algunos medicamentos pueden pasar a la leche materna. Tu médico puede recomendarte alternativas seguras si es necesario.',
    },
    'q13': {
      'question': '¿Cuánto tiempo dura la lactancia?',
      'answer':
          'La Organización Mundial de la Salud recomienda lactancia materna exclusiva durante los primeros 6 meses, y luego continuar con lactancia junto con alimentos complementarios hasta los 2 años o más. La duración depende de ti y de tu bebé. No hay un tiempo "correcto" para destetar.',
    },
    'q14': {
      'question': '¿Cómo destetar a mi bebé?',
      'answer':
          'El destete puede ser gradual o abrupto, pero el gradual suele ser más cómodo. Reduce una toma a la vez, reemplazándola con leche de fórmula o alimentos sólidos según la edad. Ofrece consuelo y atención adicional durante el proceso. El destete puede tomar semanas o meses.',
    },
    'q15': {
      'question': '¿Puedo amamantar si estoy enferma?',
      'answer':
          'En la mayoría de los casos, sí puedes amamantar cuando estás enferma. De hecho, tu leche contiene anticuerpos que pueden proteger a tu bebé. Si tienes fiebre alta o una enfermedad grave, consulta con tu médico. Usa mascarilla si tienes síntomas respiratorios.',
    },
    'q16': {
      'question': '¿La lactancia duele?',
      'answer':
          'La lactancia no debería doler. Si sientes dolor, puede ser señal de un agarre incorrecto. El dolor puede indicar grietas, mastitis u otros problemas. Si el dolor persiste, consulta con un especialista en lactancia o tu médico para identificar y tratar la causa.',
    },
    'q17': {
      'question': '¿Puedo hacer ejercicio durante la lactancia?',
      'answer':
          'Sí, puedes hacer ejercicio durante la lactancia. El ejercicio moderado no afecta la producción de leche ni su calidad. Asegúrate de mantenerte hidratada y usar un sostén de apoyo. Puedes amamantar antes del ejercicio para mayor comodidad.',
    },
    'q18': {
      'question': '¿Qué posiciones son mejores para amamantar?',
      'answer':
          'Las mejores posiciones son aquellas en las que tanto tú como tu bebé están cómodos. Algunas opciones comunes: posición cuna, posición cuna cruzada, posición acostada de lado, y posición de balón de rugby. Prueba diferentes posiciones para encontrar la que mejor funcione.',
    },
    'q19': {
      'question': '¿Cómo aumentar la producción de leche?',
      'answer':
          'Para aumentar la producción de leche: amamanta con frecuencia (a demanda), asegúrate de que el bebé tenga un buen agarre, alterna entre ambos pechos, extrae leche después de las tomas si es necesario, descansa y mantén una buena hidratación y nutrición.',
    },
    'q20': {
      'question': '¿Puedo amamantar en público?',
      'answer':
          'Sí, tienes derecho legal a amamantar en público en muchos países. Es una actividad natural y protegida. Si te sientes más cómoda, puedes usar una manta o un top especial para lactancia. No hay nada de malo en amamantar a tu bebé cuando lo necesite.',
    },
    'q21': {
      'question': '¿Qué es la lactancia materna exclusiva?',
      'answer':
          'La lactancia materna exclusiva significa que el bebé solo recibe leche materna, sin agua, jugos, fórmula u otros alimentos. Se recomienda durante los primeros 6 meses de vida. Después de los 6 meses, se combina con alimentos complementarios mientras se continúa amamantando.',
    },
    'q22': {
      'question': '¿Cómo saber si tengo suficiente leche?',
      'answer':
          'Señales de que tienes suficiente leche: el bebé moja 6-8 pañales al día, aumenta de peso adecuadamente, se ve satisfecho después de las tomas, y tus pechos se sienten más blandos después de amamantar. Si tienes dudas, consulta con un especialista en lactancia.',
    },
    'q23': {
      'question': '¿Puedo amamantar si tengo pezones planos o invertidos?',
      'answer':
          'Sí, puedes amamantar con pezones planos o invertidos. Puede requerir más paciencia y técnicas especiales. Un especialista en lactancia puede ayudarte con técnicas como el uso de pezoneras, ejercicios de Hoffman, o extracción antes de amamantar para ayudar a que el pezón sobresalga.',
    },
    'q24': {
      'question': '¿Cuándo debo buscar ayuda profesional?',
      'answer':
          'Debes buscar ayuda profesional si: sientes dolor constante al amamantar, tu bebé no aumenta de peso adecuadamente, tienes fiebre o síntomas de mastitis, el bebé no moja suficientes pañales, o si tienes cualquier preocupación sobre la lactancia. Los especialistas en lactancia pueden ayudarte.',
    },
    'q25': {
      'question': '¿La leche materna cambia con el tiempo?',
      'answer':
          'Sí, la leche materna cambia para adaptarse a las necesidades del bebé. El calostro (primeros días) es rico en anticuerpos. La leche de transición (días 3-14) tiene más grasa y lactosa. La leche madura se adapta continuamente a las necesidades nutricionales del bebé en crecimiento.',
    },
  };

  /// Obtiene la pregunta por defecto en español (fallback)
  String _getDefaultQuestion(String questionId) {
    return _defaultQuestions[questionId]?['question'] ?? '';
  }

  /// Obtiene la respuesta por defecto en español (fallback)
  String _getDefaultAnswer(String questionId) {
    return _defaultQuestions[questionId]?['answer'] ?? '';
  }

  /// Crea una pregunta predefinida con traducciones
  PredefinedQuestion _createTranslatedQuestion({
    required String id,
    required String category,
    required List<String> relatedQuestionIds,
  }) {
    return PredefinedQuestion(
      id: id,
      question: _getTranslatedQuestion(id),
      answer: _getTranslatedAnswer(id),
      category: category,
      relatedQuestionIds: relatedQuestionIds,
    );
  }

  // Mapa con la estructura de las preguntas (sin traducciones)
  static const Map<String, Map<String, dynamic>> _questionsStructureStatic = {
    'q1': {
      'category': 'inicio',
      'relatedQuestionIds': ['q2', 'q3', 'q4'],
    },
    'q2': {
      'category': 'inicio',
      'relatedQuestionIds': ['q1', 'q3', 'q5'],
    },
    'q3': {
      'category': 'inicio',
      'relatedQuestionIds': ['q2', 'q4', 'q6'],
    },
    'q4': {
      'category': 'inicio',
      'relatedQuestionIds': ['q1', 'q3', 'q7'],
    },
    'q5': {
      'category': 'problemas',
      'relatedQuestionIds': ['q6', 'q8', 'q9'],
    },
    'q6': {
      'category': 'problemas',
      'relatedQuestionIds': ['q3', 'q5', 'q10'],
    },
    'q7': {
      'category': 'problemas',
      'relatedQuestionIds': ['q4', 'q11', 'q12'],
    },
    'q8': {
      'category': 'almacenamiento',
      'relatedQuestionIds': ['q9', 'q13', 'q14'],
    },
    'q9': {
      'category': 'almacenamiento',
      'relatedQuestionIds': ['q8', 'q5', 'q15'],
    },
    'q10': {
      'category': 'beneficios',
      'relatedQuestionIds': ['q11', 'q12', 'q16'],
    },
    'q11': {
      'category': 'beneficios',
      'relatedQuestionIds': ['q10', 'q12', 'q17'],
    },
    'q12': {
      'category': 'beneficios',
      'relatedQuestionIds': ['q11', 'q10', 'q18'],
    },
    'q13': {
      'category': 'duracion',
      'relatedQuestionIds': ['q14', 'q15', 'q19'],
    },
    'q14': {
      'category': 'duracion',
      'relatedQuestionIds': ['q13', 'q20', 'q21'],
    },
    'q15': {
      'category': 'problemas',
      'relatedQuestionIds': ['q12', 'q5', 'q22'],
    },
    'q16': {
      'category': 'problemas',
      'relatedQuestionIds': ['q6', 'q3', 'q5'],
    },
    'q17': {
      'category': 'beneficios',
      'relatedQuestionIds': ['q11', 'q10', 'q23'],
    },
    'q18': {
      'category': 'inicio',
      'relatedQuestionIds': ['q2', 'q3', 'q24'],
    },
    'q19': {
      'category': 'problemas',
      'relatedQuestionIds': ['q4', 'q9', 'q7'],
    },
    'q20': {
      'category': 'beneficios',
      'relatedQuestionIds': ['q10', 'q18', 'q25'],
    },
    'q21': {
      'category': 'inicio',
      'relatedQuestionIds': ['q1', 'q4', 'q13'],
    },
    'q22': {
      'category': 'problemas',
      'relatedQuestionIds': ['q7', 'q19', 'q4'],
    },
    'q23': {
      'category': 'problemas',
      'relatedQuestionIds': ['q3', 'q6', 'q18'],
    },
    'q24': {
      'category': 'problemas',
      'relatedQuestionIds': ['q5', 'q7', 'q16'],
    },
    'q25': {
      'category': 'beneficios',
      'relatedQuestionIds': ['q1', 'q10', 'q13'],
    },
  };

  // Base de conocimiento de preguntas predefinidas (las traducciones se obtienen dinámicamente)
  List<PredefinedQuestion> get _questions {
    return _questionsStructureStatic.keys.map((id) {
      final structure = _questionsStructureStatic[id]!;
      return _createTranslatedQuestion(
        id: id,
        category: structure['category'] as String,
        relatedQuestionIds: List<String>.from(
          structure['relatedQuestionIds'] as List,
        ),
      );
    }).toList();
  }

  /// Obtiene todas las preguntas (con traducciones actualizadas)
  List<PredefinedQuestion> getAllQuestions() => List.unmodifiable(_questions);

  /// Obtiene una pregunta por ID (con traducciones actualizadas)
  PredefinedQuestion? getQuestionById(String id) {
    final structure = _questionsStructureStatic[id];
    if (structure == null) return null;

    // Crear pregunta con traducciones actuales
    return _createTranslatedQuestion(
      id: id,
      category: structure['category'] as String,
      relatedQuestionIds: List<String>.from(
        structure['relatedQuestionIds'] as List,
      ),
    );
  }

  /// Obtiene preguntas relacionadas a una pregunta específica
  List<PredefinedQuestion> getRelatedQuestions(
    String questionId, {
    int limit = 3,
  }) {
    final question = getQuestionById(questionId);
    if (question == null) return [];

    final structure = _questionsStructureStatic[questionId];
    if (structure == null) return [];

    final relatedQuestionIds = List<String>.from(
      structure['relatedQuestionIds'] as List,
    );
    final category = structure['category'] as String;

    final relatedQuestions = relatedQuestionIds
        .map((id) => getQuestionById(id))
        .whereType<PredefinedQuestion>()
        .toList();

    // Si no hay suficientes preguntas relacionadas, agregar preguntas de la misma categoría
    if (relatedQuestions.length < limit) {
      final sameCategoryQuestions = _questionsStructureStatic.entries
          .where(
            (entry) =>
                entry.value['category'] == category &&
                entry.key != questionId &&
                !relatedQuestionIds.contains(entry.key),
          )
          .take(limit - relatedQuestions.length)
          .map((entry) => getQuestionById(entry.key))
          .whereType<PredefinedQuestion>()
          .toList();
      relatedQuestions.addAll(sameCategoryQuestions);
    }

    // Si aún no hay suficientes, agregar preguntas aleatorias de otras categorías
    if (relatedQuestions.length < limit) {
      final random = Random.secure();
      final otherQuestions =
          _questionsStructureStatic.entries
              .where(
                (entry) =>
                    entry.key != questionId &&
                    !relatedQuestionIds.contains(entry.key) &&
                    !relatedQuestions.any((rq) => rq.id == entry.key),
              )
              .toList()
            ..shuffle(random);
      relatedQuestions.addAll(
        otherQuestions
            .take(limit - relatedQuestions.length)
            .map((entry) => getQuestionById(entry.key))
            .whereType<PredefinedQuestion>()
            .toList(),
      );
    }

    return relatedQuestions.take(limit).toList();
  }

  /// Obtiene preguntas aleatorias para mostrar inicialmente
  List<PredefinedQuestion> getRandomQuestions({int count = 3}) {
    // Usar Random.secure() para mejor seguridad
    final random = Random.secure();
    final questionIds = List<String>.from(_questionsStructureStatic.keys)
      ..shuffle(random);
    return questionIds
        .take(count)
        .map((id) => getQuestionById(id))
        .whereType<PredefinedQuestion>()
        .toList();
  }

  /// Obtiene preguntas rotadas (excluyendo las ya mostradas)
  List<PredefinedQuestion> getRotatedQuestions(
    List<String> shownQuestionIds, {
    int count = 3,
  }) {
    final availableQuestionIds = _questionsStructureStatic.keys
        .where((id) => !shownQuestionIds.contains(id))
        .toList();

    if (availableQuestionIds.isEmpty) {
      // Si todas las preguntas ya se mostraron, reiniciar
      return getRandomQuestions(count: count);
    }

    // Usar Random.secure() para mejor seguridad
    final random = Random.secure();
    availableQuestionIds.shuffle(random);

    return availableQuestionIds
        .take(count)
        .map((id) => getQuestionById(id))
        .whereType<PredefinedQuestion>()
        .toList();
  }

  /// Obtiene preguntas por categoría
  List<PredefinedQuestion> getQuestionsByCategory(String category) {
    return _questionsStructureStatic.entries
        .where((entry) => entry.value['category'] == category)
        .map((entry) => getQuestionById(entry.key))
        .whereType<PredefinedQuestion>()
        .toList();
  }
}

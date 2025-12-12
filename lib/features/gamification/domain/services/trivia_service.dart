import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import '../entities/trivia_question.dart';

/// Servicio para gestionar preguntas de trivia después de cada lección
class TriviaService {
  static final TriviaService _instance = TriviaService._internal();
  factory TriviaService() => _instance;
  TriviaService._internal();

  /// Obtiene preguntas de trivia para una lección específica
  /// Retorna 3-4 preguntas relacionadas con el contenido de la lección
  List<TriviaQuestion> getTriviaForLesson(String lessonId) {
    // Convertir lessonId a número para identificar la lección
    final lessonNumber = int.tryParse(lessonId) ?? 0;

    switch (lessonNumber) {
      case 1:
        return _getLesson1Questions(lessonId);
      case 2:
        return _getLesson2Questions(lessonId);
      case 3:
        return _getLesson3Questions(lessonId);
      case 4:
        return _getLesson4Questions(lessonId);
      case 5:
        return _getLesson5Questions(lessonId);
      case 6:
        return _getLesson6Questions(lessonId);
      case 7:
        return _getLesson7Questions(lessonId);
      case 8:
        return _getLesson8Questions(lessonId);
      case 9:
        return _getLesson9Questions(lessonId);
      case 10:
        return _getLesson10Questions(lessonId);
      case 11:
        return _getLesson11Questions(lessonId);
      case 12:
        return _getLesson12Questions(lessonId);
      case 13:
        return _getLesson13Questions(lessonId);
      case 14:
        return _getLesson14Questions(lessonId);
      default:
        return _getGenericLactationTrivia(lessonId);
    }
  }

  // Lección 1: Lactancia materna y sus beneficios
  List<TriviaQuestion> _getLesson1Questions(String lessonId) {
    // #region agent log
    if (kDebugMode) {
      try {
        final testQ1 = 'trivia.lessons.lesson1.question1.text'.tr();
        final testO1 = 'trivia.lessons.lesson1.question1.option1'.tr();
        final testO2 = 'trivia.lessons.lesson1.question1.option2'.tr();
        print('🔍 [TriviaService] Test traducciones:');
        print('   Q1: $testQ1');
        print('   O1: $testO1');
        print('   O2: $testO2');
      } catch (e) {
        print('❌ [TriviaService] Error en traducciones: $e');
      }
    }
    // #endregion

    // Evaluar traducciones y crear opciones
    final q1 = 'trivia.lessons.lesson1.question1.text'.tr();
    final q1Opt1 = 'trivia.lessons.lesson1.question1.option1'.tr();
    final q1Opt2 = 'trivia.lessons.lesson1.question1.option2'.tr();
    final q1Opt3 = 'trivia.lessons.lesson1.question1.option3'.tr();
    final q1Opt4 = 'trivia.lessons.lesson1.question1.option4'.tr();
    final q1Exp = 'trivia.lessons.lesson1.question1.explanation'.tr();

    // #region agent log
    if (kDebugMode) {
      print('🔍 [TriviaService] Valores evaluados para pregunta 1:');
      print('   Pregunta: $q1');
      print('   Opción 1: $q1Opt1');
      print('   Opción 2: $q1Opt2');
      print('   Opción 3: $q1Opt3');
      print('   Opción 4: $q1Opt4');
    }
    // #endregion

    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question: q1,
        options: [q1Opt1, q1Opt2, q1Opt3, q1Opt4],
        correctAnswerIndex: 1,
        explanation: q1Exp,
      ),
      // Pregunta 2
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson1.question2.text'.tr(),
        options: [
          'trivia.lessons.lesson1.question2.option1'.tr(),
          'trivia.lessons.lesson1.question2.option2'.tr(),
          'trivia.lessons.lesson1.question2.option3'.tr(),
          'trivia.lessons.lesson1.question2.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson1.question2.explanation'.tr(),
      ),
      // Pregunta 3
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson1.question3.text'.tr(),
        options: [
          'trivia.lessons.lesson1.question3.option1'.tr(),
          'trivia.lessons.lesson1.question3.option2'.tr(),
          'trivia.lessons.lesson1.question3.option3'.tr(),
          'trivia.lessons.lesson1.question3.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson1.question3.explanation'.tr(),
      ),
      // Pregunta 4
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson1.question4.text'.tr(),
        options: [
          'trivia.lessons.lesson1.question4.option1'.tr(),
          'trivia.lessons.lesson1.question4.option2'.tr(),
          'trivia.lessons.lesson1.question4.option3'.tr(),
          'trivia.lessons.lesson1.question4.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson1.question4.explanation'.tr(),
      ),
    ];
  }

  // Lección 2: Calostro, leche de transición y leche madura
  List<TriviaQuestion> _getLesson2Questions(String lessonId) {
    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson2.question1.text'.tr(),
        options: [
          'trivia.lessons.lesson2.question1.option1'.tr(),
          'trivia.lessons.lesson2.question1.option2'.tr(),
          'trivia.lessons.lesson2.question1.option3'.tr(),
          'trivia.lessons.lesson2.question1.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson2.question1.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson2.question2.text'.tr(),
        options: [
          'trivia.lessons.lesson2.question2.option1'.tr(),
          'trivia.lessons.lesson2.question2.option2'.tr(),
          'trivia.lessons.lesson2.question2.option3'.tr(),
          'trivia.lessons.lesson2.question2.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson2.question2.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson2.question3.text'.tr(),
        options: [
          'trivia.lessons.lesson2.question3.option1'.tr(),
          'trivia.lessons.lesson2.question3.option2'.tr(),
          'trivia.lessons.lesson2.question3.option3'.tr(),
          'trivia.lessons.lesson2.question3.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson2.question3.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson2.question4.text'.tr(),
        options: [
          'trivia.lessons.lesson2.question4.option1'.tr(),
          'trivia.lessons.lesson2.question4.option2'.tr(),
          'trivia.lessons.lesson2.question4.option3'.tr(),
          'trivia.lessons.lesson2.question4.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson2.question4.explanation'.tr(),
      ),
    ];
  }

  // Lección 3: Cosas a considerar al momento de amamantar
  List<TriviaQuestion> _getLesson3Questions(String lessonId) {
    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson3.question1.text'.tr(),
        options: [
          'trivia.lessons.lesson3.question1.option1'.tr(),
          'trivia.lessons.lesson3.question1.option2'.tr(),
          'trivia.lessons.lesson3.question1.option3'.tr(),
          'trivia.lessons.lesson3.question1.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson3.question1.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson3.question2.text'.tr(),
        options: [
          'trivia.lessons.lesson3.question2.option1'.tr(),
          'trivia.lessons.lesson3.question2.option2'.tr(),
          'trivia.lessons.lesson3.question2.option3'.tr(),
          'trivia.lessons.lesson3.question2.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson3.question2.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson3.question3.text'.tr(),
        options: [
          'trivia.lessons.lesson3.question3.option1'.tr(),
          'trivia.lessons.lesson3.question3.option2'.tr(),
          'trivia.lessons.lesson3.question3.option3'.tr(),
          'trivia.lessons.lesson3.question3.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson3.question3.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson3.question4.text'.tr(),
        options: [
          'trivia.lessons.lesson3.question4.option1'.tr(),
          'trivia.lessons.lesson3.question4.option2'.tr(),
          'trivia.lessons.lesson3.question4.option3'.tr(),
          'trivia.lessons.lesson3.question4.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson3.question4.explanation'.tr(),
      ),
    ];
  }

  // Lección 4: Composición Nutricional de la Leche Materna
  List<TriviaQuestion> _getLesson4Questions(String lessonId) {
    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson4.question1.text'.tr(),
        options: [
          'trivia.lessons.lesson4.question1.option1'.tr(),
          'trivia.lessons.lesson4.question1.option2'.tr(),
          'trivia.lessons.lesson4.question1.option3'.tr(),
          'trivia.lessons.lesson4.question1.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson4.question1.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson4.question2.text'.tr(),
        options: [
          'trivia.lessons.lesson4.question2.option1'.tr(),
          'trivia.lessons.lesson4.question2.option2'.tr(),
          'trivia.lessons.lesson4.question2.option3'.tr(),
          'trivia.lessons.lesson4.question2.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson4.question2.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson4.question3.text'.tr(),
        options: [
          'trivia.lessons.lesson4.question3.option1'.tr(),
          'trivia.lessons.lesson4.question3.option2'.tr(),
          'trivia.lessons.lesson4.question3.option3'.tr(),
          'trivia.lessons.lesson4.question3.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson4.question3.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson4.question4.text'.tr(),
        options: [
          'trivia.lessons.lesson4.question4.option1'.tr(),
          'trivia.lessons.lesson4.question4.option2'.tr(),
          'trivia.lessons.lesson4.question4.option3'.tr(),
          'trivia.lessons.lesson4.question4.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson4.question4.explanation'.tr(),
      ),
    ];
  }

  // Lección 5: ¿Cómo saber que el bebé se alimentó lo suficiente?
  List<TriviaQuestion> _getLesson5Questions(String lessonId) {
    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson5.question1.text'.tr(),
        options: [
          'trivia.lessons.lesson5.question1.option1'.tr(),
          'trivia.lessons.lesson5.question1.option2'.tr(),
          'trivia.lessons.lesson5.question1.option3'.tr(),
          'trivia.lessons.lesson5.question1.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson5.question1.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson5.question2.text'.tr(),
        options: [
          'trivia.lessons.lesson5.question2.option1'.tr(),
          'trivia.lessons.lesson5.question2.option2'.tr(),
          'trivia.lessons.lesson5.question2.option3'.tr(),
          'trivia.lessons.lesson5.question2.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson5.question2.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson5.question3.text'.tr(),
        options: [
          'trivia.lessons.lesson5.question3.option1'.tr(),
          'trivia.lessons.lesson5.question3.option2'.tr(),
          'trivia.lessons.lesson5.question3.option3'.tr(),
          'trivia.lessons.lesson5.question3.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson5.question3.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson5.question4.text'.tr(),
        options: [
          'trivia.lessons.lesson5.question4.option1'.tr(),
          'trivia.lessons.lesson5.question4.option2'.tr(),
          'trivia.lessons.lesson5.question4.option3'.tr(),
          'trivia.lessons.lesson5.question4.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson5.question4.explanation'.tr(),
      ),
    ];
  }

  // Lección 6: Hitos de peso a vigilar
  List<TriviaQuestion> _getLesson6Questions(String lessonId) {
    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson6.question1.text'.tr(),
        options: [
          'trivia.lessons.lesson6.question1.option1'.tr(),
          'trivia.lessons.lesson6.question1.option2'.tr(),
          'trivia.lessons.lesson6.question1.option3'.tr(),
          'trivia.lessons.lesson6.question1.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson6.question1.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson6.question2.text'.tr(),
        options: [
          'trivia.lessons.lesson6.question2.option1'.tr(),
          'trivia.lessons.lesson6.question2.option2'.tr(),
          'trivia.lessons.lesson6.question2.option3'.tr(),
          'trivia.lessons.lesson6.question2.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson6.question2.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson6.question3.text'.tr(),
        options: [
          'trivia.lessons.lesson6.question3.option1'.tr(),
          'trivia.lessons.lesson6.question3.option2'.tr(),
          'trivia.lessons.lesson6.question3.option3'.tr(),
          'trivia.lessons.lesson6.question3.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson6.question3.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson6.question4.text'.tr(),
        options: [
          'trivia.lessons.lesson6.question4.option1'.tr(),
          'trivia.lessons.lesson6.question4.option2'.tr(),
          'trivia.lessons.lesson6.question4.option3'.tr(),
          'trivia.lessons.lesson6.question4.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson6.question4.explanation'.tr(),
      ),
    ];
  }

  // Lección 7: Higiene de manos y técnicas de lactancia materna
  List<TriviaQuestion> _getLesson7Questions(String lessonId) {
    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson7.question1.text'.tr(),
        options: [
          'trivia.lessons.lesson7.question1.option1'.tr(),
          'trivia.lessons.lesson7.question1.option2'.tr(),
          'trivia.lessons.lesson7.question1.option3'.tr(),
          'trivia.lessons.lesson7.question1.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson7.question1.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson7.question2.text'.tr(),
        options: [
          'trivia.lessons.lesson7.question2.option1'.tr(),
          'trivia.lessons.lesson7.question2.option2'.tr(),
          'trivia.lessons.lesson7.question2.option3'.tr(),
          'trivia.lessons.lesson7.question2.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson7.question2.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson7.question3.text'.tr(),
        options: [
          'trivia.lessons.lesson7.question3.option1'.tr(),
          'trivia.lessons.lesson7.question3.option2'.tr(),
          'trivia.lessons.lesson7.question3.option3'.tr(),
          'trivia.lessons.lesson7.question3.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson7.question3.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson7.question4.text'.tr(),
        options: [
          'trivia.lessons.lesson7.question4.option1'.tr(),
          'trivia.lessons.lesson7.question4.option2'.tr(),
          'trivia.lessons.lesson7.question4.option3'.tr(),
          'trivia.lessons.lesson7.question4.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson7.question4.explanation'.tr(),
      ),
    ];
  }

  // Lección 8: Medicamentos durante la lactancia materna
  List<TriviaQuestion> _getLesson8Questions(String lessonId) {
    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson8.question1.text'.tr(),
        options: [
          'trivia.lessons.lesson8.question1.option1'.tr(),
          'trivia.lessons.lesson8.question1.option2'.tr(),
          'trivia.lessons.lesson8.question1.option3'.tr(),
          'trivia.lessons.lesson8.question1.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson8.question1.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson8.question2.text'.tr(),
        options: [
          'trivia.lessons.lesson8.question2.option1'.tr(),
          'trivia.lessons.lesson8.question2.option2'.tr(),
          'trivia.lessons.lesson8.question2.option3'.tr(),
          'trivia.lessons.lesson8.question2.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson8.question2.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson8.question3.text'.tr(),
        options: [
          'trivia.lessons.lesson8.question3.option1'.tr(),
          'trivia.lessons.lesson8.question3.option2'.tr(),
          'trivia.lessons.lesson8.question3.option3'.tr(),
          'trivia.lessons.lesson8.question3.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson8.question3.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson8.question4.text'.tr(),
        options: [
          'trivia.lessons.lesson8.question4.option1'.tr(),
          'trivia.lessons.lesson8.question4.option2'.tr(),
          'trivia.lessons.lesson8.question4.option3'.tr(),
          'trivia.lessons.lesson8.question4.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson8.question4.explanation'.tr(),
      ),
    ];
  }

  // Lección 9: Signos o Complicaciones en la Lactancia
  List<TriviaQuestion> _getLesson9Questions(String lessonId) {
    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson9.question1.text'.tr(),
        options: [
          'trivia.lessons.lesson9.question1.option1'.tr(),
          'trivia.lessons.lesson9.question1.option2'.tr(),
          'trivia.lessons.lesson9.question1.option3'.tr(),
          'trivia.lessons.lesson9.question1.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson9.question1.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson9.question2.text'.tr(),
        options: [
          'trivia.lessons.lesson9.question2.option1'.tr(),
          'trivia.lessons.lesson9.question2.option2'.tr(),
          'trivia.lessons.lesson9.question2.option3'.tr(),
          'trivia.lessons.lesson9.question2.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson9.question2.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson9.question3.text'.tr(),
        options: [
          'trivia.lessons.lesson9.question3.option1'.tr(),
          'trivia.lessons.lesson9.question3.option2'.tr(),
          'trivia.lessons.lesson9.question3.option3'.tr(),
          'trivia.lessons.lesson9.question3.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson9.question3.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson9.question4.text'.tr(),
        options: [
          'trivia.lessons.lesson9.question4.option1'.tr(),
          'trivia.lessons.lesson9.question4.option2'.tr(),
          'trivia.lessons.lesson9.question4.option3'.tr(),
          'trivia.lessons.lesson9.question4.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson9.question4.explanation'.tr(),
      ),
    ];
  }

  // Lección 10: Masajes al seno antes de iniciar la lactancia
  List<TriviaQuestion> _getLesson10Questions(String lessonId) {
    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson10.question1.text'.tr(),
        options: [
          'trivia.lessons.lesson10.question1.option1'.tr(),
          'trivia.lessons.lesson10.question1.option2'.tr(),
          'trivia.lessons.lesson10.question1.option3'.tr(),
          'trivia.lessons.lesson10.question1.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson10.question1.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson10.question2.text'.tr(),
        options: [
          'trivia.lessons.lesson10.question2.option1'.tr(),
          'trivia.lessons.lesson10.question2.option2'.tr(),
          'trivia.lessons.lesson10.question2.option3'.tr(),
          'trivia.lessons.lesson10.question2.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson10.question2.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson10.question3.text'.tr(),
        options: [
          'trivia.lessons.lesson10.question3.option1'.tr(),
          'trivia.lessons.lesson10.question3.option2'.tr(),
          'trivia.lessons.lesson10.question3.option3'.tr(),
          'trivia.lessons.lesson10.question3.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson10.question3.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson10.question4.text'.tr(),
        options: [
          'trivia.lessons.lesson10.question4.option1'.tr(),
          'trivia.lessons.lesson10.question4.option2'.tr(),
          'trivia.lessons.lesson10.question4.option3'.tr(),
          'trivia.lessons.lesson10.question4.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson10.question4.explanation'.tr(),
      ),
    ];
  }

  // Lección 11: Mi banco de leche en casa y su preservación
  List<TriviaQuestion> _getLesson11Questions(String lessonId) {
    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson11.question1.text'.tr(),
        options: [
          'trivia.lessons.lesson11.question1.option1'.tr(),
          'trivia.lessons.lesson11.question1.option2'.tr(),
          'trivia.lessons.lesson11.question1.option3'.tr(),
          'trivia.lessons.lesson11.question1.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson11.question1.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson11.question2.text'.tr(),
        options: [
          'trivia.lessons.lesson11.question2.option1'.tr(),
          'trivia.lessons.lesson11.question2.option2'.tr(),
          'trivia.lessons.lesson11.question2.option3'.tr(),
          'trivia.lessons.lesson11.question2.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson11.question2.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson11.question3.text'.tr(),
        options: [
          'trivia.lessons.lesson11.question3.option1'.tr(),
          'trivia.lessons.lesson11.question3.option2'.tr(),
          'trivia.lessons.lesson11.question3.option3'.tr(),
          'trivia.lessons.lesson11.question3.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson11.question3.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson11.question4.text'.tr(),
        options: [
          'trivia.lessons.lesson11.question4.option1'.tr(),
          'trivia.lessons.lesson11.question4.option2'.tr(),
          'trivia.lessons.lesson11.question4.option3'.tr(),
          'trivia.lessons.lesson11.question4.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson11.question4.explanation'.tr(),
      ),
    ];
  }

  // Lección 12: Leyes en Panamá que apoyan la lactancia materna
  List<TriviaQuestion> _getLesson12Questions(String lessonId) {
    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson12.question1.text'.tr(),
        options: [
          'trivia.lessons.lesson12.question1.option1'.tr(),
          'trivia.lessons.lesson12.question1.option2'.tr(),
          'trivia.lessons.lesson12.question1.option3'.tr(),
          'trivia.lessons.lesson12.question1.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson12.question1.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson12.question2.text'.tr(),
        options: [
          'trivia.lessons.lesson12.question2.option1'.tr(),
          'trivia.lessons.lesson12.question2.option2'.tr(),
          'trivia.lessons.lesson12.question2.option3'.tr(),
          'trivia.lessons.lesson12.question2.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson12.question2.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson12.question3.text'.tr(),
        options: [
          'trivia.lessons.lesson12.question3.option1'.tr(),
          'trivia.lessons.lesson12.question3.option2'.tr(),
          'trivia.lessons.lesson12.question3.option3'.tr(),
          'trivia.lessons.lesson12.question3.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson12.question3.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson12.question4.text'.tr(),
        options: [
          'trivia.lessons.lesson12.question4.option1'.tr(),
          'trivia.lessons.lesson12.question4.option2'.tr(),
          'trivia.lessons.lesson12.question4.option3'.tr(),
          'trivia.lessons.lesson12.question4.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson12.question4.explanation'.tr(),
      ),
    ];
  }

  // Lección 13: Diferencias entre la leche materna y la leche de vaca
  List<TriviaQuestion> _getLesson13Questions(String lessonId) {
    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson13.question1.text'.tr(),
        options: [
          'trivia.lessons.lesson13.question1.option1'.tr(),
          'trivia.lessons.lesson13.question1.option2'.tr(),
          'trivia.lessons.lesson13.question1.option3'.tr(),
          'trivia.lessons.lesson13.question1.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson13.question1.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson13.question2.text'.tr(),
        options: [
          'trivia.lessons.lesson13.question2.option1'.tr(),
          'trivia.lessons.lesson13.question2.option2'.tr(),
          'trivia.lessons.lesson13.question2.option3'.tr(),
          'trivia.lessons.lesson13.question2.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson13.question2.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson13.question3.text'.tr(),
        options: [
          'trivia.lessons.lesson13.question3.option1'.tr(),
          'trivia.lessons.lesson13.question3.option2'.tr(),
          'trivia.lessons.lesson13.question3.option3'.tr(),
          'trivia.lessons.lesson13.question3.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson13.question3.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson13.question4.text'.tr(),
        options: [
          'trivia.lessons.lesson13.question4.option1'.tr(),
          'trivia.lessons.lesson13.question4.option2'.tr(),
          'trivia.lessons.lesson13.question4.option3'.tr(),
          'trivia.lessons.lesson13.question4.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson13.question4.explanation'.tr(),
      ),
    ];
  }

  // Lección 14: Mitos de la lactancia materna
  List<TriviaQuestion> _getLesson14Questions(String lessonId) {
    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson14.question1.text'.tr(),
        options: [
          'trivia.lessons.lesson14.question1.option1'.tr(),
          'trivia.lessons.lesson14.question1.option2'.tr(),
          'trivia.lessons.lesson14.question1.option3'.tr(),
          'trivia.lessons.lesson14.question1.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson14.question1.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson14.question2.text'.tr(),
        options: [
          'trivia.lessons.lesson14.question2.option1'.tr(),
          'trivia.lessons.lesson14.question2.option2'.tr(),
          'trivia.lessons.lesson14.question2.option3'.tr(),
          'trivia.lessons.lesson14.question2.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson14.question2.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson14.question3.text'.tr(),
        options: [
          'trivia.lessons.lesson14.question3.option1'.tr(),
          'trivia.lessons.lesson14.question3.option2'.tr(),
          'trivia.lessons.lesson14.question3.option3'.tr(),
          'trivia.lessons.lesson14.question3.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson14.question3.explanation'.tr(),
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question: 'trivia.lessons.lesson14.question4.text'.tr(),
        options: [
          'trivia.lessons.lesson14.question4.option1'.tr(),
          'trivia.lessons.lesson14.question4.option2'.tr(),
          'trivia.lessons.lesson14.question4.option3'.tr(),
          'trivia.lessons.lesson14.question4.option4'.tr(),
        ],
        correctAnswerIndex: 1,
        explanation: 'trivia.lessons.lesson14.question4.explanation'.tr(),
      ),
    ];
  }

  /// Preguntas genéricas sobre lactancia materna (fallback)
  List<TriviaQuestion> _getGenericLactationTrivia(String lessonId) {
    return [
      TriviaQuestion(
        id: 'trivia_${lessonId}_1',
        lessonId: lessonId,
        question:
            '¿Cuál es la frecuencia recomendada de alimentación para un recién nacido?',
        options: const [
          'Cada 2-3 horas',
          'Cada 4-5 horas',
          'Solo cuando el bebé llora',
          'Una vez al día',
        ],
        correctAnswerIndex: 0,
        explanation:
            'Los recién nacidos deben alimentarse cada 2-3 horas para asegurar un crecimiento adecuado.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_2',
        lessonId: lessonId,
        question: '¿Cuánto tiempo debe durar una sesión de lactancia típica?',
        options: const [
          '5-10 minutos',
          '10-20 minutos por pecho',
          '30-45 minutos',
          'Más de 1 hora',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Una sesión típica de lactancia dura entre 10-20 minutos por pecho, aunque puede variar según el bebé.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_3',
        lessonId: lessonId,
        question: '¿Qué indica que el bebé está recibiendo suficiente leche?',
        options: const [
          'Llora constantemente',
          'Aumenta de peso adecuadamente y moja 6+ pañales al día',
          'Duerme todo el día',
          'Rechaza el pecho',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Un bebé que recibe suficiente leche aumenta de peso adecuadamente y moja al menos 6 pañales al día.',
      ),
      TriviaQuestion(
        id: 'trivia_${lessonId}_4',
        lessonId: lessonId,
        question:
            '¿Cuándo se debe buscar ayuda profesional para problemas de lactancia?',
        options: const [
          'Nunca, todo se resuelve solo',
          'Solo si hay dolor extremo',
          'Cuando hay dolor persistente, dificultades de agarre o preocupaciones sobre la alimentación',
          'Después de 6 meses',
        ],
        correctAnswerIndex: 2,
        explanation:
            'Es importante buscar ayuda profesional cuando hay dolor persistente, dificultades de agarre o cualquier preocupación sobre la alimentación del bebé.',
      ),
    ];
  }

  /// Verifica si una respuesta es correcta
  bool isAnswerCorrect(TriviaQuestion question, int selectedIndex) {
    return question.correctAnswerIndex == selectedIndex;
  }

  /// Calcula el puntaje de una trivia completada
  int calculateScore(
    List<TriviaQuestion> questions,
    List<int> selectedAnswers,
  ) {
    if (questions.length != selectedAnswers.length) {
      return 0;
    }

    int correct = 0;
    for (int i = 0; i < questions.length; i++) {
      if (isAnswerCorrect(questions[i], selectedAnswers[i])) {
        correct++;
      }
    }

    return correct;
  }
}

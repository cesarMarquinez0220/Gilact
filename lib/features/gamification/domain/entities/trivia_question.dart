import 'package:equatable/equatable.dart';

/// Pregunta de trivia relacionada con una lección
class TriviaQuestion extends Equatable {
  final String id;
  final String lessonId;
  final String question;
  final List<String> options; // Lista de opciones (máximo 4)
  final int correctAnswerIndex; // Índice de la respuesta correcta (0-3)
  final String? explanation; // Explicación opcional de la respuesta correcta

  const TriviaQuestion({
    required this.id,
    required this.lessonId,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation,
  }) : assert(
          options.length >= 2 && options.length <= 4,
          'Las opciones deben ser entre 2 y 4',
        ),
        assert(
          correctAnswerIndex >= 0 && correctAnswerIndex < options.length,
          'El índice de respuesta correcta debe ser válido',
        );

  @override
  List<Object?> get props => [
        id,
        lessonId,
        question,
        options,
        correctAnswerIndex,
        explanation,
      ];

  TriviaQuestion copyWith({
    String? id,
    String? lessonId,
    String? question,
    List<String>? options,
    int? correctAnswerIndex,
    String? explanation,
  }) {
    return TriviaQuestion(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      explanation: explanation ?? this.explanation,
    );
  }

  /// Convierte a Map para almacenamiento
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lessonId': lessonId,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
    };
  }

  /// Crea desde Map
  factory TriviaQuestion.fromMap(Map<String, dynamic> map) {
    return TriviaQuestion(
      id: map['id'] as String,
      lessonId: map['lessonId'] as String,
      question: map['question'] as String,
      options: List<String>.from(map['options'] as List),
      correctAnswerIndex: map['correctAnswerIndex'] as int,
      explanation: map['explanation'] as String?,
    );
  }
}


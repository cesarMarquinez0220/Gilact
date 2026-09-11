import 'package:equatable/equatable.dart';

/// Modelo para preguntas predefinidas con categorías y relaciones
class PredefinedQuestion extends Equatable {
  final String id;
  final String question;
  final String answer;
  final String category;
  final List<String> relatedQuestionIds; // IDs de preguntas relacionadas

  const PredefinedQuestion({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    required this.relatedQuestionIds,
  });

  @override
  List<Object?> get props => [id, question, answer, category, relatedQuestionIds];
}


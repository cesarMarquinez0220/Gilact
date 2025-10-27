import 'package:equatable/equatable.dart';

class ChatbotKnowledge extends Equatable {
  final String id;
  final String question;
  final String answer;
  final List<String> category;
  final List<String> keywords;
  final DateTime lastUpdated;

  const ChatbotKnowledge({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    required this.keywords,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
      'category': category,
      'keywords': keywords,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory ChatbotKnowledge.fromMap(Map<String, dynamic> map, String id) {
    return ChatbotKnowledge(
      id: id,
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      category: List<String>.from(map['category'] ?? []),
      keywords: List<String>.from(map['keywords'] ?? []),
      lastUpdated:
          DateTime.tryParse(map['lastUpdated'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    question,
    answer,
    category,
    keywords,
    lastUpdated,
  ];
}

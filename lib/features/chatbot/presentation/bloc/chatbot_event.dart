part of 'chatbot_bloc.dart';

abstract class ChatbotEvent extends Equatable {
  const ChatbotEvent();

  @override
  List<Object?> get props => [];
}

class SendMessage extends ChatbotEvent {
  final String question;
  final String userId;
  final List<ChatMessage> messages;
  final String? predefinedAnswer; // Respuesta predefinida (opcional)

  const SendMessage({
    required this.question,
    required this.userId,
    required this.messages,
    this.predefinedAnswer,
  });

  @override
  List<Object?> get props => [question, userId, messages, predefinedAnswer];
}

class LoadChatHistory extends ChatbotEvent {
  final String userId;

  const LoadChatHistory({required this.userId});

  @override
  List<Object> get props => [userId];
}

class ClearChat extends ChatbotEvent {
  const ClearChat();
}

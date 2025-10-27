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

  const SendMessage({
    required this.question,
    required this.userId,
    required this.messages,
  });

  @override
  List<Object> get props => [question, userId, messages];
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

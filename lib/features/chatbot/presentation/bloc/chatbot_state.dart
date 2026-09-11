part of 'chatbot_bloc.dart';

abstract class ChatbotState extends Equatable {
  const ChatbotState();

  @override
  List<Object?> get props => [];
}

class ChatbotInitial extends ChatbotState {
  const ChatbotInitial();
}

class ChatbotLoading extends ChatbotState {
  const ChatbotLoading();
}

class ChatbotLoaded extends ChatbotState {
  final List<ChatMessage> messages;

  const ChatbotLoaded(this.messages);

  @override
  List<Object> get props => [messages];
}

class ChatbotError extends ChatbotState {
  final String message;

  const ChatbotError(this.message);

  @override
  List<Object> get props => [message];
}

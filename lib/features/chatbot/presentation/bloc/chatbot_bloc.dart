import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/chatbot_usecases.dart';

part 'chatbot_event.dart';
part 'chatbot_state.dart';

@injectable
class ChatbotBloc extends Bloc<ChatbotEvent, ChatbotState> {
  final SendMessageUseCase _sendMessageUseCase;

  ChatbotBloc({required SendMessageUseCase sendMessageUseCase})
    : _sendMessageUseCase = sendMessageUseCase,
      super(ChatbotInitial()) {
    on<SendMessage>(_onSendMessage);
    on<LoadChatHistory>(_onLoadChatHistory);
    on<ClearChat>(_onClearChat);
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatbotState> emit,
  ) async {
    // Añadir mensaje del usuario al estado actual
    final currentMessages = state is ChatbotLoaded
        ? (state as ChatbotLoaded).messages
        : <ChatMessage>[];

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: event.question,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final updatedMessages = [...currentMessages, userMessage];

    emit(ChatbotLoaded(updatedMessages));

    // Mostrar estado de carga
    emit(ChatbotLoading());

    // Obtener respuesta del chatbot
    final result = await _sendMessageUseCase(
      SendMessageParams(question: event.question),
    );

    result.fold((failure) => emit(ChatbotError(failure.message)), (answer) {
      final botMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: answer,
        isUser: false,
        timestamp: DateTime.now(),
      );

      final finalMessages = [...updatedMessages, botMessage];
      emit(ChatbotLoaded(finalMessages));
    });
  }

  Future<void> _onLoadChatHistory(
    LoadChatHistory event,
    Emitter<ChatbotState> emit,
  ) async {
    emit(ChatbotLoading());
    // El historial se carga desde el repositorio si es necesario
    emit(const ChatbotLoaded([]));
  }

  void _onClearChat(ClearChat event, Emitter<ChatbotState> emit) {
    emit(const ChatbotLoaded([]));
  }
}

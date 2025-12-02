import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/chatbot_usecases.dart';
import '../../../../core/services/connectivity_service.dart';

part 'chatbot_event.dart';
part 'chatbot_state.dart';

@injectable
class ChatbotBloc extends Bloc<ChatbotEvent, ChatbotState> {
  final SendMessageUseCase _sendMessageUseCase;
  final ConnectivityService _connectivityService = ConnectivityService();

  ChatbotBloc({required SendMessageUseCase sendMessageUseCase})
    : _sendMessageUseCase = sendMessageUseCase,
      super(const ChatbotInitial()) {
    on<SendMessage>(_onSendMessage);
    on<LoadChatHistory>(_onLoadChatHistory);
    on<ClearChat>(_onClearChat);
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatbotState> emit,
  ) async {
    // Verificar conectividad antes de enviar mensaje
    final isConnected = await _connectivityService.isConnected();
    
    if (!isConnected) {
      // Sin conexión: mostrar mensaje de error
      final currentMessages = state is ChatbotLoaded
          ? (state as ChatbotLoaded).messages
          : <ChatMessage>[];

      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: event.question,
        isUser: true,
        timestamp: DateTime.now(),
      );

      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Es necesario tener conexión a internet para obtener una respuesta del chatbot. Por favor, verifica tu conexión e intenta nuevamente.',
        isUser: false,
        timestamp: DateTime.now(),
      );

      final updatedMessages = [...currentMessages, userMessage, errorMessage];
      emit(ChatbotLoaded(updatedMessages));
      return;
    }

    // Si hay una respuesta predefinida, usarla directamente sin llamar a la API
    if (event.predefinedAnswer != null && event.predefinedAnswer!.isNotEmpty) {
      final currentMessages = event.messages.isNotEmpty
          ? event.messages
          : (state is ChatbotLoaded
              ? (state as ChatbotLoaded).messages
              : <ChatMessage>[]);

      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: event.question,
        isUser: true,
        timestamp: DateTime.now(),
      );

      final botMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_bot',
        text: event.predefinedAnswer!,
        isUser: false,
        timestamp: DateTime.now(),
      );

      final finalMessages = [...currentMessages, userMessage, botMessage];
      emit(ChatbotLoaded(finalMessages));
      return;
    }

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
    emit(const ChatbotLoading());

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
    emit(const ChatbotLoading());
    // El historial se carga desde el repositorio si es necesario
    emit(const ChatbotLoaded([]));
  }

  void _onClearChat(ClearChat event, Emitter<ChatbotState> emit) {
    emit(const ChatbotLoaded([]));
  }
}

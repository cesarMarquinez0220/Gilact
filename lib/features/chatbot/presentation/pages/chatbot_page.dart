import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/predefined_question.dart';
import '../../domain/services/predefined_questions_service.dart';
import '../bloc/chatbot_bloc.dart';

class ChatbotPage extends StatefulWidget {
  final String? userId;

  const ChatbotPage({super.key, this.userId});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final ScrollController _scrollController = ScrollController();
  final PredefinedQuestionsService _questionsService = PredefinedQuestionsService();
  
  // Preguntas actualmente mostradas
  List<PredefinedQuestion> _currentQuestions = [];
  // IDs de preguntas que ya se han mostrado (para rotación)
  final Set<String> _shownQuestionIds = {};
  // ID de la última pregunta seleccionada (para mostrar preguntas relacionadas)
  String? _lastSelectedQuestionId;

  @override
  void initState() {
    super.initState();
    _loadInitialQuestions();
  }

  void _loadInitialQuestions() {
    setState(() {
      _currentQuestions = _questionsService.getRandomQuestions(count: 3);
      _shownQuestionIds.addAll(_currentQuestions.map((q) => q.id));
    });
  }

  void _refreshQuestions() {
    setState(() {
      _currentQuestions = _questionsService.getRotatedQuestions(
        _shownQuestionIds.toList(),
        count: 3,
      );
      _shownQuestionIds.addAll(_currentQuestions.map((q) => q.id));
      _lastSelectedQuestionId = null; // Resetear para mostrar preguntas generales
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _selectQuestion(PredefinedQuestion question) {
    final bloc = context.read<ChatbotBloc>();
    final currentState = bloc.state;
    final List<ChatMessage> messages = currentState is ChatbotLoaded
        ? currentState.messages
        : [];

    // Enviar mensaje con respuesta predefinida
    bloc.add(SendMessage(
      question: question.question,
      userId: widget.userId ?? 'default_user',
      messages: messages,
      predefinedAnswer: question.answer, // Pasar la respuesta predefinida
    ));

    // Actualizar preguntas mostradas con preguntas relacionadas
    setState(() {
      _lastSelectedQuestionId = question.id;
      _currentQuestions = _questionsService.getRelatedQuestions(
        question.id,
        limit: 3,
      );
      _shownQuestionIds.addAll(_currentQuestions.map((q) => q.id));
    });

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A365D), // Azul marino oscuro
              Color(0xFF2C5F5D), // Azul teal oscuro
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: BlocConsumer<ChatbotBloc, ChatbotState>(
                  listener: (context, state) {
                    if (state is ChatbotLoaded) {
                      _scrollToBottom();
                    }
                  },
                  builder: (context, state) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: state is ChatbotLoaded
                                ? (state.messages.isEmpty
                                      ? _EmptyChatWidget(
                                          questions: _currentQuestions,
                                          onRefresh: _refreshQuestions,
                                          onQuestionSelected: _selectQuestion,
                                        )
                                      : _buildMessageList(
                                          state.messages,
                                          _currentQuestions,
                                          _refreshQuestions,
                                          _selectQuestion,
                                        ))
                                : state is ChatbotLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : _EmptyChatWidget(
                                    questions: _currentQuestions,
                                    onRefresh: _refreshQuestions,
                                    onQuestionSelected: _selectQuestion,
                                  ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
              ),
              tooltip: 'Volver',
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'chatbot.title'.tr(),
                  style: GoogleFonts.quicksand(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'chatbot.subtitle'.tr(),
                  style: GoogleFonts.quicksand(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(
    List<ChatMessage> messages,
    List<PredefinedQuestion> currentQuestions,
    VoidCallback onRefresh,
    Function(PredefinedQuestion) onQuestionSelected,
  ) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return _buildMessageBubble(messages[index]);
            },
          ),
        ),
        // Mostrar preguntas relacionadas después de los mensajes
        if (currentQuestions.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Preguntas relacionadas',
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: onRefresh,
                      child: Row(
                        children: [
                          const Icon(Icons.refresh_rounded, size: 16, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            'Otras preguntas',
                            style: GoogleFonts.quicksand(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...currentQuestions.map(
                  (question) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildQuestionChip(question, onQuestionSelected),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: message.isUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!message.isUser) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: message.isUser
                      ? const Color(0xFF4FD1C7).withValues(alpha: 0.95)
                      : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Text(
                  message.text,
                  style: GoogleFonts.quicksand(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            if (message.isUser) ...[
              const SizedBox(width: 10),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionChip(
    PredefinedQuestion question,
    Function(PredefinedQuestion) onTap,
  ) {
    return InkWell(
      onTap: () => onTap(question),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                question.question,
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChatWidget extends StatelessWidget {
  final List<PredefinedQuestion> questions;
  final VoidCallback onRefresh;
  final Function(PredefinedQuestion) onQuestionSelected;

  const _EmptyChatWidget({
    required this.questions,
    required this.onRefresh,
    required this.onQuestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '¡Hola! 👋',
              style: GoogleFonts.quicksand(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Soy tu asistente virtual',
              style: GoogleFonts.quicksand(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pregúntame sobre lactancia materna',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 15,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Preguntas frecuentes',
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.refresh_rounded, size: 16, color: Colors.white70),
                GestureDetector(
                  onTap: onRefresh,
                  child: Text(
                    ' Actualizar',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...questions.map(
              (question) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildQuestionChip(context, question),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionChip(BuildContext context, PredefinedQuestion question) {
    return InkWell(
      onTap: () => onQuestionSelected(question),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                question.question,
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}

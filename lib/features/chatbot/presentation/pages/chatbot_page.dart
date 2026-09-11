import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/predefined_question.dart';
import '../../domain/services/predefined_questions_service.dart';
import '../bloc/chatbot_bloc.dart';
import '../../../../core/utils/responsive_helper.dart';

class ChatbotPage extends StatefulWidget {
  final String? userId;

  const ChatbotPage({super.key, this.userId});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final ScrollController _scrollController = ScrollController();
  final PredefinedQuestionsService _questionsService =
      PredefinedQuestionsService();

  // Preguntas actualmente mostradas
  List<PredefinedQuestion> _currentQuestions = [];
  // IDs de preguntas que ya se han mostrado (para rotación)
  final Set<String> _shownQuestionIds = {};
  // ID de la última pregunta seleccionada (para mostrar preguntas relacionadas)
  // ignore: unused_field
  String? _lastSelectedQuestionId;
  // Idioma actual para detectar cambios
  Locale? _currentLocale;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // No acceder a context.locale aquí, se hará en didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Detectar cambios de idioma y recargar preguntas
    // Solo acceder a context.locale después de que didChangeDependencies se complete
    try {
      final newLocale = context.locale;

      // Primera inicialización o cambio de idioma
      if (!_hasInitialized || _currentLocale != newLocale) {
        _currentLocale = newLocale;
        _hasInitialized = true;
        // Recargar preguntas con el nuevo idioma
        _loadInitialQuestions();
      }
    } catch (e) {
      // Si hay error, simplemente cargar las preguntas sin verificar el idioma
      if (!_hasInitialized) {
        _hasInitialized = true;
        _loadInitialQuestions();
      }
    }
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
      _lastSelectedQuestionId =
          null; // Resetear para mostrar preguntas generales
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
    bloc.add(
      SendMessage(
        question: question.question,
        userId: widget.userId ?? 'default_user',
        messages: messages,
        predefinedAnswer: question.answer, // Pasar la respuesta predefinida
      ),
    );

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
    final padding = ResponsiveHelper.getResponsivePadding(context);
    final iconContainerSize = ResponsiveHelper.isExtraSmall(context)
        ? 40.0
        : 50.0;
    final iconSize = ResponsiveHelper.getResponsiveIconSize(context, 28);
    final titleFontSize = ResponsiveHelper.getResponsiveFontSize(context, 20);
    final subtitleFontSize = ResponsiveHelper.getResponsiveFontSize(
      context,
      14,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: padding * 0.8,
      ),
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
              tooltip: 'chatbot.back'.tr(),
            ),
          ),
          SizedBox(width: padding * 0.8),
          Container(
            width: iconContainerSize,
            height: iconContainerSize,
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
            child: Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: iconSize,
            ),
          ),
          SizedBox(width: padding * 0.8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'chatbot.title'.tr(),
                  style: GoogleFonts.quicksand(
                    color: Colors.white,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'chatbot.subtitle'.tr(),
                  style: GoogleFonts.quicksand(
                    color: Colors.white70,
                    fontSize: subtitleFontSize,
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
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'chatbot.relatedQuestions'.tr(),
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
                          const Icon(
                            Icons.refresh_rounded,
                            size: 16,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'chatbot.otherQuestions'.tr(),
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
    final padding = ResponsiveHelper.getResponsivePadding(context);
    final avatarSize = ResponsiveHelper.isExtraSmall(context) ? 32.0 : 40.0;
    final fontSize = ResponsiveHelper.getResponsiveFontSize(context, 15);
    final iconSize = ResponsiveHelper.getResponsiveIconSize(context, 22);

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: padding * 0.6),
        child: Row(
          mainAxisAlignment: message.isUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!message.isUser) ...[
              Container(
                width: avatarSize,
                height: avatarSize,
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
                child: Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: iconSize,
                ),
              ),
              SizedBox(width: padding * 0.5),
            ],
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: padding * 0.9,
                  vertical: padding * 0.7,
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
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            if (message.isUser) ...[
              SizedBox(width: padding * 0.5),
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: iconSize,
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
    final padding = ResponsiveHelper.getResponsivePadding(context);
    final fontSize = ResponsiveHelper.getResponsiveFontSize(context, 14);

    return InkWell(
      onTap: () => onTap(question),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: padding,
          vertical: padding * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
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
                  fontSize: fontSize,
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
    final padding = ResponsiveHelper.getResponsivePadding(context);
    final iconContainerSize = ResponsiveHelper.isSmall(context) ? 100.0 : 120.0;
    final mainIconSize = ResponsiveHelper.getResponsiveIconSize(context, 60);
    final titleFontSize = ResponsiveHelper.getResponsiveFontSize(context, 32);
    final subtitleFontSize = ResponsiveHelper.getResponsiveFontSize(
      context,
      18,
    );
    final textFontSize = ResponsiveHelper.getResponsiveFontSize(context, 15);
    final smallFontSize = ResponsiveHelper.getResponsiveFontSize(context, 12);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(padding * 1.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconContainerSize,
              height: iconContainerSize,
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
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: mainIconSize,
                color: Colors.white,
              ),
            ),
            SizedBox(height: padding),
            Text(
              'chatbot.greeting'.tr(),
              style: GoogleFonts.quicksand(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'chatbot.assistantDescription'.tr(),
              style: GoogleFonts.quicksand(
                fontSize: subtitleFontSize,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'chatbot.askPrompt'.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: textFontSize,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: padding * 1.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'chatbot.frequentQuestions'.tr(),
                  style: GoogleFonts.quicksand(
                    fontSize: smallFontSize,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.refresh_rounded,
                  size: 16,
                  color: Colors.white70,
                ),
                GestureDetector(
                  onTap: onRefresh,
                  child: Text(
                    ' ${'chatbot.refresh'.tr()}',
                    style: GoogleFonts.quicksand(
                      fontSize: smallFontSize,
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
    final padding = ResponsiveHelper.getResponsivePadding(context);
    final fontSize = ResponsiveHelper.getResponsiveFontSize(context, 14);

    return InkWell(
      onTap: () => onQuestionSelected(question),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: padding,
          vertical: padding * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
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
                  fontSize: fontSize,
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

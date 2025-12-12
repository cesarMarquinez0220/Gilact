import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chatbot_knowledge.dart';

abstract class ChatbotRemoteDataSource {
  Future<List<ChatMessage>> getChatHistory(String userId);
  Future<void> saveMessage(String userId, ChatMessage message);
  Future<List<ChatbotKnowledge>> getKnowledgeBase();
  Future<List<ChatbotKnowledge>> searchKnowledge(String query);
  Future<String> getAnswer(String question);
}

class ChatbotRemoteDataSourceImpl implements ChatbotRemoteDataSource {
  final FirebaseFirestore _firestore;

  ChatbotRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<ChatMessage>> getChatHistory(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('Users')
          .doc(userId)
          .collection('chat_history')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => ChatMessage.fromMap(doc.data()))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    } catch (e) {
      throw ServerException(
        message: 'Error obteniendo historial: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> saveMessage(String userId, ChatMessage message) async {
    try {
      await _firestore
          .collection('Users')
          .doc(userId)
          .collection('chat_history')
          .add(message.toMap());
    } catch (e) {
      throw ServerException(
        message: 'Error guardando mensaje: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<ChatbotKnowledge>> getKnowledgeBase() async {
    try {
      final querySnapshot = await _firestore
          .collection('chatbot_knowledge')
          .doc('questions')
          .collection('faqs')
          .get();

      return querySnapshot.docs
          .map((doc) => ChatbotKnowledge.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException(
        message: 'Error obteniendo base de conocimiento: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<ChatbotKnowledge>> searchKnowledge(String query) async {
    try {
      // Obtener todas las preguntas
      final allKnowledge = await getKnowledgeBase();

      if (allKnowledge.isEmpty) {
        return [];
      }

      final lowerQuery = query.toLowerCase();

      // Buscar por keywords
      final keywordMatches = allKnowledge.where((knowledge) {
        return knowledge.keywords.any(
          (keyword) =>
              keyword.toLowerCase().contains(lowerQuery) ||
              lowerQuery.contains(keyword.toLowerCase()),
        );
      }).toList();

      if (keywordMatches.isNotEmpty) {
        return keywordMatches;
      }

      // Buscar en pregunta y respuesta
      return allKnowledge.where((knowledge) {
        return knowledge.question.toLowerCase().contains(lowerQuery) ||
            knowledge.answer.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      throw ServerException(
        message: 'Error buscando conocimiento: ${e.toString()}',
      );
    }
  }

  @override
  Future<String> getAnswer(String question) async {
    try {
      final knowledge = await searchKnowledge(question);

      if (knowledge.isNotEmpty) {
        return knowledge.first.answer;
      }

      // Respuestas por defecto si no encuentra coincidencia
      return _getDefaultAnswer(question);
    } catch (e) {
      // Mensaje de error traducido según el idioma actual
      try {
        return 'chatbot.errorProcessing'.tr();
      } catch (_) {
        // Fallback si no hay traducción
        return 'Ocurrió un error al procesar tu pregunta. Por favor, intenta de nuevo.';
      }
    }
  }

  String _getDefaultAnswer(String question) {
    final lowerQuestion = question.toLowerCase();

    // Detectar idioma basado en palabras clave
    final isEnglish =
        lowerQuestion.contains('hi') ||
        lowerQuestion.contains('hello') ||
        lowerQuestion.contains('thank') ||
        lowerQuestion.contains('thanks');

    if (lowerQuestion.contains('hola') ||
        lowerQuestion.contains('hi') ||
        lowerQuestion.contains('hello')) {
      return isEnglish
          ? 'Hello! 👋 I\'m here to help you with questions about breastfeeding. How can I assist you?'
          : '¡Hola! 👋 Estoy aquí para ayudarte con preguntas sobre lactancia materna. ¿En qué puedo asistirte?';
    }

    if (lowerQuestion.contains('gracias') ||
        lowerQuestion.contains('thank') ||
        lowerQuestion.contains('thanks')) {
      return isEnglish
          ? 'You\'re welcome. I\'m here whenever you need me! 😊'
          : 'De nada. ¡Estoy aquí cuando me necesites! 😊';
    }

    // Respuesta genérica traducida
    return isEnglish
        ? 'I don\'t have specific information about that at the moment, but I can help you with topics related to:\n\n✅ Breastfeeding\n✅ Correct positions\n✅ Complementary feeding\n✅ Baby\'s health\n\nDo you have any questions about these topics?'
        : 'No tengo información específica sobre eso en este momento, pero puedo ayudarte con temas relacionados a:\n\n✅ Lactancia materna\n✅ Posturas correctas\n✅ Alimentación complementaria\n✅ Salud del bebé\n\n¿Tienes alguna pregunta sobre estos temas?';
  }
}

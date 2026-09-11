import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_message.dart';
import '../entities/chatbot_knowledge.dart';

abstract class ChatbotRepository {
  Future<Either<Failure, List<ChatMessage>>> getChatHistory(String userId);
  Future<Either<Failure, void>> saveMessage(String userId, ChatMessage message);
  Future<Either<Failure, List<ChatbotKnowledge>>> getKnowledgeBase();
  Future<Either<Failure, List<ChatbotKnowledge>>> searchKnowledge(String query);
  Future<Either<Failure, String>> getAnswer(String question);
}

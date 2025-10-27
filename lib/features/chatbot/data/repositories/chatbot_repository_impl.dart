import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chatbot_knowledge.dart';
import '../../domain/repositories/chatbot_repository.dart';
import '../datasources/chatbot_remote_data_source.dart';

class ChatbotRepositoryImpl implements ChatbotRepository {
  final ChatbotRemoteDataSource _remoteDataSource;

  ChatbotRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<ChatMessage>>> getChatHistory(
    String userId,
  ) async {
    try {
      final messages = await _remoteDataSource.getChatHistory(userId);
      return Right(messages);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveMessage(
    String userId,
    ChatMessage message,
  ) async {
    try {
      await _remoteDataSource.saveMessage(userId, message);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ChatbotKnowledge>>> getKnowledgeBase() async {
    try {
      final knowledge = await _remoteDataSource.getKnowledgeBase();
      return Right(knowledge);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ChatbotKnowledge>>> searchKnowledge(
    String query,
  ) async {
    try {
      final knowledge = await _remoteDataSource.searchKnowledge(query);
      return Right(knowledge);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> getAnswer(String question) async {
    try {
      final answer = await _remoteDataSource.getAnswer(question);
      return Right(answer);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }
}

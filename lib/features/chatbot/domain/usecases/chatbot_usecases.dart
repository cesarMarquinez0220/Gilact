import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/chatbot_repository.dart';

@injectable
class SendMessageUseCase implements UseCase<String, SendMessageParams> {
  final ChatbotRepository repository;

  SendMessageUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(SendMessageParams params) async {
    return await repository.getAnswer(params.question);
  }
}

class SendMessageParams {
  final String question;

  SendMessageParams({required this.question});
}

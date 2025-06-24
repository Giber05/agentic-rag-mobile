import '../models/assistant_models.dart';
import '../repositories/assistant_repository.dart';
import '../../core/usecases/usecase.dart';
import '../../core/utils/resource.dart';

/// Usecase for asking the intelligent assistant a question
class AskQuestionUsecase extends Usecase<AskQuestionParams, AssistantAnswerDomain> {
  final AssistantRepository _repository;

  AskQuestionUsecase(this._repository);

  @override
  Future<Resource<AssistantAnswerDomain>> execute(AskQuestionParams params) async {
    return await _repository.askQuestion(
      question: params.question,
      options: params.options,
      conversationHistory: params.conversationHistory,
    ).asResource;
  }
}

/// Parameters for asking a question
class AskQuestionParams {
  final String question;
  final RAGOptionsDomain? options;
  final List<Map<String, String>>? conversationHistory;

  const AskQuestionParams({required this.question, this.options, this.conversationHistory});
}

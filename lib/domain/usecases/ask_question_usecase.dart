import 'package:injectable/injectable.dart';

import '../models/assistant_models.dart';
import '../repositories/assistant_repository.dart';
import '../../core/usecases/usecase.dart';
import '../../core/utils/resource.dart';

/// Usecase for asking the intelligent assistant a question
@injectable
class AskQuestionUsecase extends Usecase<AskQuestionParams, AssistantAnswerDomain> {
  final AssistantRepository _repository;

  AskQuestionUsecase(this._repository);

  @override
  Future<Resource<AssistantAnswerDomain>> execute(AskQuestionParams params) async {
    return await _repository.askQuestion(
      question: params.question,
      options: params.options,
      conversationHistory: params.conversationHistory,
      mode: params.mode,
    ).asResource;
  }
}

/// Parameters for asking a question
class AskQuestionParams {
  final String question;
  final RAGOptionsDomain? options;
  final List<Map<String, String>>? conversationHistory;
  final String? mode; // Tool mode (e.g., "jira" for Search by Jira)

  const AskQuestionParams({
    required this.question, 
    this.options, 
    this.conversationHistory,
    this.mode,
  });
}

import 'package:injectable/injectable.dart';

import '../../core/usecases/usecase.dart';
import '../../core/utils/resource.dart';
import '../models/assistant_models.dart';

/// Use case for getting conversation history
@injectable
class GetConversationsUsecase extends UsecaseNoParams<List<AssistantQueryDomain>> {
  GetConversationsUsecase();

  @override
  Future<Resource<List<AssistantQueryDomain>>> execute() async {
    // TODO: Implement conversation retrieval when needed
    return Resource.success([]);
  }
}

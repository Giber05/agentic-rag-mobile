import 'resource.dart';
import '../error/exceptions.dart';

class APIResult<T> {
  final String status;
  final T data;
  final String message;

  const APIResult({required this.data, required this.message, required this.status});

  bool get isSuccess => status == 'success' || status == 'completed';
  bool get isError => !isSuccess;
}

extension APIResultExt<T> on Future<APIResult<T>> {
  Future<T> get futureData async => (await this).data;
}

extension APIResultResourceExt<T> on APIResult<T> {
  Resource<T> get asResource {
    if (isSuccess) {
      return Resource.success(data, message: message);
    } else {
      return Resource.error(BaseException(message: message));
    }
  }
}

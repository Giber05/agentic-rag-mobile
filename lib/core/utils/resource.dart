import '../error/exceptions.dart';

sealed class Resource<T> {
  static Resource<T> success<T>(T data, {String message = ''}) => Success<T>(data: data, message: message);

  static Resource<T> error<T>(BaseException exception) => Error<T>(exception);
}

class Success<T> extends Resource<T> {
  final T data;
  final String message;

  Success({required this.data, required this.message});
}

class Error<T> extends Resource<T> {
  final BaseException exception;

  Error(this.exception);
}

extension ResourceExt<T> on Future<Resource<T>> {
  Future<Resource<Y>> mapWhenSuccess<Y>(Y Function(T) transform) async {
    final result = await this;
    switch (result) {
      case Success<T> success:
        return Success<Y>(data: transform(success.data), message: success.message);
      case Error<T> error:
        return Error<Y>(error.exception);
    }
  }
}

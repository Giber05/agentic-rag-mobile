import '../errors/failures.dart';

typedef DataMap = Map<String, dynamic>;

// Custom Result type to replace Either from dartz
abstract class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;
}

class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);
  final Failure failure;
}

// Extension methods to access data and failure
extension ResultExtension<T> on Result<T> {
  T get data {
    if (this is Success<T>) {
      return (this as Success<T>).data;
    }
    throw StateError('Cannot access data on failure result');
  }

  Failure get failure {
    if (this is FailureResult<T>) {
      return (this as FailureResult<T>).failure;
    }
    throw StateError('Cannot access failure on success result');
  }
}

typedef ResultFuture<T> = Future<Result<T>>;
typedef ResultVoid = Future<Result<void>>;

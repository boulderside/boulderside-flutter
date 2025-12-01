import 'package:boulderside_flutter/src/core/error/app_failure.dart';

class Result<T> {
  const Result._({this.data, this.error});

  final T? data;
  final AppFailure? error;

  bool get isSuccess => data != null;

  factory Result.success(T data) => Result._(data: data);

  factory Result.failure(AppFailure failure) => Result._(error: failure);

  R when<R>({
    required R Function(T data) success,
    required R Function(AppFailure failure) failure,
  }) {
    if (data != null) {
      return success(data as T);
    }
    return failure(error!);
  }
}

import 'package:flutter/material.dart';

@immutable
abstract class IErrorHandler {
  E when<E>({required E Function(Object error) unknown});

  bool get isApiError;
}

@immutable
class _UnknownError extends ErrorHandler {
  final Object error;
  const _UnknownError(this.error);

  @override
  E when<E>({required E Function(Object error) unknown}) => unknown(error);

  @override
  bool get isApiError => false;
}

@immutable
abstract class ErrorHandler implements IErrorHandler {
  const ErrorHandler();

  factory ErrorHandler.fromError(Object object) {
    return _UnknownError(object);
  }
}

extension ObjectExtension on Object {
  IErrorHandler toHandler() => ErrorHandler.fromError(this);
}

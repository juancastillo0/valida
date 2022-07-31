import 'package:valida/src/validate.dart';

void Function({
  required String errorCode,
  required String message,
  required Object? validationParam,
}) addErrorFunc(
  String property,
  Object value,
  List<ValidaError> errors,
) {
  void _addError({
    required String errorCode,
    required String message,
    required Object? validationParam,
  }) {
    errors.add(
      ValidaError(
        property: property,
        value: value,
        errorCode: errorCode,
        message: message,
        validationParam: validationParam,
      ),
    );
  }

  return _addError;
}

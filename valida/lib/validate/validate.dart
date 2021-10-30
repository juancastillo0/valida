export 'validate_annotations.dart';

/// Error generated in the process of
/// validating a class or field
class ValidaError {
  // TODO: final F fieldId;

  final String property;
  final Object? value;
  final String errorCode;
  final Object? validationParam;
  final String message;
  final Validation? nestedValidation;

  const ValidaError({
    required this.property,
    required this.value,
    required this.errorCode,
    required this.message,
    this.validationParam,
    this.nestedValidation,
  });

  @override
  String toString() {
    return '$errorCode${validationParam == null ? '' : '(${validationParam})'}:'
        ' $message. $property${value == null ? '' : ' = $value'}';
  }

  static ValidaError? fromNested(String property, Validation validation) {
    return validation.hasErrors
        ? ValidaError(
            errorCode: 'Valida.nested',
            // ignore: missing_whitespace_between_adjacent_strings
            message: 'Found ${validation.numErrors} error'
                '{${validation.numErrors > 1 ? 's' : ''} in $property',
            property: property,
            value: validation.value,
            nestedValidation: validation,
          )
        : null;
  }
}

/// A value of type [T] which was successfully validated
class Validated<T> {
  const Validated._(this.value);
  final T value;
}

/// The result of a validation for [T] with fields of type [F]
abstract class Validation<T, F> {
  Validation(Map<F, List<ValidaError>> errorsMap)
      : errorsMap = Map.unmodifiable(errorsMap),
        numErrors = computeNumErrors(errorsMap.values.expand((e) => e));

  static int computeNumErrors(Iterable<ValidaError> errors) {
    return errors.fold(
      0,
      (_num, error) => _num + (error.nestedValidation?.numErrors ?? 1),
    );
  }

  final Map<F, List<ValidaError>> errorsMap;
  final int numErrors;

  T get value;
  Object get fields;

  Iterable<ValidaError> get allErrors => errorsMap.values.expand((e) => e);
  bool get hasErrors => numErrors > 0;
  bool get isValid => !hasErrors;

  Validated<T>? get validated => isValid ? Validated._(value) : null;

  ValidaError? toError({required String property}) {
    return ValidaError.fromNested(property, this);
  }
}

/// An object that can validate a value of type [T]
class Validator<T, V extends Validation<T, Object>> {
  final V Function(T) validate;

  const Validator(this.validate);
}

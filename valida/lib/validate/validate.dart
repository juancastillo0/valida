import 'package:valida/validate/validate_annotations.dart';

export 'models/to_json_mixin.dart';
export 'validate_annotations.dart';

/// Error generated in the process of
/// validating a class or field
class ValidaError {
  // TODO: final F fieldId;

  /// The name of the field that caused this error
  final String property;

  /// The value that caused this error
  final Object? value;

  /// An identifier for the type this error
  final String errorCode;

  /// The argument passed as configuration to the validation condition
  final Object? validationParam;

  /// An human readable explanation of this error
  final String message;

  /// The result of validating nested fields if the [value] is a class
  final Validation? nestedValidation;

  /// Error generated in the process of
  /// validating a class or field
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

  /// Converts a [validation] into a [ValidaError] if there are errors
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

  /// The successfully validated value
  final T value;
}

/// The result of a validation for [T] with fields of type [F]
abstract class Validation<T, F> {
  /// The result of a validation for [T] with fields of type [F]
  Validation(Map<F, List<ValidaError>> errorsMap)
      : errorsMap = Map.unmodifiable(errorsMap),
        numErrors = computeNumErrors(errorsMap.values.expand((e) => e));

  /// Computes the number of errors in a collection of errors.
  /// Also counts nested errors.
  static int computeNumErrors(Iterable<ValidaError> errors) {
    return errors.fold(
      0,
      (_num, error) => _num + (error.nestedValidation?.numErrors ?? 1),
    );
  }

  /// The list of errors for each field
  final Map<F, List<ValidaError>> errorsMap;

  /// The number of errors encountered in validation
  final int numErrors;

  /// The validated value
  T get value;

  /// The fields error information in an improved API over [errorsMap]
  Object get fields;

  /// All encountered errors
  Iterable<ValidaError> get allErrors => errorsMap.values.expand((e) => e);

  /// Whether there were errors in validation
  bool get hasErrors => numErrors > 0;

  /// Whether the validation was successful
  bool get isValid => !hasErrors;

  /// The validated value. Null if there were errors
  Validated<T>? get validated => isValid ? Validated._(value) : null;

  ValidaError? toError({required String property}) {
    return ValidaError.fromNested(property, this);
  }
}

/// An object that can validate a value of type [T]
class Validator<T, V extends Validation<T, Object>> {
  final V Function(T) validate;

  /// An object that can validate a value of type [T]
  const Validator(this.validate);
}

/// The specification of the validation for a given type [T] with field [F]
class ValidaSpec<T, F> {
  /// A Map with specification of the validation for each field
  final Map<F, ValidaField> fieldsMap;

  /// Returns the [field] in [value]
  final Object? Function(T value, String field) getField;

  /// Validates [value] globally. It is not specific to only one field.
  final List<ValidaError> Function(T value)? globalValidate;

  /// The specification of the validation for a given type [T] with field [F]
  const ValidaSpec({
    required this.fieldsMap,
    required this.getField,
    this.globalValidate,
  });
}

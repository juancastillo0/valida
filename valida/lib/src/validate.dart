import 'package:valida/src/models/to_json_mixin.dart';
import 'package:valida/src/validate_annotations.dart';

export 'models/to_json_mixin.dart';
export 'validate_annotations.dart';

/// Error generated in the process of
/// validating a class or field
class ValidaError with ValidaToJson {
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
  final Validation<Object?, Object?>? nestedValidation;

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
        ' $message. $property${value == null ? '' : ' = $value'}.'
        '${nestedValidation ?? ''}';
  }

  @override
  Map<String, Object?> toJson({bool withValue = false}) {
    return {
      'property': property,
      'errorCode': errorCode,
      'message': message,
      if (validationParam != null) 'validationParam': validationParam,
      if (withValue) 'value': value,
      if (nestedValidation != null)
        'nestedValidation': nestedValidation!.toJson(withValue: withValue),
    };
  }

  /// Converts a [validation] into a [ValidaError] if there are errors
  static ValidaError? fromNested(
    String property,
    Validation<Object?, Object?> validation,
  ) {
    return validation.hasErrors
        ? ValidaError(
            errorCode: 'Valida.nested',
            // ignore: missing_whitespace_between_adjacent_strings
            message: 'Found ${validation.numErrors} error'
                '${validation.numErrors > 1 ? 's' : ''} in $property',
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
abstract class Validation<T, F> with ValidaToJson {
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

  /// Return this validation as a [ValidaError].
  /// Null if there are no errors in the validation.
  ValidaError? toError({required String property}) {
    return ValidaError.fromNested(property, this);
  }

  @override
  Map<String, Object?> toJson({bool withValue = false}) {
    return errorsMap.map(
      (key, value) => MapEntry(
        key is Enum ? key.name : key.toString(),
        value.map((e) => e.toJson(withValue: withValue)).toList(),
      ),
    );
  }

  @override
  String toString() {
    return '$runtimeType<$T, $F>(numErrors: $numErrors, errors: ${toJson()})';
  }
}

/// Returns the type passed as type argument
Type _getType<T>() => T;

/// An object that can validate a value of type [T]
abstract class Validator<T, V extends Validation<T, Object>> {
  /// Executes the validation for [value] and returns the [V] validation.
  V validate(T value);

  /// Returns the generic [T] type
  Type get modelType => _getType<T>();

  /// Returns the generic [T] nullable type
  Type get modelNullType => _getType<T?>();

  /// An object that can validate a value of type [T]
  const Validator();

  /// An object that validates a value of type [T] using the [validate] function
  const factory Validator.fromFunction(V Function(T) validate) =
      _ValidatorValue<T, V>;
}

class _ValidatorValue<T, V extends Validation<T, Object>>
    extends Validator<T, V> {
  final V Function(T) _validate;

  /// An object that can validate a value of type [T]
  const _ValidatorValue(this._validate);

  @override
  V validate(T value) {
    return _validate(value);
  }
}

/// A value that can retrieve validators from a given type
mixin GenericValidator {
  /// Retrieves validators for a given type [T].
  /// Null if no validator was found.
  Validator<T, Validation<T, Object>>? validator<T>();

  /// Validate a generic [value] using the validator from [validator].
  /// Null if no validator was found or if [value] is Null.
  Validation<T, Object>? validate<T>(T value) {
    if (value == null) return null;
    final validator = this.validator<T>();
    return validator?.validate(value);
  }
}

/// The specification of the validation for a given type [T] with field [F]
class ValidaSpec<V extends Validation<T, F>, T, F> {
  /// A Map with specification of the validation for each field
  final Map<F, ValidaField<Object?>> fieldsMap;

  /// Returns the [field] in [value]
  final Object? Function(T value, String field) getField;

  /// Validates [value] globally. It is not specific to only one field.
  final GlobalValidateFunc<T, F>? globalValidate;

  /// A function that creates a validation instance from the errors
  /// and the validated value.
  final V Function(Map<F, List<ValidaError>> errors, T value) validationFactory;

  /// Validates [value] and returns a [V] with the errors found as a result
  V validate(T value) {
    Object? _getProperty(String property) => getField(value, property);

    final errors = <F, List<ValidaError>>{
      if (globalValidate != null)
        globalValidate!.field: globalValidate!.function(value),
      ...fieldsMap.map(
        (key, field) => MapEntry(
          key,
          field.validate(key is Enum ? key.name : key.toString(), _getProperty),
        ),
      )
    };
    errors.removeWhere((key, value) => value.isEmpty);
    return validationFactory(errors, value);
  }

  /// The specification of the validation for a given type [T] with field [F]
  const ValidaSpec({
    required this.fieldsMap,
    required this.getField,
    required this.validationFactory,
    this.globalValidate,
  });
}

/// A wrapper around the global validation [function].
class GlobalValidateFunc<T, F> {
  /// The function that performs the validation
  final List<ValidaError> Function(T value) function;

  /// The global field identifier
  final F field;

  /// A wrapper around the global validation [function].
  const GlobalValidateFunc({
    required this.function,
    required this.field,
  });
}

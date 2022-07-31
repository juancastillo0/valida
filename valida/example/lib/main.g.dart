// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// ValidatorGenerator
// **************************************************************************

enum FormTestField {
  longStr,
  shortStr,
  positiveInt,
  optionalDecimal,
  nonEmptyList,
  identifier,
  nested,
  $global
}

class FormTestValidationFields {
  const FormTestValidationFields(this.errorsMap);
  final Map<FormTestField, List<ValidaError>> errorsMap;

  NestedFieldValidation? get nested {
    final l = errorsMap[FormTestField.nested];
    return (l != null && l.isNotEmpty)
        ? l.first.nestedValidation as NestedFieldValidation?
        : null;
  }

  List<ValidaError>? get longStr => errorsMap[FormTestField.longStr];
  List<ValidaError>? get shortStr => errorsMap[FormTestField.shortStr];
  List<ValidaError>? get positiveInt => errorsMap[FormTestField.positiveInt];
  List<ValidaError>? get optionalDecimal =>
      errorsMap[FormTestField.optionalDecimal];
  List<ValidaError>? get nonEmptyList => errorsMap[FormTestField.nonEmptyList];
  List<ValidaError>? get identifier => errorsMap[FormTestField.identifier];
  List<ValidaError>? get $global => errorsMap[FormTestField.$global];
}

class FormTestValidation extends Validation<FormTest, FormTestField> {
  FormTestValidation(this.errorsMap, this.value, this.fields)
      : super(errorsMap);
  @override
  final Map<FormTestField, List<ValidaError>> errorsMap;
  @override
  final FormTest value;
  @override
  final FormTestValidationFields fields;

  /// Validates [value] and returns a [FormTestValidation] with the errors found as a result
  static FormTestValidation fromValue(FormTest value) {
    Object? _getProperty(String property) => spec.getField(value, property);

    final errors = <FormTestField, List<ValidaError>>{
      if (spec.globalValidate != null)
        FormTestField.$global: spec.globalValidate!(value),
      ...spec.fieldsMap.map(
        (key, field) => MapEntry(
          key,
          field.validate(key.name, _getProperty),
        ),
      )
    };
    errors.removeWhere((key, value) => value.isEmpty);
    return FormTestValidation(errors, value, FormTestValidationFields(errors));
  }

  static const spec = ValidaSpec(
    fieldsMap: {
      FormTestField.nested: ValidaNested<NestedField>(
        omit: null,
        customValidate: null,
        overrideValidation: NestedFieldValidation.fromValue,
      ),
      FormTestField.longStr: ValidaString(
          minLength: 15,
          maxLength: 50,
          matches: r'^[a-zA-Z]+$',
          customValidate: _customValidateStr,
          description: 'should have between 15 and 50 bytes, only letters'
              " and cannot be 'WrongValue'"),
      FormTestField.shortStr: ValidaString(maxLength: 20, contains: '@'),
      FormTestField.positiveInt: ValidaNum(
          isInt: true, min: 0, customValidate: FormTest._customValidateNum),
      FormTestField.optionalDecimal: ValidaNum(
          min: 0,
          max: 1,
          comp: ValidaComparison<num>(
              less: CompVal(0),
              moreEq: CompVal.list([CompVal.ref('positiveInt')]))),
      FormTestField.nonEmptyList: ValidaList(
          minLength: 1, each: ValidaString(isDate: true, maxLength: 3)),
      FormTestField.identifier: ValidaString(isUUID: UUIDVersion.v4),
    },
    getField: _getField,
    globalValidate: _globalValidate,
  );

  static List<ValidaError> _globalValidate(FormTest value) => [
        ...FormTest._customValidate2(value),
        ...value._customValidate3(),
        ...FormTest._customValidate(value),
      ];

  static Object? _getField(FormTest value, String field) {
    switch (field) {
      case 'longStr':
        return value.longStr;
      case 'shortStr':
        return value.shortStr;
      case 'positiveInt':
        return value.positiveInt;
      case 'optionalDecimal':
        return value.optionalDecimal;
      case 'nonEmptyList':
        return value.nonEmptyList;
      case 'identifier':
        return value.identifier;
      case 'nested':
        return value.nested;
      case 'hashCode':
        return value.hashCode;
      case 'runtimeType':
        return value.runtimeType;
      default:
        throw Exception('Could not find field "$field" for value $value.');
    }
  }
}

class NestedFieldValidationFields {
  const NestedFieldValidationFields(this.errorsMap);
  final Map<String, List<ValidaError>> errorsMap;

  List<ValidaError> get timeStr => errorsMap['timeStr'] ?? const [];
  List<ValidaError> get dateWith2021Min =>
      errorsMap['dateWith2021Min'] ?? const [];
  List<ValidaError> get optionalDateWithNowMax =>
      errorsMap['optionalDateWithNowMax'] ?? const [];
}

class NestedFieldValidation extends Validation<NestedField, String> {
  NestedFieldValidation(this.errorsMap, this.value, this.fields)
      : super(errorsMap);
  @override
  final Map<String, List<ValidaError>> errorsMap;
  @override
  final NestedField value;
  @override
  final NestedFieldValidationFields fields;

  /// Validates [value] and returns a [NestedFieldValidation] with the errors found as a result
  static NestedFieldValidation fromValue(NestedField value) {
    Object? _getProperty(String property) => spec.getField(value, property);

    final errors = <String, List<ValidaError>>{
      ...spec.fieldsMap.map(
        (key, field) => MapEntry(
          key,
          field.validate(key, _getProperty),
        ),
      )
    };
    errors.removeWhere((key, value) => value.isEmpty);
    return NestedFieldValidation(
        errors, value, NestedFieldValidationFields(errors));
  }

  static const spec = ValidaSpec(
    fieldsMap: {
      'timeStr': ValidaString(isTime: true),
      'dateWith2021Min': ValidaDate(min: '2021-01-01'),
      'optionalDateWithNowMax': ValidaDate(max: 'now'),
    },
    getField: _getField,
  );

  static List<ValidaError> _globalValidate(NestedField value) => [];

  static Object? _getField(NestedField value, String field) {
    switch (field) {
      case 'timeStr':
        return value.timeStr;
      case 'dateWith2021Min':
        return value.dateWith2021Min;
      case 'optionalDateWithNowMax':
        return value.optionalDateWithNowMax;
      case 'hashCode':
        return value.hashCode;
      case 'runtimeType':
        return value.runtimeType;
      default:
        throw Exception('Could not find field "$field" for value $value.');
    }
  }
}

/// The arguments for [singleFunction].
class SingleFunctionArgs with ToJson {
  final String name;
  final String lastName;

  /// The arguments for [singleFunction].
  const SingleFunctionArgs(
    this.name, [
    this.lastName = 'NONE',
  ]);

  /// Validates this arguments for [singleFunction].
  SingleFunctionArgsValidation validate() =>
      SingleFunctionArgsValidation.fromValue(this);

  /// Validates this arguments for [singleFunction] and
  /// returns the successfully [Validated] value or
  /// throws a [SingleFunctionArgsValidation] when there is an error.
  Validated<SingleFunctionArgs> validatedOrThrow() {
    final validation = validate();
    final validated = validation.validated;
    if (validated == null) {
      throw validation;
    }
    return validated;
  }

  @override
  Map<String, Object?> toJson() => {
        'name': name,
        'lastName': lastName,
      };

  @override
  String toString() => 'SingleFunctionArgs${toJson()}';

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SingleFunctionArgs &&
            name == other.name &&
            lastName == other.lastName);
  }

  @override
  int get hashCode => Object.hash(
        runtimeType,
        name,
        lastName,
      );
}

enum SingleFunctionArgsField {
  name,
  lastName,

  $global
}

class SingleFunctionArgsValidationFields {
  const SingleFunctionArgsValidationFields(this.errorsMap);
  final Map<SingleFunctionArgsField, List<ValidaError>> errorsMap;

  List<ValidaError> get name =>
      errorsMap[SingleFunctionArgsField.name] ?? const [];
  List<ValidaError> get lastName =>
      errorsMap[SingleFunctionArgsField.lastName] ?? const [];
  List<ValidaError> get $global =>
      errorsMap[SingleFunctionArgsField.$global] ?? const [];
}

class SingleFunctionArgsValidation
    extends Validation<SingleFunctionArgs, SingleFunctionArgsField> {
  SingleFunctionArgsValidation(this.errorsMap, this.value, this.fields)
      : super(errorsMap);
  @override
  final Map<SingleFunctionArgsField, List<ValidaError>> errorsMap;
  @override
  final SingleFunctionArgs value;
  @override
  final SingleFunctionArgsValidationFields fields;

  /// Validates [value] and returns a [SingleFunctionArgsValidation] with the errors found as a result
  static SingleFunctionArgsValidation fromValue(SingleFunctionArgs value) {
    Object? _getProperty(String property) => spec.getField(value, property);

    final errors = <SingleFunctionArgsField, List<ValidaError>>{
      if (spec.globalValidate != null)
        SingleFunctionArgsField.$global: spec.globalValidate!(value),
      ...spec.fieldsMap.map(
        (key, field) => MapEntry(
          key,
          field.validate(key.name, _getProperty),
        ),
      )
    };
    errors.removeWhere((key, value) => value.isEmpty);
    return SingleFunctionArgsValidation(
        errors, value, SingleFunctionArgsValidationFields(errors));
  }

  static const spec = ValidaSpec(
    fieldsMap: {
      SingleFunctionArgsField.name:
          ValidaString(isLowercase: true, isAlpha: true),
      SingleFunctionArgsField.lastName:
          ValidaString(isUppercase: true, isAlpha: true),
    },
    getField: _getField,
    globalValidate: _globalValidate,
  );

  static List<ValidaError> _globalValidate(SingleFunctionArgs value) => [
        ..._customValidateSingleFunction(value),
      ];

  static Object? _getField(SingleFunctionArgs value, String field) {
    switch (field) {
      case 'name':
        return value.name;
      case 'lastName':
        return value.lastName;
      default:
        throw Exception('Could not find field "$field" for value $value.');
    }
  }
}

/// The arguments for [_singleFunction2].
class _SingleFunction2Args with ToJson {
  final String name;
  final List<Object> nonEmptyList;
  final String lastName;

  /// The arguments for [_singleFunction2].
  const _SingleFunction2Args(
    this.name, {
    required this.nonEmptyList,
    this.lastName = 'NONE',
  });

  /// Validates this arguments for [_singleFunction2].
  _SingleFunction2ArgsValidation validate() =>
      _SingleFunction2ArgsValidation.fromValue(this);

  /// Validates this arguments for [_singleFunction2] and
  /// returns the successfully [Validated] value or
  /// throws a [_SingleFunction2ArgsValidation] when there is an error.
  Validated<_SingleFunction2Args> validatedOrThrow() {
    final validation = validate();
    final validated = validation.validated;
    if (validated == null) {
      throw validation;
    }
    return validated;
  }

  @override
  Map<String, Object?> toJson() => {
        'name': name,
        'nonEmptyList': nonEmptyList,
        'lastName': lastName,
      };

  @override
  String toString() => '_SingleFunction2Args${toJson()}';

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SingleFunction2Args &&
            name == other.name &&
            nonEmptyList == other.nonEmptyList &&
            lastName == other.lastName);
  }

  @override
  int get hashCode => Object.hash(
        runtimeType,
        name,
        nonEmptyList,
        lastName,
      );
}

enum _SingleFunction2ArgsField {
  name,
  lastName,
  nonEmptyList,
}

class _SingleFunction2ArgsValidationFields {
  const _SingleFunction2ArgsValidationFields(this.errorsMap);
  final Map<_SingleFunction2ArgsField, List<ValidaError>> errorsMap;

  List<ValidaError> get name =>
      errorsMap[_SingleFunction2ArgsField.name] ?? const [];
  List<ValidaError> get lastName =>
      errorsMap[_SingleFunction2ArgsField.lastName] ?? const [];
  List<ValidaError> get nonEmptyList =>
      errorsMap[_SingleFunction2ArgsField.nonEmptyList] ?? const [];
}

class _SingleFunction2ArgsValidation
    extends Validation<_SingleFunction2Args, _SingleFunction2ArgsField> {
  _SingleFunction2ArgsValidation(this.errorsMap, this.value, this.fields)
      : super(errorsMap);
  @override
  final Map<_SingleFunction2ArgsField, List<ValidaError>> errorsMap;
  @override
  final _SingleFunction2Args value;
  @override
  final _SingleFunction2ArgsValidationFields fields;

  /// Validates [value] and returns a [_SingleFunction2ArgsValidation] with the errors found as a result
  static _SingleFunction2ArgsValidation fromValue(_SingleFunction2Args value) {
    Object? _getProperty(String property) => spec.getField(value, property);

    final errors = <_SingleFunction2ArgsField, List<ValidaError>>{
      ...spec.fieldsMap.map(
        (key, field) => MapEntry(
          key,
          field.validate(key.name, _getProperty),
        ),
      )
    };
    errors.removeWhere((key, value) => value.isEmpty);
    return _SingleFunction2ArgsValidation(
        errors, value, _SingleFunction2ArgsValidationFields(errors));
  }

  static const spec = ValidaSpec(
    fieldsMap: {
      _SingleFunction2ArgsField.name:
          ValidaString(isLowercase: true, isAlpha: true),
      _SingleFunction2ArgsField.lastName:
          ValidaString(isUppercase: true, isAlpha: true),
      _SingleFunction2ArgsField.nonEmptyList: ValidaList<Object>(minLength: 1),
    },
    getField: _getField,
  );

  static List<ValidaError> _globalValidate(_SingleFunction2Args value) => [];

  static Object? _getField(_SingleFunction2Args value, String field) {
    switch (field) {
      case 'name':
        return value.name;
      case 'lastName':
        return value.lastName;
      case 'nonEmptyList':
        return value.nonEmptyList;
      default:
        throw Exception('Could not find field "$field" for value $value.');
    }
  }
}

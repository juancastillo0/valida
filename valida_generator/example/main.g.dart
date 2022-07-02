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
  global,
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
}

class FormTestValidation extends Validation<FormTest, FormTestField> {
  FormTestValidation(this.errorsMap, this.value, this.fields)
      : super(errorsMap);

  final Map<FormTestField, List<ValidaError>> errorsMap;

  final FormTest value;

  final FormTestValidationFields fields;

  static const validationSpec = {
    'longStr': ValidaString(
        minLength: 15,
        maxLength: 50,
        matches: r'^[a-zA-Z]+$',
        customValidate: _customValidateStr),
    'shortStr': ValidaString(maxLength: 20, contains: '@'),
    'positiveInt': ValidaNum(
        isInt: true, min: 0, customValidate: FormTest._customValidateNum),
    'optionalDecimal': ValidaNum(
        min: 0,
        max: 1,
        comp: ValidaComparison<num>(
            less: CompVal(0),
            moreEq: CompVal.list([CompVal.ref('positiveInt')]))),
    'nonEmptyList': ValidaList(
        minLength: 1, each: ValidaString(isDate: true, maxLength: 3)),
    'identifier': ValidaString(isUUID: UUIDVersion.v4),
  };

  static List<ValidaError> globalValidate(FormTest value) => [
        ...FormTest._customValidate2(value),
        ...value._customValidate3(),
      ];

  static Object? getField(FormTest value, String field) {
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
      default:
        throw Exception();
    }
  }
}

FormTestValidation validateFormTest(FormTest value) {
  final errors = <FormTestField, List<ValidaError>>{};

  final _nestedValidation = value.nested == null
      ? null
      : validateNestedField(value.nested!).toError(property: 'nested');
  errors[FormTestField.nested] = [
    if (_nestedValidation != null) _nestedValidation
  ];

  errors[FormTestField.global] = [
    ...FormTest._customValidate2(value),
    ...value._customValidate3(),
  ];
  errors[FormTestField.longStr] = [
    ..._customValidateStr(value.longStr),
    if (value.longStr.length < 15)
      ValidaError(
        message: r'Should be at a minimum 15 in length',
        errorCode: 'ValidaString.minLength',
        property: 'longStr',
        validationParam: 15,
        value: value.longStr,
      ),
    if (value.longStr.length > 50)
      ValidaError(
        message: r'Should be at a maximum 50 in length',
        errorCode: 'ValidaString.maxLength',
        property: 'longStr',
        validationParam: 50,
        value: value.longStr,
      ),
    if (!RegExp(r"^[a-zA-Z]+$").hasMatch(value.longStr))
      ValidaError(
        message: r'Should match ^[a-zA-Z]+$',
        errorCode: 'ValidaString.matches',
        property: 'longStr',
        validationParam: RegExp(r"^[a-zA-Z]+$"),
        value: value.longStr,
      )
  ];
  errors[FormTestField.shortStr] = [
    if (value.shortStr.length > 20)
      ValidaError(
        message: r'Should be at a maximum 20 in length',
        errorCode: 'ValidaString.maxLength',
        property: 'shortStr',
        validationParam: 20,
        value: value.shortStr,
      ),
    if (!value.shortStr.contains(r"@"))
      ValidaError(
        message: r'Should contain @',
        errorCode: 'ValidaString.contains',
        property: 'shortStr',
        validationParam: r'@',
        value: value.shortStr,
      )
  ];
  errors[FormTestField.positiveInt] = [
    ...FormTest._customValidateNum(value.positiveInt),
    if (value.positiveInt.round() != value.positiveInt)
      ValidaError(
        message: r'Should be an integer',
        errorCode: 'ValidaNum.isInt',
        property: 'positiveInt',
        validationParam: null,
        value: value.positiveInt,
      ),
    if (value.positiveInt < 0)
      ValidaError(
        message: r'Should be at a minimum 0',
        errorCode: 'ValidaNum.min',
        property: 'positiveInt',
        validationParam: 0,
        value: value.positiveInt,
      )
  ];
  if (value.optionalDecimal != null)
    errors[FormTestField.optionalDecimal] = [
      if (value.optionalDecimal!.compareTo(0) >= 0)
        ValidaError(
          message: r'Should be at a minimum 0',
          errorCode: 'ValidaComparable.less',
          property: 'optionalDecimal',
          validationParam: "0",
          value: value.optionalDecimal!,
        ),
      if (value.optionalDecimal!.compareTo(value.positiveInt) < 0)
        ValidaError(
          message: r'Should be at a more than or equal to [positiveInt]',
          errorCode: 'ValidaComparable.moreEq',
          property: 'optionalDecimal',
          validationParam: "[positiveInt]",
          value: value.optionalDecimal!,
        ),
      if (value.optionalDecimal! < 0)
        ValidaError(
          message: r'Should be at a minimum 0',
          errorCode: 'ValidaNum.min',
          property: 'optionalDecimal',
          validationParam: 0,
          value: value.optionalDecimal!,
        ),
      if (value.optionalDecimal! > 1)
        ValidaError(
          message: r'Should be at a maximum 1',
          errorCode: 'ValidaNum.max',
          property: 'optionalDecimal',
          validationParam: 1,
          value: value.optionalDecimal!,
        )
    ];
  errors[FormTestField.nonEmptyList] = [
    if (value.nonEmptyList.length < 1)
      ValidaError(
        message: r'Should be at a minimum 1 in length',
        errorCode: 'ValidaList.minLength',
        property: 'nonEmptyList',
        validationParam: 1,
        value: value.nonEmptyList,
      )
  ];
  errors.removeWhere((k, v) => v.isEmpty);

  return FormTestValidation(
    errors,
    value,
    FormTestValidationFields(errors),
  );
}

enum NestedFieldField {
  timeStr,
  dateWith2021Min,
  optionalDateWithNowMax,
}

class NestedFieldValidationFields {
  const NestedFieldValidationFields(this.errorsMap);
  final Map<NestedFieldField, List<ValidaError>> errorsMap;

  List<ValidaError> get timeStr => errorsMap[NestedFieldField.timeStr]!;
  List<ValidaError> get dateWith2021Min =>
      errorsMap[NestedFieldField.dateWith2021Min]!;
  List<ValidaError> get optionalDateWithNowMax =>
      errorsMap[NestedFieldField.optionalDateWithNowMax]!;
}

class NestedFieldValidation extends Validation<NestedField, NestedFieldField> {
  NestedFieldValidation(this.errorsMap, this.value, this.fields)
      : super(errorsMap);

  final Map<NestedFieldField, List<ValidaError>> errorsMap;

  final NestedField value;

  final NestedFieldValidationFields fields;

  static const validationSpec = {
    'timeStr': ValidaString(isTime: true),
    'dateWith2021Min': ValidaDate(min: '2021-01-01'),
    'optionalDateWithNowMax': ValidaDate(max: 'now'),
  };

  static List<ValidaError> globalValidate(NestedField value) => [];

  static Object? getField(NestedField value, String field) {
    switch (field) {
      case 'timeStr':
        return value.timeStr;
      case 'dateWith2021Min':
        return value.dateWith2021Min;
      case 'optionalDateWithNowMax':
        return value.optionalDateWithNowMax;
      default:
        throw Exception();
    }
  }
}

NestedFieldValidation validateNestedField(NestedField value) {
  final errors = <NestedFieldField, List<ValidaError>>{};

  errors[NestedFieldField.dateWith2021Min] = [
    if (DateTime.fromMillisecondsSinceEpoch(1609459200000)
        .isAfter(value.dateWith2021Min))
      ValidaError(
        message: r'Should be at a minimum 2021-01-01',
        errorCode: 'ValidaDate.min',
        property: 'dateWith2021Min',
        validationParam: "2021-01-01",
        value: value.dateWith2021Min,
      )
  ];
  if (value.optionalDateWithNowMax == null)
    errors[NestedFieldField.optionalDateWithNowMax] = [];
  else
    errors[NestedFieldField.optionalDateWithNowMax] = [
      if (DateTime.now().isAfter(value.optionalDateWithNowMax!))
        ValidaError(
          message: r'Should be at a maximum now',
          errorCode: 'ValidaDate.max',
          property: 'optionalDateWithNowMax',
          validationParam: "now",
          value: value.optionalDateWithNowMax!,
        )
    ];

  return NestedFieldValidation(
    errors,
    value,
    NestedFieldValidationFields(errors),
  );
}

/// The arguments for [singleFunction].
class SingleFunctionArgs {
  final String name;
  final String lastName;

  /// The arguments for [singleFunction].
  const SingleFunctionArgs(
    this.name, [
    this.lastName = 'NONE',
  ]);

  /// Validates this arguments for [singleFunction].
  SingleFunctionArgsValidation validate() => validateSingleFunctionArgs(this);

  /// Validates this arguments for [singleFunction] and
  /// returns the successfully [Validated] value or
  /// throws a [SingleFunctionArgsValidation] when there is an error.
  Validated<SingleFunctionArgs> isValidOrThrow() {
    final validation = validate();
    if (validation.hasErrors) {
      throw validation;
    }
    return validation.validated!;
  }

  /// Returns a Map with all fields
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
}

class SingleFunctionArgsValidationFields {
  const SingleFunctionArgsValidationFields(this.errorsMap);
  final Map<SingleFunctionArgsField, List<ValidaError>> errorsMap;

  List<ValidaError> get name => errorsMap[SingleFunctionArgsField.name]!;
  List<ValidaError> get lastName =>
      errorsMap[SingleFunctionArgsField.lastName]!;
}

class SingleFunctionArgsValidation
    extends Validation<SingleFunctionArgs, SingleFunctionArgsField> {
  SingleFunctionArgsValidation(this.errorsMap, this.value, this.fields)
      : super(errorsMap);

  final Map<SingleFunctionArgsField, List<ValidaError>> errorsMap;

  final SingleFunctionArgs value;

  final SingleFunctionArgsValidationFields fields;

  static const validationSpec = {
    'name': ValidaString(isLowercase: true, isAlpha: true),
    'lastName': ValidaString(isUppercase: true, isAlpha: true),
  };

  static List<ValidaError> globalValidate(SingleFunctionArgs value) => [];

  static Object? getField(SingleFunctionArgs value, String field) {
    switch (field) {
      case 'name':
        return value.name;
      case 'lastName':
        return value.lastName;
      default:
        throw Exception();
    }
  }
}

SingleFunctionArgsValidation validateSingleFunctionArgs(
    SingleFunctionArgs value) {
  final errors = <SingleFunctionArgsField, List<ValidaError>>{};

  errors[SingleFunctionArgsField.name] = [
    if (value.name.toLowerCase() != value.name)
      ValidaError(
        message: r'Should be lowercase',
        errorCode: 'ValidaString.isLowercase',
        property: 'name',
        validationParam: null,
        value: value.name,
      )
  ];
  errors[SingleFunctionArgsField.lastName] = [
    if (value.lastName.toUpperCase() != value.lastName)
      ValidaError(
        message: r'Should be uppercase',
        errorCode: 'ValidaString.isUppercase',
        property: 'lastName',
        validationParam: null,
        value: value.lastName,
      )
  ];

  return SingleFunctionArgsValidation(
    errors,
    value,
    SingleFunctionArgsValidationFields(errors),
  );
}

/// The arguments for [_singleFunction2].
class _SingleFunction2Args {
  final String name;
  final List<dynamic> nonEmptyList;
  final String lastName;

  /// The arguments for [_singleFunction2].
  const _SingleFunction2Args(
    this.name, {
    required this.nonEmptyList,
    this.lastName = 'NONE',
  });

  /// Validates this arguments for [_singleFunction2].
  _SingleFunction2ArgsValidation validate() =>
      _validateSingleFunction2Args(this);

  /// Validates this arguments for [_singleFunction2] and
  /// returns the successfully [Validated] value or
  /// throws a [_SingleFunction2ArgsValidation] when there is an error.
  Validated<_SingleFunction2Args> isValidOrThrow() {
    final validation = validate();
    if (validation.hasErrors) {
      throw validation;
    }
    return validation.validated!;
  }

  /// Returns a Map with all fields
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

  List<ValidaError> get name => errorsMap[_SingleFunction2ArgsField.name]!;
  List<ValidaError> get lastName =>
      errorsMap[_SingleFunction2ArgsField.lastName]!;
  List<ValidaError> get nonEmptyList =>
      errorsMap[_SingleFunction2ArgsField.nonEmptyList]!;
}

class _SingleFunction2ArgsValidation
    extends Validation<_SingleFunction2Args, _SingleFunction2ArgsField> {
  _SingleFunction2ArgsValidation(this.errorsMap, this.value, this.fields)
      : super(errorsMap);

  final Map<_SingleFunction2ArgsField, List<ValidaError>> errorsMap;

  final _SingleFunction2Args value;

  final _SingleFunction2ArgsValidationFields fields;

  static const validationSpec = {
    'name': ValidaString(isLowercase: true, isAlpha: true),
    'lastName': ValidaString(isUppercase: true, isAlpha: true),
    'nonEmptyList': ValidaList(minLength: 1),
  };

  static List<ValidaError> globalValidate(_SingleFunction2Args value) => [];

  static Object? getField(_SingleFunction2Args value, String field) {
    switch (field) {
      case 'name':
        return value.name;
      case 'lastName':
        return value.lastName;
      case 'nonEmptyList':
        return value.nonEmptyList;
      default:
        throw Exception();
    }
  }
}

_SingleFunction2ArgsValidation _validateSingleFunction2Args(
    _SingleFunction2Args value) {
  final errors = <_SingleFunction2ArgsField, List<ValidaError>>{};

  errors[_SingleFunction2ArgsField.name] = [
    if (value.name.toLowerCase() != value.name)
      ValidaError(
        message: r'Should be lowercase',
        errorCode: 'ValidaString.isLowercase',
        property: 'name',
        validationParam: null,
        value: value.name,
      )
  ];
  errors[_SingleFunction2ArgsField.lastName] = [
    if (value.lastName.toUpperCase() != value.lastName)
      ValidaError(
        message: r'Should be uppercase',
        errorCode: 'ValidaString.isUppercase',
        property: 'lastName',
        validationParam: null,
        value: value.lastName,
      )
  ];
  errors[_SingleFunction2ArgsField.nonEmptyList] = [
    if (value.nonEmptyList.length < 1)
      ValidaError(
        message: r'Should be at a minimum 1 in length',
        errorCode: 'ValidaList.minLength',
        property: 'nonEmptyList',
        validationParam: 1,
        value: value.nonEmptyList,
      )
  ];

  return _SingleFunction2ArgsValidation(
    errors,
    value,
    _SingleFunction2ArgsValidationFields(errors),
  );
}

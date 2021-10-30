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
    ...value._customValidate3()
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

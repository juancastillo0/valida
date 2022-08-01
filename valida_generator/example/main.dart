import 'package:valida/valida.dart';

part 'main.g.dart';

// global config from build.yaml
// more annotations
// custom validator ergonomics, for field and for class
// nested validation execution and result

@Valida(nullableErrorLists: true, customValidate: FormTest._customValidate)
class FormTest {
  static List<ValidaError> _customValidate(FormTest value) {
    return [];
  }

  @ValidaString(
    minLength: 15,
    maxLength: 50,
    matches: r'^[a-zA-Z]+$',
    customValidate: _customValidateStr,
    description: 'should have between 15 and 50 bytes, only letters'
        " and cannot be 'WrongValue'",
  )
  final String longStr;

  @ValidaString(maxLength: 20, contains: '@')
  final String shortStr;

  @ValidaNum(isInt: true, min: 0, customValidate: FormTest._customValidateNum)
  final num positiveInt;

  static List<ValidaError> _customValidateNum(num value) {
    return [];
  }

  @ValidaFunction()
  static List<ValidaError> _customValidate2(FormTest value) {
    return [
      if (value.optionalDecimal == null && value.identifier == null)
        ValidaError(
          errorCode: 'CustomError.not',
          message: 'CustomError message',
          property: 'identifier',
          value: value,
        )
    ];
  }

  @ValidaFunction()
  List<ValidaError> _customValidate3() {
    return _customValidate2(this);
  }

  @ValidaNum(
    min: 0,
    max: 1,
    comp: ValidaComparison<num>(
      less: CompVal(0),
      moreEq: CompVal.list([CompVal.ref('positiveInt')]),
    ),
  )
  final double? optionalDecimal;

  @ValidaList(minLength: 1, each: ValidaString(isDate: true, maxLength: 3))
  final List<String> nonEmptyList;

  @ValidaString(isUUID: UUIDVersion.v4)
  final String? identifier;

  final NestedField? nested;

  @ValidaList(
    maxLength: 2,
    each: ValidaNested(
      overrideValidation: NestedFieldValidation.fromValue,
      omit: false,
      customValidate: FormTest._customValidateNestedListItem,
    ),
  )
  final List<NestedField>? nestedList;

  final Map<String, NestedField?> nestedMap;

  @ValidaSet(
    each: ValidaNested<NestedField>(omit: true),
  )
  final Set<NestedField?> nestedSet;

  static List<ValidaError> _customValidateNestedListItem(NestedField f) {
    return [
      if (f.timeStr == '00:00')
        ValidaError(
          errorCode: '00:00',
          message: "Can't have a time 00:00 for values in list.",
          property: 'timeStr',
          value: f,
        ),
    ];
  }

  ///
  const FormTest({
    required this.longStr,
    required this.shortStr,
    required this.positiveInt,
    required this.optionalDecimal,
    required this.nonEmptyList,
    required this.identifier,
    this.nested,
    this.nestedList,
    this.nestedMap = const {},
    this.nestedSet = const {},
  });
}

List<ValidaError> _customValidateStr(String value) {
  // Validate `value` and return a list of errors
  return [
    if (value == 'WrongValue')
      ValidaError(
        errorCode: 'CustomError.wrong',
        message: 'WrongValue is not allowed',
        property: 'longStr',
        value: value,
      ),
  ];
}

@Valida(enumFields: false)
class NestedField {
  @ValidaString(isTime: true)
  final String timeStr;

  @ValidaDate(min: '2021-01-01')
  final DateTime dateWith2021Min;

  @ValidaDate(max: 'now')
  final DateTime? optionalDateWithNowMax;

  ///
  const NestedField({
    required this.timeStr,
    required this.dateWith2021Min,
    required this.optionalDateWithNowMax,
  });
}

List<ValidaError> _customValidateSingleFunction(Object? _args) {
  final args = _args! as SingleFunctionArgs;
  return [
    if (args.name == 'none' && args.lastName == 'NONE')
      ValidaError(
        property: 'name',
        value: args.name,
        errorCode: 'Custom.noNoneName',
        message: "Can't have a 'none' name and a 'NONE' last name",
      ),
  ];
}

@Valida(customValidate: _customValidateSingleFunction)
int singleFunction(
  @ValidaString(isLowercase: true, isAlpha: true) String name, [
  @ValidaString(isUppercase: true, isAlpha: true) String lastName = 'NONE',
]) {
  final validation = SingleFunctionArgs(name, lastName).validate();
  if (validation.hasErrors) {
    throw validation;
  }
  return name.length + lastName.length;
}

@Valida()
int _singleFunction2(
  @ValidaString(isLowercase: true, isAlpha: true) String name, {
  @ValidaString(isUppercase: true, isAlpha: true) String lastName = 'NONE',
  @ValidaList<Object>(minLength: 1) required List<Object> nonEmptyList,
  Map<NestedField, List>? dynamicList,
}) {
  final validated = _SingleFunction2Args(
    name,
    lastName: lastName,
    nonEmptyList: nonEmptyList,
    dynamicList: dynamicList,
  ).validatedOrThrow();
  return name.length + lastName.length + nonEmptyList.length;
}

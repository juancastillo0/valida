import 'package:valida/valida.dart';

part 'main.g.dart';

// global config from build.yaml
// more annotations
// custom validator ergonomics, for field and for class
// nested validation execution and result

@Valida(nullableErrorLists: true, customValidate: FormTest._customValidate)
class FormTest {
  static List<ValidaError> _customValidate(Object? value) {
    return [];
  }

  @ValidaString(
    minLength: 15,
    maxLength: 50,
    matches: r'^[a-zA-Z]+$',
    customValidate: _customValidateStr,
  )
  final String longStr;

  @ValidaString(maxLength: 20, contains: '@')
  final String shortStr;

  @ValidaNum(isInt: true, min: 0, customValidate: _customValidateNum)
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

  const FormTest({
    required this.longStr,
    required this.shortStr,
    required this.positiveInt,
    required this.optionalDecimal,
    required this.nonEmptyList,
    required this.identifier,
    this.nested,
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

@Valida()
class NestedField {
  @ValidaString(isTime: true)
  final String timeStr;

  @ValidaDate(min: '2021-01-01')
  final DateTime dateWith2021Min;

  @ValidaDate(max: 'now')
  final DateTime? optionalDateWithNowMax;

  NestedField({
    required this.timeStr,
    required this.dateWith2021Min,
    required this.optionalDateWithNowMax,
  });
}

# valida

Validators for Dart and Flutter. Create field, params and object validators from code annotations.

## Getting Started


Add to pubspec.yaml

```yaml
dependencies:
    valida: ^0.0.1
dev_dependencies:
    build_runner: <latest>
    valida_generator: ^0.0.1
```

Run `pub get` and create your model class:

```dart
import 'package:valida/valida.dart';

part 'model.g.dart';

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

```

Execute build_runner to generate the validation code

```
dart pub run build_runner watch --delete-conflicting-outputs
```

Use the generated `validateFormTest` with your model

```dart
import 'model.dart'

void main() {
    const form = FormTest(
      longStr: 'long Str',
      shortStr: 'shortStr',
      positiveInt: 2.4,
      optionalDecimal: 3,
      nonEmptyList: [],
      identifier: 'identifier',
    );

    final FormTestValidation validation = validateFormTest(form);
    assert(validation is Validation<FormTest, FormTestField>);
    expect(validation.numErrors, validation.allErrors.length);
    expect(validation.hasErrors, true);

    final errorsMap = validation.errorsMap;
    expect(errorsMap.isNotEmpty, true);

    expect(errorsMap[FormTestField.longStr]?.length, 2);
    expect(validation.fields.longStr!.length, 2);
    expect(errorsMap[FormTestField.shortStr]?.length, 1);
    expect(validation.fields.shortStr!.length, 1);
    expect(errorsMap[FormTestField.positiveInt]?.length, 1);
    expect(validation.fields.positiveInt!.length, 1);
    expect(errorsMap[FormTestField.nonEmptyList]?.length, 1);
    expect(validation.fields.nonEmptyList!.length, 1);
    expect(errorsMap[FormTestField.optionalDecimal]?.length, 2);
    expect(validation.fields.optionalDecimal!.length, 2);
}
```

The code generator produces the following output

- A function `ModelValidation validateModel(Model)`, that executes the validation
- `ModelValidation` which extends `Validation<Model, ModelField>`, has utility getters for the number of errors, the validated value, whether the validation was successful or not and a `ModelValidationFields` getter
- An enum `ModelField` of the fields for the validated class
- A utility `ModelValidationFields` class which contains named getters for the errors of each field


```dart

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
  // ...
  // More validations
  // ...
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

```

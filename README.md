# valida

Validators for Dart and Flutter. Includes a code generator for validating classes and functions.

## Getting Started


Add to pubspec.yaml
```yaml
dependencies:
    valida: ^0.1
dependencies:
    build_runner: <latest>
    valida_generator: ^0.1
```

Run `pub get` and create your model class:

```dart
import 'package:valida/valida.dart';

part 'model.g.dart';

List<ValidationError> _customValidateStr(String value) {
  return [];
}

@Validate(nullableErrorLists: true, customValidate: FormTest._customValidate)
class FormTest {
  static List<ValidationError> _customValidate(Object? value) {
    return [];
  }

  @ValidateString(
    minLength: 15,
    maxLength: 50,
    matches: r'^[a-zA-Z]+$',
    customValidate: _customValidateStr,
  )
  final String longStr;

  @ValidateString(maxLength: 20, contains: '@')
  final String shortStr;

  @ValidateNum(isInt: true, min: 0, customValidate: _customValidateNum)
  final num positiveInt;

  static List<ValidationError> _customValidateNum(num value) {
    return [];
  }

  @ValidationFunction()
  static List<ValidationError> _customValidate2(FormTest value) {
    return [
      if (value.optionalDecimal == null && value.identifier == null)
        ValidationError(
          errorCode: 'CustomError.not',
          message: 'CustomError message',
          property: 'identifier',
          value: value,
        )
    ];
  }

  @ValidationFunction()
  List<ValidationError> _customValidate3() {
    return _customValidate2(this);
  }

  @ValidateNum(
    min: 0,
    max: 1,
    comp: ValidateComparison<num>(
      less: CompVal(0),
      moreEq: CompVal.list([CompVal.ref('positiveInt')]),
    ),
  )
  final double? optionalDecimal;

  @ValidateList(minLength: 1, each: ValidateString(isDate: true, maxLength: 3))
  final List<String> nonEmptyList;

  @ValidateString(isUUID: UUIDVersion.v4)
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

@Validate()
class NestedField {
  @ValidateString(isTime: true)
  final String timeStr;

  @ValidateDate(min: '2021-01-01')
  final DateTime dateWith2021Min;

  @ValidateDate(max: 'now')
  final DateTime? optionalDateWithNowMax;

  NestedField({
    required this.timeStr,
    required this.dateWith2021Min,
    required this.optionalDateWithNowMax,
  });
}
```

Execute build_runner

```
flutter pub run build_runner watch --delete-conflicting-outputs
```

Use the generated `validateFormTest` with yout model

```dart
import 'model.dart'

void main() {
    final form = FormTest(
      longStr: 'long Str',
      shortStr: 'shortStr',
      positiveInt: 2.4,
      optionalDecimal: 3,
      nonEmptyList: [],
      identifier: 'identifier',
    );

    final errors = validateFormTest(form);
    assert(errors.numErrors == errors.allErrors.length);
    assert(errors.hasErrors == true);
    assert(errors.fields.nonEmptyList != null);

    final errorsMap = errors.errorsMap;

    assert(errorsMap.isNotEmpty == true);
    assert(errorsMap['longStr']?.length == 2);
    assert(errorsMap['shortStr']?.length == 1);
    assert(errorsMap['positiveInt']?.length == 1);
    assert(errorsMap['nonEmptyList']?.length == 1);
    assert(errorsMap['optionalDecimal']?.length == 1);
}
```

## Getting Started

This project is a starting point for a Dart
[package](https://flutter.dev/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

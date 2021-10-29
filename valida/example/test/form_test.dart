import 'package:valida_example/model.dart';
import 'package:test/test.dart';

void main() {
  test('validate FormTest', () {
    const form = FormTest(
      longStr: 'long Str',
      shortStr: 'shortStr',
      positiveInt: 2.4,
      optionalDecimal: 3,
      nonEmptyList: [],
      identifier: 'identifier',
    );

    final errors = validateFormTest(form);
    expect(errors.numErrors, errors.allErrors.length);
    expect(errors.hasErrors, true);

    final errorsMap = errors.errorsMap;
    expect(errorsMap.isNotEmpty, true);

    expect(errorsMap[FormTestField.longStr]?.length, 2);
    expect(errors.fields.longStr!.length, 2);
    expect(errorsMap[FormTestField.shortStr]?.length, 1);
    expect(errors.fields.shortStr!.length, 1);
    expect(errorsMap[FormTestField.positiveInt]?.length, 1);
    expect(errors.fields.positiveInt!.length, 1);
    expect(errorsMap[FormTestField.nonEmptyList]?.length, 1);
    expect(errors.fields.nonEmptyList!.length, 1);
    expect(errorsMap[FormTestField.optionalDecimal]?.length, 2);
    expect(errors.fields.optionalDecimal!.length, 2);
  });
}

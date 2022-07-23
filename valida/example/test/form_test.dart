import 'package:valida/valida.dart';
import 'package:valida_example/main.dart';
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

    final FormTestValidation validation = FormTestValidation.fromValue(form);
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
  });
}

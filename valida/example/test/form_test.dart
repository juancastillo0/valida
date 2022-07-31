import 'package:valida/valida.dart';
import 'package:valida_example/main.dart';
import 'package:test/test.dart';

void main() {
  test('validate FormTest', () {
    final form = FormTest(
      longStr: 'long Str',
      shortStr: 'shortStr',
      positiveInt: 2.4,
      optionalDecimal: 3,
      nonEmptyList: [],
      identifier: 'identifier',
      nested: NestedField(
        timeStr: '20:34',
        dateWith2021Min: DateTime(2020, 03, 03),
        optionalDateWithNowMax: DateTime(7340, 2, 3),
      ),
    );

    final FormTestValidation validation = FormTestValidation.fromValue(form);
    assert(validation is Validation<FormTest, FormTestField>);
    expect(validation.numErrors, 10);
    expect(validation.allErrors.length, 9);
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

    expect(errorsMap[FormTestField.nested]?.length, 1);
    expect(validation.fields.nested!.fields.optionalDateWithNowMax.length, 1);
    final errorJson = {
      'property': 'dateWith2021Min',
      'message': 'Should be at a minimum 2021-01-01',
      'errorCode': 'ValidaDate.min',
      'validationParam': '2021-01-01',
    };
    expect(
      validation.fields.nested!.fields.dateWith2021Min.map((e) => e.toJson()),
      [errorJson],
    );
    expect(
      validation.fields.nested!.fields.dateWith2021Min.map(
        (e) => e.toJson(withValue: true),
      ),
      [
        {...errorJson, 'value': form.nested!.dateWith2021Min}
      ],
    );
  });

  test('validate FormTest toJson and fromJson', () {
    for (final e in FormTestValidation.spec.fieldsMap.entries) {
      final v = e.value.toJson();
      final v2 = ValidaField<Object?>.fromJson(v);
      expect(v, v2.toJson());
    }
    expect(
      FormTestValidation.spec.fieldsMap[FormTestField.longStr]!
          .toJson()['description'],
      'should have between 15 and 50 bytes, only letters'
      " and cannot be 'WrongValue'",
    );
  });
}

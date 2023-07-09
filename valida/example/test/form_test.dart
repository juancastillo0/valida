import 'package:valida/valida.dart';
import 'package:valida_example/all_validators.dart';
import 'package:valida_example/main.dart';
import 'package:test/test.dart';

void main() {
  final errorJsonDateWith2021Min = {
    'property': 'dateWith2021Min',
    'message': 'Should be at a minimum 2021-01-01',
    'errorCode': 'ValidaDate.min',
    'validationParam': '2021-01-01',
  };

  final errorJsonOptionalDateWithNowMax = {
    'property': 'optionalDateWithNowMax',
    'message': 'Should be at a maximum now',
    'errorCode': 'ValidaDate.max',
    'validationParam': 'now',
  };

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
    expect(
      validation.errorsMap.toString(),
      Validators.instance().validate(form)?.errorsMap.toString(),
    );
    // ignore: unnecessary_type_check
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
    expect(
      validation.fields.nested!.fields.dateWith2021Min.map((e) => e.toJson()),
      [errorJsonDateWith2021Min],
    );
    expect(
      validation.fields.nested!.fields.dateWith2021Min.map(
        (e) => e.toJson(withValue: true),
      ),
      [
        {...errorJsonDateWith2021Min, 'value': form.nested!.dateWith2021Min}
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

  test('all validators', () {
    expect(
      identical(
        Validators.validatorFormTest,
        Validators.instance().validator<FormTest>(),
      ),
      true,
    );

    expect(
      identical(
        Validators.validatorNestedField,
        Validators.instance().validator<NestedField>(),
      ),
      true,
    );

    expect(Validators.instance().typeMap, hasLength(4 * 2));
  });

  test('GenericModel', () {
    final validation = GenericModelValidation.fromValue(
      GenericModel<FormTest?, NestedField>(
        value: null,
        params: 'dwdw',
        objects: [
          NestedField(
            timeStr: '20:34',
            dateWith2021Min: DateTime(2020, 03, 03),
            optionalDateWithNowMax: DateTime(7340, 2, 3),
          ),
        ],
      ),
    );

    expect(validation.fields.objects.map((e) => e.toJson()), [
      {
        'property': 'objects[0]',
        'errorCode': 'Valida.nested',
        'message': 'Found 2 errors in objects[0]',
        'nestedValidation': {
          'dateWith2021Min': [errorJsonDateWith2021Min],
          'optionalDateWithNowMax': [errorJsonOptionalDateWithNowMax],
        },
      },
    ]);

    expect(
      GenericModelValidation.fromValue(
        GenericModel<FormTest?, NestedField>(
          value: null,
          params: '',
          objects: [],
        ),
      ).fields.params.map((e) => e.toJson(withValue: true)),
      [
        {
          'property': 'params',
          'errorCode': 'ValidaLength.minLength',
          'message': 'Should have a minimum length of 1',
          'validationParam': 1,
          'value': ''
        }
      ],
    );

    final validation2 = GenericModelValidation.fromValue(
      GenericModel<NestedField, FormTest>(
        value: NestedField(
          timeStr: 'notTime',
          dateWith2021Min: DateTime(2020, 03, 03),
          optionalDateWithNowMax: DateTime(2010, 2, 3),
        ),
        params: 'dwdw',
        objects: [],
      ),
    );

    final validation3 = GenericModelValidation.fromValue(
      GenericModel<NestedField?, FormTest>(
        value: NestedField(
          timeStr: 'notTime',
          dateWith2021Min: DateTime(2020, 03, 03),
          optionalDateWithNowMax: DateTime(2010, 2, 3),
        ),
        params: 'dwdw',
        objects: [],
      ),
    );
    expect(validation2.toJson(), {
      'value': [
        {
          'property': 'value',
          'errorCode': 'Valida.nested',
          'message': 'Found 2 errors in value',
          'nestedValidation': {
            'timeStr': [
              {
                'property': 'timeStr',
                'errorCode': 'ValidaString.isTime',
                'message': 'Should be a time'
              }
            ],
            'dateWith2021Min': [errorJsonDateWith2021Min],
          },
        },
      ],
    });
    expect(validation2.toJson(), validation3.toJson());
  });

  test('is time', () {
    bool isTime(String time) {
      final value = DateTime.tryParse('1970-01-01T$time');
      print('$time $value');
      return value != null;
    }

    isTime('notTime');
    isTime('10');
    isTime('01');
    isTime('10:40');
    isTime('04:20:23.392');
    isTime('04:20:61.392');
    isTime('21:61');
    isTime('24:61');
    isTime('00:60:00');
    isTime('00:00:60');
    isTime('00:00:59.05');
    isTime('24:00:00');
    isTime('24:00');

    isTime('10:40:59 Z');
    isTime('10:40 -05');
  });
}

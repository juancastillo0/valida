import 'package:valida/valida.dart';
import 'package:valida_example/main.dart';

// ignore: avoid_classes_with_only_static_members
class Validators {
  static const typeMap = <Type, Validator>{
    FormTest: validatorFormTest,
    NestedField: validatorNestedField,
  };

  static const validatorFormTest = Validator(FormTestValidation.fromValue);
  static const validatorNestedField =
      Validator(NestedFieldValidation.fromValue);

  static Validator<T, Validation<T, Object>>? validator<T>() {
    final validator = typeMap[T];
    return validator as Validator<T, Validation<T, Object>>?;
  }

  static Validation<T, Object>? validate<T>(T value) {
    final validator = typeMap[T];
    return validator?.validate(value) as Validation<T, Object>?;
  }
}

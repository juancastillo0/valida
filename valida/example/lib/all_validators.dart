import 'package:valida/valida.dart';
import 'package:valida_example/main.dart';

/// A validator with all the validators
/// found in code generation.
class Validators with GenericValidator {
  Validators._() {
    for (final v in <Validator>[
      validatorFormTest,
      validatorNestedField,
      validatorGenericModel,
      validatorSingleFunctionArgs,
    ]) {
      typeMap[v.modelType] = v;
      typeMap[v.modelNullType] = v;
    }
  }
  static final _instance = Validators._();

  /// Returns the [Validators] instance with the validators
  /// found in code generation
  static Validators instance() => _instance;

  /// A map with all registered validators by
  /// the type of the model to validate
  final typeMap = <Type, Validator>{};

  @override
  Validator<T, Validation<T, Object>>? validator<T>() {
    final validator = typeMap[T];
    return validator as Validator<T, Validation<T, Object>>?;
  }

  @override
  Validation<T, Object>? validate<T>(T value) {
    if (value == null) return null;
    final validator = typeMap[T];
    return validator?.validate(value) as Validation<T, Object>?;
  }

  static const validatorFormTest = Validator(FormTestValidation.fromValue);
  static const validatorNestedField =
      Validator(NestedFieldValidation.fromValue);
  static const validatorGenericModel =
      Validator(GenericModelValidation.fromValue);
  static const validatorSingleFunctionArgs =
      Validator(SingleFunctionArgsValidation.fromValue);
}

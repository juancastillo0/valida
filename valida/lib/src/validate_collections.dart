import 'package:valida/serde_type.dart';
import 'package:valida/src/validate.dart';

/// Specification of the validation that should be
/// executed over a given value which has a length.
/// For example, collections like lists, sets and maps.
mixin ValidaLength {
  /// The minimum length the value should be
  int? get minLength;

  /// The maximum length the value should be
  int? get maxLength;

  /// Returns an iterable with the errors of validating [value] with [length]
  Iterable<ValidaError> validateLength(
    String property,
    Object value,
    int length,
  ) sync* {
    if (minLength != null && length < minLength!) {
      yield ValidaError(
        property: property,
        value: value,
        errorCode: 'ValidaLength.minLength',
        message: 'Should have a minimum length of ${minLength}',
        validationParam: minLength,
      );
    }
    if (maxLength != null && length > maxLength!) {
      yield ValidaError(
        property: property,
        value: value,
        errorCode: 'ValidaLength.maxLength',
        message: 'Should have a maximum length of ${maxLength}',
        validationParam: maxLength,
      );
    }
  }
}

/// Specification of the validation that should be
/// executed over a given [List]
class ValidaList<T> extends ValidaField<List<T>> with ValidaLength {
  @override
  final int? minLength;
  @override
  final int? maxLength;

  /// Validates each value in the list with [each]'s configuration
  final ValidaField<T>? each;

  @override
  ValidaFieldType get variantType => ValidaFieldType.list;

  @override
  final List<ValidaError> Function(List<T>)? customValidate;
  @override
  final String? customValidateName;
  @override
  final String? description;

  /// Specification of the validation that should be
  /// executed over a given [List]
  const ValidaList({
    this.minLength,
    this.maxLength,
    this.each,
    this.customValidate,
    this.customValidateName,
    this.description,
  });

  @override
  Map<String, Object?> toJson() {
    return {
      ValidaField.variantTypeString: variantType.name,
      'minLength': minLength,
      'maxLength': maxLength,
      'each': each?.toJson(),
      'description': description,
    };
  }

  factory ValidaList.fromJson(Map<String, Object?> map) {
    return ValidaList(
      minLength: map['minLength'] as int?,
      maxLength: map['maxLength'] as int?,
      each: map['each'] == null
          ? null
          : ValidaField.fromJson(map['each']! as Map<String, Object?>),
      customValidateName: map['customValidate'] as String?,
      description: map['description'] as String?,
    );
  }

  static const fieldsSerde = {
    'minLength': SerdeType.int,
    'maxLength': SerdeType.int,
    'each': ValidaField.fieldsSerde,
    'customValidate': SerdeType.function,
    'description': SerdeType.str,
  };

  @override
  List<ValidaError> validate(
    String property,
    Object? Function(String property) getter,
  ) {
    final List<ValidaError> errors = [];
    final value = getter(property) as List<T?>?;
    if (value == null) return errors;

    errors.addAll(validateLength(property, value, value.length));
    if (each != null) {
      int i = 0;
      errors.addAll(
        value.expand(
          (e) => e is T
              ? each!.validateValue(
                  e,
                  name: '$property[${i++}]',
                  getter: getter,
                )
              : const [],
        ),
      );
    }
    if (customValidate != null) {
      errors.addAll(customValidate!(value.cast()));
    }

    return errors;
  }
}

/// Specification of the validation that should be
/// executed over a given [Set]
class ValidaSet<T> extends ValidaField<Set<T>> with ValidaLength {
  @override
  final int? minLength;
  @override
  final int? maxLength;

  /// Validates each value in the set with [each]'s configuration
  final ValidaField<T>? each;

  @override
  ValidaFieldType get variantType => ValidaFieldType.set;

  @override
  final List<ValidaError> Function(Set<T>)? customValidate;
  @override
  final String? customValidateName;
  @override
  final String? description;

  /// Specification of the validation that should be
  /// executed over a given [Set]
  const ValidaSet({
    this.minLength,
    this.maxLength,
    this.each,
    this.customValidate,
    this.customValidateName,
    this.description,
  });

  @override
  Map<String, Object?> toJson() {
    return {
      ValidaField.variantTypeString: variantType.name,
      'minLength': minLength,
      'maxLength': maxLength,
      'each': each?.toJson(),
      'customValidate': customValidateName,
      'description': description,
    };
  }

  factory ValidaSet.fromJson(Map<String, Object?> map) {
    return ValidaSet(
      minLength: map['minLength'] as int?,
      maxLength: map['maxLength'] as int?,
      each: map['each'] == null
          ? null
          : ValidaField.fromJson(map['each']! as Map<String, Object?>),
      customValidateName: map['customValidate'] as String?,
      description: map['description'] as String?,
    );
  }

  static const fieldsSerde = {
    'minLength': SerdeType.int,
    'maxLength': SerdeType.int,
    'each': ValidaField.fieldsSerde,
    'customValidate': SerdeType.function,
    'description': SerdeType.str,
  };

  @override
  List<ValidaError> validate(
    String property,
    Object? Function(String property) getter,
  ) {
    final List<ValidaError> errors = [];
    final value = getter(property) as Set<T?>?;
    if (value == null) return errors;

    errors.addAll(validateLength(property, value, value.length));
    if (each != null) {
      int i = 0;
      errors.addAll(
        value.expand(
          (e) => e is T
              ? each!.validateValue(
                  e,
                  name: '$property[${i++}]',
                  getter: getter,
                )
              : const [],
        ),
      );
    }
    if (customValidate != null) {
      errors.addAll(customValidate!(value.cast()));
    }

    return errors;
  }
}

/// Specification of the validation that should be
/// executed over a given [Map]
class ValidaMap<K, V> extends ValidaField<Map<K, V>> with ValidaLength {
  @override
  final int? minLength;
  @override
  final int? maxLength;

  /// Validates each key in the map with [eachKey]'s configuration
  final ValidaField<K>? eachKey;

  /// Validates each value in the map with [eachValue]'s configuration
  final ValidaField<V>? eachValue;

  @override
  ValidaFieldType get variantType => ValidaFieldType.map;

  @override
  final List<ValidaError> Function(Map<K, V>)? customValidate;
  @override
  final String? customValidateName;
  @override
  final String? description;

  /// Specification of the validation that should be
  /// executed over a given [Map]
  const ValidaMap({
    this.minLength,
    this.maxLength,
    this.eachKey,
    this.eachValue,
    this.customValidate,
    this.customValidateName,
    this.description,
  });

  @override
  Map<String, Object?> toJson() {
    return {
      ValidaField.variantTypeString: variantType.name,
      'minLength': minLength,
      'maxLength': maxLength,
      'eachKey': eachKey?.toJson(),
      'eachValue': eachValue?.toJson(),
      'customValidate': customValidateName,
      'description': description,
    };
  }

  factory ValidaMap.fromJson(Map<String, Object?> map) {
    return ValidaMap(
      minLength: map['minLength'] as int?,
      maxLength: map['maxLength'] as int?,
      eachKey: map['eachKey'] == null
          ? null
          : ValidaField.fromJson(map['eachKey']! as Map<String, Object?>),
      eachValue: map['eachValue'] == null
          ? null
          : ValidaField.fromJson(map['eachValue']! as Map<String, Object?>),
      customValidateName: map['customValidate'] as String?,
      description: map['description'] as String?,
    );
  }

  static const fieldsSerde = {
    'minLength': SerdeType.int,
    'maxLength': SerdeType.int,
    'eachKey': ValidaField.fieldsSerde,
    'eachValue': ValidaField.fieldsSerde,
    'customValidate': SerdeType.function,
    'description': SerdeType.str,
  };

  @override
  List<ValidaError> validate(
    String property,
    Object? Function(String property) getter,
  ) {
    final List<ValidaError> errors = [];
    final value = getter(property) as Map<K?, V?>?;
    if (value == null) return errors;

    errors.addAll(validateLength(property, value, value.length));
    if (eachKey != null) {
      errors.addAll(
        value.keys.expand(
          (key) => key is K
              ? eachKey!.validateValue(
                  key,
                  name: '$property[${key}].key',
                  getter: getter,
                )
              : const [],
        ),
      );
    }
    if (eachValue != null) {
      errors.addAll(
        value.entries.expand(
          (e) => e.value is V
              ? eachValue!.validateValue(
                  e.value as V,
                  name: '$property[${e.key}].value',
                  getter: getter,
                )
              : const [],
        ),
      );
    }
    if (customValidate != null) {
      errors.addAll(customValidate!(value.cast()));
    }

    return errors;
  }
}

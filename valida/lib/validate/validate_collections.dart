import 'package:valida/serde_type.dart';
import 'package:valida/validate/validate.dart';

/// Specification of the validation that should be
/// executed over a given value which has a length.
/// For example, collections like lists, sets and maps.
abstract class ValidaLength {
  /// The minimum length the value should be
  int? get minLength;

  /// The maximum length the value should be
  int? get maxLength;
}

/// Specification of the validation that should be
/// executed over a given [List]
class ValidaList<T> extends ValidaField<List<T>> implements ValidaLength {
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

  /// Specification of the validation that should be
  /// executed over a given [List]
  const ValidaList({
    this.minLength,
    this.maxLength,
    this.each,
    this.customValidate,
    this.customValidateName,
  });

  @override
  Map<String, Object?> toJson() {
    return {
      ValidaField.variantTypeString: variantType.toString(),
      'minLength': minLength,
      'maxLength': maxLength,
      'each': each?.toJson(),
    };
  }

  factory ValidaList.fromJson(Map<String, Object?> map) {
    return ValidaList(
      minLength: map['minLength'] as int?,
      maxLength: map['maxLength'] as int?,
      each: map['each'] == null
          ? null
          : (ValidaField.fromJson(map['each']! as Map<String, Object?>)
              as ValidaField<T>),
      customValidateName: map['customValidate'] as String?,
    );
  }

  static const fieldsSerde = {
    'minLength': SerdeType.int,
    'maxLength': SerdeType.int,
    'each': ValidaField.fieldsSerde,
    'customValidate': SerdeType.function,
  };
}

/// Specification of the validation that should be
/// executed over a given [Set]
class ValidaSet<T> extends ValidaField<Set<T>> implements ValidaLength {
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

  /// Specification of the validation that should be
  /// executed over a given [Set]
  const ValidaSet({
    this.minLength,
    this.maxLength,
    this.each,
    this.customValidate,
    this.customValidateName,
  });

  @override
  Map<String, Object?> toJson() {
    return {
      ValidaField.variantTypeString: variantType.toString(),
      'minLength': minLength,
      'maxLength': maxLength,
      'each': each?.toJson(),
      'customValidate': customValidateName,
    };
  }

  factory ValidaSet.fromJson(Map<String, Object?> map) {
    return ValidaSet(
      minLength: map['minLength'] as int?,
      maxLength: map['maxLength'] as int?,
      each: map['each'] == null
          ? null
          : (ValidaField.fromJson(map['each']! as Map<String, Object?>)
              as ValidaField<T>),
      customValidateName: map['customValidate'] as String?,
    );
  }

  static const fieldsSerde = {
    'minLength': SerdeType.int,
    'maxLength': SerdeType.int,
    'each': ValidaField.fieldsSerde,
    'customValidate': SerdeType.function,
  };
}

/// Specification of the validation that should be
/// executed over a given [Map]
class ValidaMap<K, V> extends ValidaField<Map<K, V>> implements ValidaLength {
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

  /// Specification of the validation that should be
  /// executed over a given [Map]
  const ValidaMap({
    this.minLength,
    this.maxLength,
    this.eachKey,
    this.eachValue,
    this.customValidate,
    this.customValidateName,
  });

  @override
  Map<String, Object?> toJson() {
    return {
      ValidaField.variantTypeString: variantType.toString(),
      'minLength': minLength,
      'maxLength': maxLength,
      'eachKey': eachKey?.toJson(),
      'eachValue': eachValue?.toJson(),
      'customValidate': customValidateName,
    };
  }

  factory ValidaMap.fromJson(Map<String, Object?> map) {
    return ValidaMap(
      minLength: map['minLength'] as int?,
      maxLength: map['maxLength'] as int?,
      eachKey: map['eachKey'] == null
          ? null
          : (ValidaField.fromJson(map['eachKey']! as Map<String, Object?>)
              as ValidaField<K>),
      eachValue: map['eachValue'] == null
          ? null
          : (ValidaField.fromJson(map['eachValue']! as Map<String, Object?>)
              as ValidaField<V>),
      customValidateName: map['customValidate'] as String?,
    );
  }

  static const fieldsSerde = {
    'minLength': SerdeType.int,
    'maxLength': SerdeType.int,
    'eachKey': ValidaField.fieldsSerde,
    'eachValue': ValidaField.fieldsSerde,
    'customValidate': SerdeType.function,
  };
}

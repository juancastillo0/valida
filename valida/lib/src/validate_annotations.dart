import 'package:valida/serde_type.dart';
import 'package:valida/src/validate.dart';

export 'models/comp_val.dart';
export 'validate_collections.dart';
export 'validate_string.dart';

/// Specification of the validation that should be
/// executed over a given class
///
/// if [nullableErrorLists] is true, the error lists for each
/// field will be nullable. Default false.
/// if [enumFields] is true, the field type will be a
/// generated enum. Default true.
class Valida with ToJson implements ValidaCustom<Object?> {
  /// If true, the error lists for each field will be nullable.
  /// Default false.
  final bool? nullableErrorLists;

  /// If true, the field type will be a generated enum.
  /// Default true.
  final bool? enumFields;

  @override
  final List<ValidaError> Function(Object?)? customValidate;
  @override
  final String? customValidateName;

  /// Specification of the validation that should be
  /// executed over a given class
  ///
  /// if [nullableErrorLists] is true, the error lists for each
  /// field will be nullable. Default false.
  /// if [enumFields] is true, the field type will be a
  /// generated enum. Default true.
  const Valida({
    this.nullableErrorLists,
    this.enumFields,
    this.customValidate,
    this.customValidateName,
  });

  static const fieldsSerde = {
    'nullableErrorLists': SerdeType.bool,
    'enumFields': SerdeType.bool,
    'customValidate': SerdeType.function,
  };

  @override
  Map<String, Object?> toJson() {
    return {
      'nullableErrorLists': nullableErrorLists,
      'enumFields': enumFields,
      'customValidate': customValidateName,
    };
  }

  factory Valida.fromJson(Map<String, Object?> map) {
    return Valida(
      nullableErrorLists: map['nullableErrorLists'] as bool?,
      enumFields: map['enumFields'] as bool?,
      customValidateName: map['customValidate'] as String?,
    );
  }
}

/// A function with this annotation will be executed in the validation process
class ValidaFunction {
  /// A function with this annotation will be executed in the validation process
  const ValidaFunction();
}

/// Annotation for specifying de validation for a nested field. A nested field
/// is of a class that has [Valida] annotation.
class ValidaNested<T> extends ValidaField<T> {
  /// Whether to omit the validation for this field
  final bool? omit;

  /// A function that executes the validation.
  /// By default, the generated function will be used
  final Validation Function(T value)? overrideValidation;

  /// The name of the function used for validation. This value should not
  /// be used directly, since it is used for code generation
  final String? overrideValidationName;

  @override
  final List<ValidaError> Function(T)? customValidate;

  @override
  final String? customValidateName;

  /// Annotation for specifying de validation for a nested field. A nested field
  /// is of a class that has [Valida] annotation.
  const ValidaNested({
    this.omit,
    this.overrideValidation,
    this.overrideValidationName,
    this.customValidate,
    this.customValidateName,
  });

  static const fieldsSerde = {
    'omit': SerdeType.bool,
    'customValidate': SerdeType.function,
    'overrideValidation': SerdeType.function,
  };

  @override
  Map<String, Object?> toJson() {
    return {
      ValidaField.variantTypeString: variantType.toString(),
      'omit': omit,
      'customValidate': customValidateName,
      'overrideValidation': overrideValidationName,
    };
  }

  factory ValidaNested.fromJson(Map<String, Object?> json) {
    return ValidaNested(
      omit: json['omit'] as bool?,
      customValidateName: json['customValidate'] as String?,
      overrideValidationName: json['overrideValidation'] as String?,
    );
  }

  @override
  List<ValidaError> validate(
    String property,
    Object? Function(String property) getter,
  ) {
    final List<ValidaError> errors = [];
    final value = getter(property) as T?;
    if (omit == true || value == null) return errors;

    if (overrideValidation != null) {
      final error = overrideValidation!(value).toError(property: property);
      if (error != null) errors.add(error);
    }
    if (customValidate != null) errors.addAll(customValidate!(value));

    return errors;
  }

  @override
  ValidaFieldType get variantType => ValidaFieldType.nested;
}

/// The type of value being validated
enum ValidaFieldType {
  num,
  string,
  date,
  duration,
  list,
  map,
  set,
  nested,
}

ValidaFieldType parseValidaFieldType(String raw) {
  for (final v in ValidaFieldType.values) {
    if (v.name == raw || v.toString() == raw) {
      return v;
    }
  }
  throw Error();
}

/// Interface for validators which accept a custom function
abstract class ValidaCustom<T> {
  /// The function used to perform an additional custom validation
  List<ValidaError> Function(T)? get customValidate;

  /// The name of the function used for validation.
  /// This value should not be used directly,
  /// since it is used for code generation
  String? get customValidateName;
}

/// A result of a comparison
enum ComparisonResult {
  /// When the comparison was successful
  success,

  /// When the comparison had an error
  error,

  /// When the value was less than the other
  less,

  /// When the value was more than the other
  more,

  /// When the value was equal to the other
  equal;

  /// Returns the result parsed from and integer.
  /// =0 equal, <0 less and >0 more.
  static ComparisonResult fromInt(int value) {
    return value == 0
        ? equal
        : value > 0
            ? more
            : less;
  }
}

/// Interface for validators which are comparable
abstract class ValidaComparable<T extends Comparable<T>> {
  /// The comparison validation specification
  ValidaComparison<T>? get comp;
}

/// The comparison for validators which are comparable
class ValidaComparison<T extends Comparable<T>> with ToJson {
  /// Whether to use [Comparable.compare] or `<` and `>`.
  final bool useCompareTo;

  /// The validated value should be more than what [more] represents
  final CompVal<T>? more;

  /// The validated value should be less than what [less] represents
  final CompVal<T>? less;

  /// The validated value should be more than or equal
  /// to what [moreEq] represents
  final CompVal<T>? moreEq;

  /// The validated value should be less than or equal
  /// to what [lessEq] represents
  final CompVal<T>? lessEq;

  /// The comparison for validators which are comparable
  const ValidaComparison({
    this.more,
    this.less,
    this.moreEq,
    this.lessEq,
    bool? useCompareTo,
  }) : useCompareTo = useCompareTo ?? true;

  static const fieldsSerde = SerdeType.nested({
    'more': CompVal.fieldsSerde,
    'less': CompVal.fieldsSerde,
    'moreEq': CompVal.fieldsSerde,
    'lessEq': CompVal.fieldsSerde,
    'useCompareTo': SerdeType.bool,
  });

  /// Performs the comparison validation for [property] in the object
  /// whose fields can be accessed with [getter] using [_compare]
  Iterable<ValidaError> validate(
    String property,
    ComparisonResult Function(T) _compare,
    T? Function(String) getter,
  ) sync* {
    final value = getter(property);
    ComparisonResult _compareCompVal(CompVal<T> compVal) {
      return compVal.when(
        ref: (ref, isRequired) {
          final toCompare = getter(ref);
          if (toCompare == null) {
            return isRequired
                ? ComparisonResult.error
                : ComparisonResult.success;
          }
          return _compare(toCompare);
        },
        single: _compare,
        list: (list) {
          bool less = false;
          bool more = false;
          bool eq = false;
          bool error = false;
          bool allSuccess = true;
          final skipped = list.map(_compareCompVal).any((element) {
            allSuccess = allSuccess && element == ComparisonResult.success;
            if (element != ComparisonResult.error) {
              less = less || element == ComparisonResult.less;
              more = more || element == ComparisonResult.more;
              eq = eq || element == ComparisonResult.equal;
            } else {
              error = true;
            }
            return error || (less && more || less && eq || more && eq);
          });
          if (skipped) return ComparisonResult.error;
          if (eq) return ComparisonResult.equal;
          if (less) return ComparisonResult.less;
          if (more) return ComparisonResult.more;
          if (allSuccess) return ComparisonResult.success;
          return ComparisonResult.error;
        },
      );
    }

    if (less != null &&
        !const [ComparisonResult.success, ComparisonResult.less]
            .contains(_compareCompVal(less!))) {
      yield ValidaError(
        property: property,
        value: value,
        errorCode: 'ValidaComparison.less',
        message: 'Should be less than ${less}',
      );
    }
    if (lessEq != null &&
        !const [
          ComparisonResult.success,
          ComparisonResult.less,
          ComparisonResult.equal,
        ].contains(_compareCompVal(lessEq!))) {
      yield ValidaError(
        property: property,
        value: value,
        errorCode: 'ValidaComparison.lessEq',
        message: 'Should be less than or equal to ${lessEq}',
      );
    }
    if (more != null &&
        !const [ComparisonResult.success, ComparisonResult.more]
            .contains(_compareCompVal(more!))) {
      yield ValidaError(
        property: property,
        value: value,
        errorCode: 'ValidaComparison.more',
        message: 'Should be more than ${more}',
      );
    }
    if (moreEq != null &&
        !const [
          ComparisonResult.success,
          ComparisonResult.more,
          ComparisonResult.equal,
        ].contains(_compareCompVal(moreEq!))) {
      yield ValidaError(
        property: property,
        value: value,
        errorCode: 'ValidaComparison.moreEq',
        message: 'Should be more than or equal to ${moreEq}',
      );
    }
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'more': more?.toJson(),
      'less': less?.toJson(),
      'moreEq': moreEq?.toJson(),
      'lessEq': lessEq?.toJson(),
      'useCompareTo': useCompareTo,
    };
  }

  factory ValidaComparison.fromJson(Map<String, Object?> map) {
    return ValidaComparison<T>(
      more: map['more'] == null ? null : CompVal.fromJson<T>(map['more']),
      less: map['less'] == null ? null : CompVal.fromJson<T>(map['less']),
      moreEq: map['moreEq'] == null ? null : CompVal.fromJson<T>(map['moreEq']),
      lessEq: map['lessEq'] == null ? null : CompVal.fromJson<T>(map['lessEq']),
      useCompareTo: map['useCompareTo'] as bool?,
    );
  }
}

/// Interface for validators which are fields of a class
abstract class ValidaField<T> with ToJson implements ValidaCustom<T> {
  /// Interface for validators which are fields of a class
  const ValidaField();

  /// Returns a [Map] with a JSON representation of
  /// this validation specification
  @override
  Map<String, Object?> toJson();

  /// Executes validation of [property] for the object whose fields can
  /// be accessed with [getter].
  List<ValidaError> validate(
    String property,
    Object? Function(String property) getter,
  );

  /// Executes validation of [value] with [name]
  /// for the object whose fields can be accessed with [getter].
  List<ValidaError> validateValue(
    T value, {
    required String name,
    Object? Function(String property)? getter,
  }) {
    return validate(
      name,
      (p) {
        if (p == name) return value;
        if (getter == null) throw Exception();
        return getter(p);
      },
    );
  }

  /// The type of value that this field validation specification validations.
  ///
  /// Used for code generation
  ValidaFieldType get variantType;

  static const variantTypeString = 'variantType';

  static const fieldsSerde = SerdeType.late(_makeFieldsSerde);
  static SerdeType _makeFieldsSerde() {
    return const SerdeType.union(
      ValidaField.variantTypeString,
      {
        'num': SerdeType.nested(ValidaNum.fieldsSerde),
        'string': SerdeType.nested(ValidaString.fieldsSerde),
        'date': SerdeType.nested(ValidaDate.fieldsSerde),
        'duration': SerdeType.nested(ValidaDuration.fieldsSerde),
        'list': SerdeType.nested(ValidaList.fieldsSerde),
        'set': SerdeType.nested(ValidaSet.fieldsSerde),
        'map': SerdeType.nested(ValidaMap.fieldsSerde),
        'nested': SerdeType.nested(ValidaNested.fieldsSerde),
      },
    );
  }

  _T when<_T>({
    required _T Function(ValidaString) string,
    required _T Function(ValidaNum) num,
    required _T Function(ValidaDate) date,
    required _T Function(ValidaDuration) duration,
    required _T Function(ValidaList) list,
    required _T Function(ValidaMap) map,
    required _T Function(ValidaSet) set,
    required _T Function(ValidaNested) nested,
  }) {
    switch (variantType) {
      case ValidaFieldType.string:
        return string(this as ValidaString);
      case ValidaFieldType.num:
        return num(this as ValidaNum);
      case ValidaFieldType.date:
        return date(this as ValidaDate);
      case ValidaFieldType.duration:
        return duration(this as ValidaDuration);
      case ValidaFieldType.list:
        return list(this as ValidaList);
      case ValidaFieldType.map:
        return map(this as ValidaMap);
      case ValidaFieldType.set:
        return set(this as ValidaSet);
      case ValidaFieldType.nested:
        return nested(this as ValidaNested);
    }
  }

  static ValidaField<Object?> fromJson(Map<String, Object?> map) {
    final type = parseValidaFieldType(
      (map[ValidaField.variantTypeString] ?? map['runtimeType'] ?? map['type'])!
          as String,
    );
    switch (type) {
      case ValidaFieldType.string:
        return ValidaString.fromJson(map);
      case ValidaFieldType.num:
        return ValidaNum.fromJson(map);
      case ValidaFieldType.date:
        return ValidaDate.fromJson(map);
      case ValidaFieldType.duration:
        return ValidaDuration.fromJson(map);
      case ValidaFieldType.list:
        return ValidaList<Object?>.fromJson(map);
      case ValidaFieldType.map:
        return ValidaMap<Object?, Object?>.fromJson(map);
      case ValidaFieldType.set:
        return ValidaSet<Object?>.fromJson(map);
      case ValidaFieldType.nested:
        return ValidaNested<Object?>.fromJson(map);
    }
  }
}

/// Specification of the validation that should be
/// executed over a given [num]
class ValidaNum extends ValidaField<num> implements ValidaComparable<num> {
  /// Should be within the array
  final List<num>? isIn;

  /// Should be at a minimum this number
  final num? min;

  /// Should be at a maximum this number
  final num? max;

  /// Should be an integer
  final bool? isInt;

  /// Should be divisible by the given number
  final num? isDivisibleBy;

  @override
  final ValidaComparison<num>? comp;

  @override
  ValidaFieldType get variantType => ValidaFieldType.num;

  @override
  final List<ValidaError> Function(num)? customValidate;
  @override
  final String? customValidateName;

  /// Specification of the validation that should be
  /// executed over a given [num]
  const ValidaNum({
    this.isIn,
    this.min,
    this.max,
    this.isInt,
    this.isDivisibleBy,
    this.customValidate,
    this.customValidateName,
    this.comp,
  });

  static const fieldsSerde = {
    'min': SerdeType.num,
    'max': SerdeType.num,
    'isInt': SerdeType.bool,
    'isIn': SerdeType.list(SerdeType.num),
    'isDivisibleBy': SerdeType.num,
    'customValidate': SerdeType.function,
    'comp': ValidaComparison.fieldsSerde,
  };

  @override
  Map<String, Object?> toJson() {
    return {
      ValidaField.variantTypeString: variantType.toString(),
      'isIn': isIn,
      'min': min,
      'max': max,
      'isInt': isInt,
      'isDivisibleBy': isDivisibleBy,
      'customValidate': customValidateName,
      'comp': comp?.toJson(),
    };
  }

  factory ValidaNum.fromJson(Map<String, Object?> map) {
    return ValidaNum(
      isIn: map['isIn'] == null ? null : List<num>.from(map['isIn']! as List),
      min: map['min'] as int?,
      max: map['max'] as int?,
      isInt: map['isInt'] as bool?,
      isDivisibleBy: map['isDivisibleBy'] as int?,
      customValidateName: map['customValidate'] as String?,
      comp: map['comp'] == null
          ? null
          : ValidaComparison.fromJson(map['comp']! as Map<String, Object?>),
    );
  }

  @override
  List<ValidaError> validate(
    String property,
    Object? Function(String property) getter,
  ) {
    final List<ValidaError> errors = [];
    final value = getter(property) as num?;
    if (value == null) return errors;

    final _addError = addErrorFunc(property, value, errors);

    if (isIn != null && !isIn!.contains(value)) {
      _addError(
        errorCode: 'ValidaNum.isIn',
        message: 'Should be any of $isIn',
        validationParam: isIn,
      );
    }
    if (isInt == true && value.round() != value) {
      _addError(
        errorCode: 'ValidaNum.isInt',
        message: 'Should be an integer',
        validationParam: null,
      );
    }
    final _comp = comp;
    if (_comp != null) {
      ComparisonResult _compare(num single) {
        return _comp.useCompareTo
            ? ComparisonResult.fromInt(value.compareTo(single))
            : (value < single
                ? ComparisonResult.less
                : value == single
                    ? ComparisonResult.equal
                    : ComparisonResult.more);
      }

      errors.addAll(
        _comp.validate(property, _compare, (p) => getter(p)! as num),
      );
    }
    if (min != null && value < min!) {
      _addError(
        errorCode: 'ValidaNum.min',
        message: 'Should be at a minimum ${min}',
        validationParam: min,
      );
    }
    if (max != null && value > max!) {
      _addError(
        errorCode: 'ValidaNum.max',
        message: 'Should be at a maximum ${max}',
        validationParam: max,
      );
    }
    if (isDivisibleBy != null && value.remainder(isDivisibleBy!) == 0) {
      _addError(
        errorCode: 'ValidaNum.isDivisibleBy',
        message: 'Should be divisible by ${isDivisibleBy}',
        validationParam: isDivisibleBy,
      );
    }
    if (customValidate != null) {
      errors.addAll(customValidate!(value));
    }

    return errors;
  }
}

/// Specification of the validation that should be
/// executed over a given [Duration]
class ValidaDuration extends ValidaField<Duration>
    implements ValidaComparable<Duration> {
  final Duration? min;
  final Duration? max;

  @override
  ValidaFieldType get variantType => ValidaFieldType.duration;

  @override
  final List<ValidaError> Function(Duration)? customValidate;
  @override
  final String? customValidateName;

  @override
  final ValidaComparison<Duration>? comp;

  /// Specification of the validation that should be
  /// executed over a given [Duration]
  const ValidaDuration({
    this.min,
    this.max,
    this.customValidate,
    this.customValidateName,
    this.comp,
  });

  static const fieldsSerde = {
    'min': SerdeType.duration,
    'max': SerdeType.duration,
    'customValidate': SerdeType.function,
    'comp': ValidaComparison.fieldsSerde,
  };

  @override
  Map<String, Object?> toJson() {
    return {
      ValidaField.variantTypeString: variantType.toString(),
      'min': min?.inMicroseconds,
      'max': max?.inMicroseconds,
      'customValidate': customValidateName,
      'comp': comp?.toJson(),
    };
  }

  factory ValidaDuration.fromJson(Map<String, Object?> map) {
    return ValidaDuration(
      min: map['min'] == null
          ? null
          : Duration(microseconds: map['min']! as int),
      max: map['max'] == null
          ? null
          : Duration(microseconds: map['max']! as int),
      customValidateName: map['customValidate'] as String?,
      comp: map['comp'] == null
          ? null
          : ValidaComparison.fromJson(map['comp']! as Map<String, Object?>),
    );
  }

  @override
  List<ValidaError> validate(
    String property,
    Object? Function(String property) getter,
  ) {
    final List<ValidaError> errors = [];
    final value = getter(property) as Duration?;
    if (value == null) return errors;

    final _addError = addErrorFunc(property, value, errors);

    final _comp = comp;
    if (_comp != null) {
      ComparisonResult _compare(Duration single) {
        return _comp.useCompareTo
            ? ComparisonResult.fromInt(value.compareTo(single))
            : (value < single
                ? ComparisonResult.less
                : value == single
                    ? ComparisonResult.equal
                    : ComparisonResult.more);
      }

      errors.addAll(
        _comp.validate(property, _compare, (p) => getter(p)! as Duration),
      );
    }
    if (min != null && value < min!) {
      _addError(
        errorCode: 'ValidaDuration.min',
        message: 'Should be at a minimum ${min}',
        validationParam: min,
      );
    }
    if (max != null && value > max!) {
      _addError(
        errorCode: 'ValidaDuration.max',
        message: 'Should be at a maximum ${max}',
        validationParam: max,
      );
    }
    if (customValidate != null) {
      errors.addAll(customValidate!(value));
    }

    return errors;
  }
}

/// Specification of the validation that should be
/// executed over a given [DateTime]
class ValidaDate extends ValidaField<DateTime>
    implements ValidaComparable<String> {
  /// The minimum date the validated value should be
  final String? min;

  /// The maximum date the validated value should be
  final String? max;

  @override
  ValidaFieldType get variantType => ValidaFieldType.date;

  @override
  final List<ValidaError> Function(DateTime)? customValidate;
  @override
  final String? customValidateName;

  @override
  final ValidaComparison<String>? comp;

  /// Specification of the validation that should be
  /// executed over a given [DateTime]
  const ValidaDate({
    this.min,
    this.max,
    this.customValidate,
    this.customValidateName,
    this.comp,
  });

  static const fieldsSerde = {
    'min': SerdeType.str,
    'max': SerdeType.str,
    'customValidate': SerdeType.function,
    'comp': ValidaComparison.fieldsSerde,
  };

  @override
  Map<String, Object?> toJson() {
    return {
      ValidaField.variantTypeString: variantType.toString(),
      'min': min,
      'max': max,
      'customValidate': customValidateName,
      'comp': comp?.toJson(),
    };
  }

  factory ValidaDate.fromJson(Map<String, Object?> map) {
    return ValidaDate(
      min: map['min'] as String?,
      max: map['max'] as String?,
      customValidateName: map['customValidate'] as String?,
      comp: map['comp'] == null
          ? null
          : ValidaComparison.fromJson(map['comp']! as Map<String, Object?>),
    );
  }

  /// Parses a Date using [DateTime.parse] and custom predefined Strings.
  /// Such as "now" for `DateTime.now()`
  static DateTime parseDate(String value) {
    return value == 'now' ? DateTime.now() : DateTime.parse(value);
  }

  @override
  List<ValidaError> validate(
    String property,
    Object? Function(String property) getter,
  ) {
    final List<ValidaError> errors = [];
    final value = getter(property) as DateTime?;
    if (value == null) return errors;

    final _addError = addErrorFunc(property, value, errors);

    final _comp = comp;
    if (_comp != null) {
      ComparisonResult _compare(String _single) {
        final single = ValidaDate.parseDate(_single);
        return _comp.useCompareTo
            ? ComparisonResult.fromInt(value.compareTo(single))
            : (value.isBefore(single)
                ? ComparisonResult.less
                : value.isAtSameMomentAs(single)
                    ? ComparisonResult.equal
                    : ComparisonResult.more);
      }

      errors.addAll(
        _comp.validate(property, _compare, (p) {
          final v = getter(p);
          return v is String ? v : (v! as DateTime).toString();
        }),
      );
    }
    if (min != null && value.isBefore(ValidaDate.parseDate(min!))) {
      _addError(
        errorCode: 'ValidaDate.min',
        message: 'Should be at a minimum ${min}',
        validationParam: min,
      );
    }
    if (max != null && value.isAfter(ValidaDate.parseDate(max!))) {
      _addError(
        errorCode: 'ValidaDate.max',
        message: 'Should be at a maximum ${max}',
        validationParam: max,
      );
    }
    if (customValidate != null) {
      errors.addAll(customValidate!(value));
    }

    return errors;
  }
}

// TODO: make private

void Function({
  required String errorCode,
  required String message,
  required Object? validationParam,
}) addErrorFunc(
  String property,
  Object value,
  List<ValidaError> errors,
) {
  void _addError({
    required String errorCode,
    required String message,
    required Object? validationParam,
  }) {
    errors.add(
      ValidaError(
        property: property,
        value: value,
        errorCode: errorCode,
        message: message,
        validationParam: validationParam,
      ),
    );
  }

  return _addError;
}

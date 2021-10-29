import 'package:valida/serde_type.dart';
import 'package:valida/validate/validate.dart';
import 'package:valida/validate/validate_collections.dart';
import 'package:valida/validate/validate_string.dart';
import 'models/comp_val.dart';

export 'models/comp_val.dart';
export 'validate_collections.dart';
export 'validate_string.dart';

class Valida implements ValidaCustom<Object?> {
  final bool nullableErrorLists;
  final bool constErrors;
  final bool enumFields;

  @override
  final List<ValidaError> Function(Object?)? customValidate;
  @override
  final String? customValidateName;

  const Valida({
    bool? nullableErrorLists,
    bool? constErrors,
    bool? enumFields,
    this.customValidate,
    this.customValidateName,
  })  : nullableErrorLists = nullableErrorLists ?? false,
        constErrors = constErrors ?? false,
        enumFields = enumFields ?? true;

  static const fieldsSerde = {
    'nullableErrorLists': SerdeType.bool,
    'constErrors': SerdeType.bool,
    'enumFields': SerdeType.bool,
    'customValidate': SerdeType.function,
  };

  Map<String, Object?> toJson() {
    return {
      'nullableErrorLists': nullableErrorLists,
      'constErrors': constErrors,
      'enumFields': enumFields,
      'customValidate': customValidateName,
    };
  }

  factory Valida.fromJson(Map<String, Object?> map) {
    return Valida(
      nullableErrorLists: map['nullableErrorLists'] as bool?,
      constErrors: map['constErrors'] as bool?,
      enumFields: map['enumFields'] as bool?,
      customValidateName: map['customValidate'] as String?,
    );
  }
}

class ValidaFunction {
  const ValidaFunction();
}

enum ValidaFieldType {
  num,
  string,
  date,
  duration,
  list,
  map,
  set,
}

ValidaFieldType parseValidaFieldType(String raw) {
  for (final v in ValidaFieldType.values) {
    final str = v.toString();
    if (str == raw || str.split('.')[1] == raw) {
      return v;
    }
  }
  throw Error();
}

abstract class ValidaCustom<T> {
  List<ValidaError> Function(T)? get customValidate;
  String? get customValidateName;
}

abstract class ValidaComparable<T extends Comparable<T>> {
  ValidaComparison<T>? get comp;
}

class ValidaComparison<T extends Comparable<T>> {
  final bool useCompareTo;
  final CompVal<T>? more;
  final CompVal<T>? less;
  final CompVal<T>? moreEq;
  final CompVal<T>? lessEq;

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

// abstract class CompVal<T extends Comparable> {
//   const CompVal._();

//   const factory CompVal(T value) = CompValSingle;
//   const factory CompVal.ref(String ref) = CompValRef;
//   const factory CompVal.single(T value) = CompValSingle;
//   const factory CompVal.many(List<CompVal<T>> value) = CompValMany;

//   static const fieldsSerde = SerdeType.late(_makeFieldsSerde);
//   static SerdeType _makeFieldsSerde() {
//     return SerdeType.union(
//       'discriminator',
//       {},
//     );
//   }
// }

// class CompValRef<T extends Comparable> extends CompVal<T> {
//   final String ref;

//   const CompValRef(this.ref) : super._();
// }

// class CompValSingle<T extends Comparable> extends CompVal<T> {
//   final T value;

//   const CompValSingle(this.value) : super._();
// }

// class CompValMany<T extends Comparable> extends CompVal<T> {
//   final List<CompVal<T>> values;

//   const CompValMany(this.values) : super._();
// }

abstract class ValidaField<T> implements ValidaCustom<T> {
  const ValidaField();

  Map<String, Object?> toJson();

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
    }
  }
}

class ValidaNum extends ValidaField<num> implements ValidaComparable<num> {
  final List<num>? isIn; // enum
  final num? min;
  final num? max;
  final bool? isInt;
  final num? isDivisibleBy;
  @override
  final ValidaComparison<num>? comp;

  @override
  ValidaFieldType get variantType => ValidaFieldType.num;

  @override
  final List<ValidaError> Function(num)? customValidate;
  @override
  final String? customValidateName;

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
}

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
}

class ValidaDate extends ValidaField<DateTime>
    implements ValidaComparable<String> {
  final String? min;
  final String? max;

  @override
  ValidaFieldType get variantType => ValidaFieldType.date;

  @override
  final List<ValidaError> Function(DateTime)? customValidate;
  @override
  final String? customValidateName;

  @override
  final ValidaComparison<String>? comp;

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
}

import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:valida/serde_type.dart';

import 'package:valida/src/models/to_json_mixin.dart';

/// A value in a comparison
///
/// [CompVal.ref] is a reference to another field
/// [CompVal.list] accept multiple values in the comparison
@immutable
abstract class CompVal<T extends Comparable<T>> with ValidaToJson {
  const CompVal._();

  static const fieldsSerde = SerdeType.late(_makeFieldsSerde);
  static SerdeType _makeFieldsSerde() {
    return const SerdeType.union(
      'variantType',
      {
        'ref': SerdeType.nested(CompValueRef.fieldsSerde),
        'single': SerdeType.nested(CompValueSingle.fieldsSerde),
        'list': SerdeType.nested(CompValueList.fieldsSerde),
      },
    );
  }

  /// The [value] will be used to compare
  // ignore: sort_unnamed_constructors_first
  const factory CompVal(T value) = CompValueSingle<T>;

  /// The [ref] is the name of the field whose value will be compared
  const factory CompVal.ref(
    String ref, {
    bool isRequired,
  }) = CompValueRef<T>;

  /// A single value will be compared. Same as `CompVal(value)`.
  const factory CompVal.single(
    T value,
  ) = CompValueSingle<T>;

  /// A list of values will be compared
  const factory CompVal.list(
    List<CompVal<T>> values,
  ) = CompValueList<T>;

  _T when<_T>({
    required _T Function(String ref, bool isRequired) ref,
    required _T Function(T value) single,
    required _T Function(List<CompVal<T>> values) list,
  }) {
    final v = this;
    if (v is CompValueRef<T>) {
      return ref(v.ref, v.isRequired);
    } else if (v is CompValueSingle<T>) {
      return single(v.value);
    } else if (v is CompValueList<T>) {
      return list(v.values);
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(String ref, bool isRequired)? ref,
    _T Function(T value)? single,
    _T Function(List<CompVal<T>> values)? list,
  }) {
    final v = this;
    if (v is CompValueRef<T>) {
      return ref != null ? ref(v.ref, v.isRequired) : orElse.call();
    } else if (v is CompValueSingle<T>) {
      return single != null ? single(v.value) : orElse.call();
    } else if (v is CompValueList<T>) {
      return list != null ? list(v.values) : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(CompValueRef<T> value) ref,
    required _T Function(CompValueSingle<T> value) single,
    required _T Function(CompValueList<T> value) list,
  }) {
    final v = this;
    if (v is CompValueRef<T>) {
      return ref(v);
    } else if (v is CompValueSingle<T>) {
      return single(v);
    } else if (v is CompValueList<T>) {
      return list(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(CompValueRef<T> value)? ref,
    _T Function(CompValueSingle<T> value)? single,
    _T Function(CompValueList<T> value)? list,
  }) {
    final v = this;
    if (v is CompValueRef<T>) {
      return ref != null ? ref(v) : orElse.call();
    } else if (v is CompValueSingle<T>) {
      return single != null ? single(v) : orElse.call();
    } else if (v is CompValueList<T>) {
      return list != null ? list(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isRef => this is CompValueRef;
  bool get isSingle => this is CompValueSingle;
  bool get isList => this is CompValueList;

  /// The type of CompValue that this is
  TypeCompVal get variantType;

  factory CompVal.fromJson(Object? _map) {
    final Map<String, Object?> map;
    if (_map is CompVal<T>) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, Object?>;
    } else {
      map = (_map! as Map).cast();
    }

    switch (map['variantType']) {
      case 'ref':
        return CompValueRef.fromJson(map);
      case 'single':
        return CompValueSingle.fromJson(map);
      case 'list':
        return CompValueList.fromJson(map);
      default:
        throw Exception('Invalid discriminator for '
            'CompVal<T extends Comparable<T>>.fromJson '
            '${map["variantType"]}. Input map: $map');
    }
  }

  @override
  Map<String, Object?> toJson();
}

/// A type of CompVal.
/// Possible values [TypeCompVal.ref], [TypeCompVal.single]
/// and [TypeCompVal.list].
@immutable
class TypeCompVal {
  final String _inner;

  const TypeCompVal._(this._inner);

  static const ref = TypeCompVal._('ref');
  static const single = TypeCompVal._('single');
  static const list = TypeCompVal._('list');

  static const values = [
    TypeCompVal.ref,
    TypeCompVal.single,
    TypeCompVal.list,
  ];

  factory TypeCompVal.fromJson(Object? json) {
    if (json == null) {
      throw Error();
    }
    for (final v in values) {
      if (json.toString() == v._inner) {
        return v;
      }
    }
    throw Error();
  }

  String toJson() {
    return _inner;
  }

  @override
  String toString() {
    return _inner;
  }

  @override
  bool operator ==(Object other) {
    return other is TypeCompVal &&
        other.runtimeType == runtimeType &&
        other._inner == _inner;
  }

  @override
  int get hashCode => _inner.hashCode;

  bool get isRef => this == TypeCompVal.ref;
  bool get isSingle => this == TypeCompVal.single;
  bool get isList => this == TypeCompVal.list;

  _T when<_T>({
    required _T Function() ref,
    required _T Function() single,
    required _T Function() list,
  }) {
    switch (this._inner) {
      case 'ref':
        return ref();
      case 'single':
        return single();
      case 'list':
        return list();
    }
    throw Error();
  }

  _T maybeWhen<_T>({
    _T Function()? ref,
    _T Function()? single,
    _T Function()? list,
    required _T Function() orElse,
  }) {
    _T Function()? c;
    switch (this._inner) {
      case 'ref':
        c = ref;
        break;
      case 'single':
        c = single;
        break;
      case 'list':
        c = list;
        break;
    }
    return (c ?? orElse).call();
  }
}

class CompValueRef<T extends Comparable<T>> extends CompVal<T> {
  final String ref;
  final bool isRequired;

  const CompValueRef(
    this.ref, {
    this.isRequired = true,
  }) : super._();

  @override
  // ignore: avoid_field_initializers_in_const_classes
  final TypeCompVal variantType = TypeCompVal.ref;

  factory CompValueRef.fromJson(Object? _map) {
    final Map<String, Object?> map;
    if (_map is CompValueRef<T>) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, Object?>;
    } else {
      map = (_map! as Map).cast();
    }

    return CompValueRef<T>(
      map['ref']! as String,
      isRequired: map['isRequired']! as bool,
    );
  }

  @override
  String toString() {
    return '$ref${isRequired ? '!' : ''}';
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'variantType': 'ref',
      'ref': ref,
      'isRequired': isRequired,
    };
  }

  static const fieldsSerde = {
    'ref': SerdeType.str,
    'isRequired': SerdeType.bool,
  };
}

class CompValueSingle<T extends Comparable<T>> extends CompVal<T> {
  final T value;

  const CompValueSingle(
    this.value,
  ) : super._();

  @override
  // ignore: avoid_field_initializers_in_const_classes
  final TypeCompVal variantType = TypeCompVal.single;

  @override
  String toString() {
    return '$value';
  }

  factory CompValueSingle.fromJson(Object? _map) {
    final Map<String, Object?> map;
    if (_map is CompValueSingle<T>) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, Object?>;
    } else {
      map = (_map! as Map).cast();
    }
    final value = map['value']!;
    final T v;
    if (value is T) {
      v = value;
    } else if (T == Duration) {
      v = Duration(microseconds: value as int) as T;
    } else if (T == DateTime) {
      v = DateTime.parse(value as String) as T;
    } else if (T == BigInt) {
      v = BigInt.parse(value as String) as T;
    } else {
      throw Exception('CompValueSingle$T.fromJson($map) invalid input.');
    }

    return CompValueSingle<T>(v);
  }

  @override
  Map<String, Object?> toJson() {
    Object v = value;
    if (v is Duration) {
      v = v.inMicroseconds;
    } else if (v is DateTime) {
      v = v.toIso8601String();
    } else if (v is BigInt) {
      v = v.toString();
    }
    return {
      'variantType': 'single',
      'value': v,
    };
  }

  static const fieldsSerde = {
    'value': SerdeType.dynamic,
  };
}

class CompValueList<T extends Comparable<T>> extends CompVal<T> {
  final List<CompVal<T>> values;

  const CompValueList(
    this.values,
  ) : super._();

  @override
  // ignore: avoid_field_initializers_in_const_classes
  final TypeCompVal variantType = TypeCompVal.list;

  @override
  String toString() {
    return '[${values.join(' , ')}]';
  }

  factory CompValueList.fromJson(Object? _map) {
    final Map<String, Object?> map;
    if (_map is CompValueList<T>) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, Object?>;
    } else {
      map = (_map! as Map).cast();
    }

    return CompValueList<T>(
      (map['values']! as List)
          .map((Object? e) => CompVal<T>.fromJson(e))
          .toList()
          .cast(),
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'variantType': 'list',
      'values': values.map((e) => e.toJson()).toList(),
    };
  }

  static const fieldsSerde = {
    'values': SerdeType.list(CompVal.fieldsSerde),
  };
}

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// Serialization and deserialization utility type for constant values
///
/// Useful primarily for code generators which need to access annotation
/// values in the build process.
@immutable
class SerdeType {
  final String _inner;
  const SerdeType._(this._inner);

  static const bool = SerdeType._('bool');
  static const int = SerdeType._('int');
  static const num = SerdeType._('num');
  static const function = SerdeType._('Function');
  static const str = SerdeType._('String');
  static const dynamic = SerdeType._('dynamic');
  static const duration = SerdeType._('Duration');
  const factory SerdeType.option(SerdeType generic) = SerdeTypeOption._;
  const factory SerdeType.list(SerdeType generic) = SerdeTypeList._;
  const factory SerdeType.set(SerdeType generic) = SerdeTypeSet._;
  const factory SerdeType.map(
    SerdeType genericKey,
    SerdeType genericValue,
  ) = SerdeTypeMap._;
  const factory SerdeType.nested(Map<String, SerdeType> props) =
      SerdeTypeNested._;
  const factory SerdeType.union(
    String discriminator,
    Map<String, SerdeType> variants,
  ) = SerdeTypeUnion._;
  const factory SerdeType.unionType(
    Set<SerdeType> variants,
  ) = SerdeTypeUnionType._;
  const factory SerdeType.enumV(List<Object?> values) =
      SerdeTypeEnum<Object?>._;
  const factory SerdeType.late(SerdeType Function() func) = SerdeTypeLate._;

  T when<T>({
    required T Function() bool,
    required T Function() int,
    required T Function() num,
    required T Function() str,
    required T Function(SerdeTypeOption) option,
    required T Function() duration,
    required T Function(SerdeTypeList) list,
    required T Function(SerdeTypeSet) set,
    required T Function(SerdeTypeMap) map,
    required T Function() function,
    required T Function(SerdeTypeNested) nested,
    required T Function(SerdeTypeUnion) union,
    required T Function(SerdeTypeUnionType) unionType,
    required T Function(SerdeTypeEnum<Object?>) enumV,
    required T Function() dynamic,
    required T Function(SerdeTypeLate) late,
  }) {
    switch (_inner) {
      case 'bool':
        return bool();
      case 'int':
        return int();
      case 'num':
        return num();
      case 'String':
        return str();
      case 'Duration':
        return duration();
      case 'Function':
        return function();
      case 'List':
        return list(this as SerdeTypeList);
      case 'Set':
        return set(this as SerdeTypeSet);
      case 'Map':
        return map(this as SerdeTypeMap);
      case 'Nested':
        return nested(this as SerdeTypeNested);
      case 'Union':
        return union(this as SerdeTypeUnion);
      case 'UnionType':
        return unionType(this as SerdeTypeUnionType);
      case 'enum':
        return enumV(this as SerdeTypeEnum);
      case 'dynamic':
        return dynamic();
      case 'Late':
        return late(this as SerdeTypeLate);
      case 'Option':
        return option(this as SerdeTypeOption);
      default:
        throw Exception('SerdeType._inner $_inner not found in when');
    }
  }

  T whenMaybe<T>({
    T Function()? bool,
    T Function()? int,
    T Function()? num,
    T Function()? str,
    T Function(SerdeTypeOption)? option,
    T Function()? duration,
    T Function(SerdeTypeList)? list,
    T Function(SerdeTypeSet)? set,
    T Function(SerdeTypeMap)? map,
    T Function()? function,
    T Function(SerdeTypeNested)? nested,
    T Function(SerdeTypeUnion)? union,
    T Function(SerdeTypeUnionType)? unionType,
    T Function(SerdeTypeEnum<Object?>)? enumV,
    T Function()? dynamic,
    T Function(SerdeTypeLate)? late,
    required T Function() orElse,
  }) {
    T orElseParam(Object _) => orElse();

    return when(
      bool: bool ?? orElse,
      int: int ?? orElse,
      num: num ?? orElse,
      str: str ?? orElse,
      option: option ?? orElseParam,
      duration: duration ?? orElse,
      list: list ?? orElseParam,
      set: set ?? orElseParam,
      map: map ?? orElseParam,
      function: function ?? orElse,
      nested: nested ?? orElseParam,
      union: union ?? orElseParam,
      unionType: unionType ?? orElseParam,
      enumV: enumV ?? orElseParam,
      dynamic: dynamic ?? orElse,
      late: late ?? orElseParam,
    );
  }

  @override
  String toString() {
    return 'SerdeType(inner: $_inner)';
  }

  String get inner => _inner;
}

class SerdeTypeList extends SerdeType {
  final SerdeType generic;
  const SerdeTypeList._(this.generic) : super._('List');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SerdeTypeList && other.generic == generic;
  }

  @override
  int get hashCode => generic.hashCode;

  @override
  String toString() => 'SerdeTypeList(generic: $generic)';
}

class SerdeTypeOption extends SerdeType {
  final SerdeType generic;
  const SerdeTypeOption._(this.generic) : super._('Option');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SerdeTypeOption && other.generic == generic;
  }

  @override
  int get hashCode => generic.hashCode;

  @override
  String toString() => 'SerdeTypeOption(generic: $generic)';
}

class SerdeTypeSet extends SerdeType {
  final SerdeType generic;
  const SerdeTypeSet._(this.generic) : super._('Set');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SerdeTypeSet && other.generic == generic;
  }

  @override
  int get hashCode => generic.hashCode;

  @override
  String toString() => 'SerdeTypeSet(generic: $generic)';
}

class SerdeTypeMap extends SerdeType {
  final SerdeType genericKey;
  final SerdeType genericValue;
  const SerdeTypeMap._(this.genericKey, this.genericValue) : super._('Map');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SerdeTypeMap &&
        other.genericKey == genericKey &&
        other.genericValue == genericValue;
  }

  @override
  int get hashCode => genericKey.hashCode ^ genericValue.hashCode;

  @override
  String toString() =>
      'SerdeTypeMap(genericKey: $genericKey, genericValue: $genericValue)';
}

class SerdeTypeNested extends SerdeType {
  final Map<String, SerdeType> props;
  const SerdeTypeNested._(this.props) : super._('Nested');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return other is SerdeTypeNested && mapEquals(other.props, props);
  }

  @override
  int get hashCode => const DeepCollectionEquality().hash(props);

  @override
  String toString() => 'SerdeTypeNested(props: $props)';
}

class SerdeTypeUnion extends SerdeType {
  final String discriminator;
  final Map<String, SerdeType> variants;
  const SerdeTypeUnion._(this.discriminator, this.variants) : super._('Union');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return other is SerdeTypeUnion &&
        other.discriminator == discriminator &&
        mapEquals(other.variants, variants);
  }

  @override
  int get hashCode =>
      discriminator.hashCode ^ const DeepCollectionEquality().hash(variants);

  @override
  String toString() =>
      'SerdeTypeUnion(discriminator: $discriminator, variants: $variants)';
}

class SerdeTypeUnionType extends SerdeType {
  final Set<SerdeType> variants;
  const SerdeTypeUnionType._(this.variants) : super._('UnionType');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return other is SerdeTypeUnionType && mapEquals(other.variants, variants);
  }

  @override
  int get hashCode => const DeepCollectionEquality().hash(variants);

  @override
  String toString() => 'SerdeTypeUnionType(variants: $variants)';
}

class TypeMatcher<T> {
  bool matches(Object? value) => value is T;
}

class SerdeTypeLate extends SerdeType {
  final SerdeType Function() func;
  const SerdeTypeLate._(this.func) : super._('Late');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SerdeTypeLate && other.func == func;
  }

  @override
  int get hashCode => func.hashCode;

  @override
  String toString() => 'SerdeTypeLate(func: $func)';
}

class SerdeTypeEnum<T> extends SerdeType {
  final List<T> values;
  const SerdeTypeEnum._(this.values) : super._('enum');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is SerdeTypeEnum<T> && listEquals(other.values, values);
  }

  @override
  int get hashCode => const DeepCollectionEquality().hash(values);

  @override
  String toString() => 'SerdeTypeEnum(values: $values)';
}

// ignore_for_file: require_trailing_commas

import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/visitor.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:valida/serde_type.dart';
import 'package:valida/valida.dart';

import 'package:valida_generator/src/generator_utils.dart';

class ValidatorGenerator extends GeneratorForAnnotation<Valida<Object?>> {
  final BuilderOptions options;

  ValidatorGenerator(this.options);

  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final globalNullableErrorLists =
        (options.config['nullableErrorLists'] as bool?) ?? false;
    final globalEnumFields = (options.config['enumFields'] as bool?) ?? true;
    final genericValidator = _getGenericValidator(element);
    try {
      final ModelVisitor visitor;
      if (element is FunctionElement) {
        visitor = ModelVisitor(
          getFunctionArgsClassName(element),
          element.typeParameters,
          genericValidator,
        );
        final funcVisitor = FunctionVisitor(visitor);
        element.visitChildren(funcVisitor);
      } else {
        if (element is! ClassElement) {
          throw 'Annotated element for Valida should be a function or class.'
              ' Got $element.';
        }
        visitor = ModelVisitor(
          element.name,
          element.typeParameters,
          genericValidator,
        );
        element.visitChildren(visitor);
        final _visited = <Element>{element};
        InterfaceElement? elem = element;
        while (elem?.supertype != null) {
          final currentElem = elem!.supertype!.element;
          if (_visited.contains(currentElem)) {
            elem = null;
            continue;
          }
          _visited.add(currentElem);
          currentElem.visitChildren(visitor);
          elem = currentElem;
        }
      }

      final annotationValue = annotation.objectValue.extractValue(
        Valida.fieldsSerde,
        (p0) => Valida<dynamic>.fromJson(p0),
      );
      final nullableErrorLists =
          annotationValue.nullableErrorLists ?? globalNullableErrorLists;
      final enumFields = annotationValue.enumFields ?? globalEnumFields;
      final hasGlobalFunctionValidators =
          visitor.validateFunctions.isNotEmpty ||
              annotationValue.customValidateName != null;
      String className = visitor.className;
      final generics = _typeList(visitor.typeParamList, ext: false);
      final genericsBound = _typeList(visitor.typeParamList, ext: true);
      final _index = className.indexOf('<');
      className = _index == -1 ? className : className.substring(0, _index);

      final fieldTypeName = enumFields ? '${className}Field' : 'String';
      String _fieldIdent(String fieldName) {
        return enumFields ? '$fieldTypeName.$fieldName' : "'$fieldName'";
      }

      final output = '''
${element is FunctionElement ? generateArgsClass(className, element) : ''}
${enumFields ? '''
enum $fieldTypeName {
  ${visitor.fields.entries.map((e) {
              return '${e.key},';
            }).join()}
  ${visitor.fieldsWithValidate.map((e) => '${e.element.name},').join()}
  ${hasGlobalFunctionValidators ? _globalFieldIdentifier() : ''}
}''' : ''}


class ${className}ValidationFields {
  const ${className}ValidationFields(this.errorsMap);
  final Map<$fieldTypeName, List<ValidaError>> errorsMap;

  ${visitor.fieldsWithValidate.map((_e) {
        final e = _e.element;
        final typeNameAndGenerics = _getTypeNameAndGenerics(e);
        final retType =
            '${typeNameAndGenerics.typeName}Validation${typeNameAndGenerics.generics}?';
        return '$retType get ${e.name} {'
            ' final l = errorsMap[${_fieldIdent(e.name)}];'
            ' return (l != null && l.isNotEmpty) ? l.first.nestedValidation as $retType : null;}';
      }).join()}
  ${visitor.fields.entries.map((e) => e.key).followedBy([
            if (hasGlobalFunctionValidators) _globalFieldIdentifier()
          ]).map((key) {
        return 'List<ValidaError>${nullableErrorLists ? '?' : ''} get ${key} '
            '=> errorsMap[${_fieldIdent(key)}]${nullableErrorLists ? '' : ' ?? const []'};';
      }).join()}
}

class ${className}Validation$genericsBound extends Validation<${className}$generics, $fieldTypeName> {
  ${className}Validation(this.errorsMap, this.value)
    : fields = ${className}ValidationFields(errorsMap), super(errorsMap);
  @override
  final Map<$fieldTypeName, List<ValidaError>> errorsMap;
  @override
  final ${className}$generics value;
  @override
  final ${className}ValidationFields fields;

  /// Validates [value] and returns a [${className}Validation] with the errors found as a result
  factory ${className}Validation.fromValue(${className}$generics value) =>
    ${generics.isEmpty ? 'spec' : 'spec$generics()'}.validate(value);

  static ${generics.isEmpty ? 'const spec =' : 'ValidaSpec<${className}Validation$generics, ${className}$generics, $fieldTypeName> spec$genericsBound() =>'} 
  ValidaSpec(
    globalValidate: ${hasGlobalFunctionValidators ? 'GlobalValidateFunc(function: _globalValidate, field: ${_fieldIdent(_globalFieldIdentifier())},)' : 'null'},
    validationFactory: ${className}Validation.new,
    getField: _getField,
    fieldsMap: {
      ${visitor.fieldsWithValidate.map(
        (_e) {
          final e = _e.element;
          return "${_fieldIdent(e.name)}: ${_validaNested(e)},";
        },
      ).join()}
    ${visitor.fields.entries.map(
        (e) {
          final value = e.value;
          if (e.value.nestedAnnotation != null) {
            return "${_fieldIdent(e.key)}: ${e.value.nestedAnnotation},";
          }
          final annot = value.element.element.metadata.firstWhere(
            (element) => const TypeChecker.fromRuntime(ValidaField)
                .isAssignableFromType(element.computeConstantValue()!.type!),
          );
          return "${_fieldIdent(e.key)}: ${getSourceCodeAnnotation(annot)},";
        },
      ).join()}
    },
  );

  static List<ValidaError> _globalValidate$genericsBound($className$generics value) 
    => ${_globalFunctionValidation(annotationValue, visitor.validateFunctions)};

  static Object? _getField$genericsBound(${className}$generics value, String field) {
    switch (field) {
      ${visitor.allFieldNames.map(
        (key) {
          return "case '$key': return value.$key;";
        },
      ).join()}
      default:
        throw Exception('Could not find field "\$field" for value \$value.');
    }
  }
}
''';
      // print(output);
      return output;
    } catch (e, s) {
      return 'const error = """$e\n$s""";';
    }
  }
}

TypeNameAndGenerics _getTypeNameAndGenerics(FieldDescription e) {
  String typeName = e.type.getDisplayString(withNullability: false);
  final index = typeName.indexOf('<');
  String gen = '';
  if (index != -1) {
    gen = typeName.substring(index);
    typeName = typeName.substring(0, index);
  }
  return TypeNameAndGenerics(generics: gen, typeName: typeName);
}

class TypeNameAndGenerics {
  final String typeName;
  final String generics;

  TypeNameAndGenerics({
    required this.typeName,
    required this.generics,
  });
}

String _typeList(List<TypeParameterElement> typeParams, {bool ext = false}) {
  return typeParams.isNotEmpty
      ? '<${typeParams.map((e) {
          final _e = ext && e.bound != null
              ? ' extends ${e.bound!.getDisplayString(withNullability: true)}'
              : '';

          return '${e.displayName}$_e';
        }).join(',')}>'
      : '';
}

String _globalFunctionValidation(
  Valida<Object?> annotationValue,
  Set<MethodElement> validateFunctions,
) {
  return '''
[${validateFunctions.map((e) {
    return e.isStatic
        ? '...${e.enclosingElement.name}.${e.name}(value),'
        : '...value.${e.name}(),';
  }).join()}
  ${annotationValue.customValidateName == null ? '' : '...${annotationValue.customValidateName}(value),'}
]''';
}

String _globalFieldIdentifier() => '\$global';

String getSourceCodeAnnotation(ElementAnnotation e) {
  final s = e as ElementAnnotationImpl;
  return s.annotationAst.toString().substring(1);
}

int _orderForParameter(ParameterElement a) {
  if (a.isRequiredPositional) return 0;
  if (a.isOptionalPositional) return 1;
  if (a.isRequiredNamed) return 2;
  return 3;
}

String generateArgsClass(
  String className,
  FunctionElement element,
) {
  final params = [...element.parameters]
    ..sort((a, b) => _orderForParameter(a) - _orderForParameter(b));

  int namedArgs = 0;
  int optionalPositionArgs = 0;
  return '''
/// The arguments for [${element.name}].
class $className with ValidaToJson {
  ${params.map((e) {
    return '${e.documentationComment == null ? '' : '/// ${e.documentationComment}\n'}'
        'final ${e.type.getDisplayString(withNullability: true)} ${e.name};';
  }).join()}

  /// The arguments for [${element.name}].
  const $className(
    ${params.map((e) {
    if (e.isNamed) namedArgs++;
    if (e.isOptionalPositional) optionalPositionArgs++;
    return '${namedArgs == 1 ? '{' : optionalPositionArgs == 1 ? '[' : ''}'
        ' ${e.isRequiredNamed ? 'required' : ''} this.${e.name} '
        ' ${e.defaultValueCode == null ? '' : '= ${e.defaultValueCode}'},';
  }).join()}
  ${namedArgs > 0 ? '}' : ''}
  ${optionalPositionArgs > 0 ? ']' : ''}
  );

  /// Validates this arguments for [${element.name}].
  ${className}Validation validate() => ${className}Validation.fromValue(this);


  /// Validates this arguments for [${element.name}] and
  /// returns the successfully [Validated] value or
  /// throws a [${className}Validation] when there is an error.
  Validated<${className}> validatedOrThrow() {
    final validation = validate();
    final validated = validation.validated;
    if (validated == null) {
      throw validation;
    }
    return validated;
  }

  @override
  Map<String, Object?> toJson() => {
    ${params.map((e) => "'${e.name}': ${e.name},").join()}
  };

  @override
  String toString() => '${className}\${toJson()}';

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ${className} &&
            ${params.map((e) => '${e.name} == other.${e.name}').join(' && ')});
  }

  @override
  int get hashCode => ${params.length <= 19 ? 'Object.hash(runtimeType,' : 'Object.hashAll([runtimeType,'}
    ${params.map((e) => e.name).join(',')}
    ${params.length <= 19 ? ',)' : ',])'};
}
''';
}

class FunctionVisitor extends SimpleElementVisitor<void> {
  FunctionVisitor(this.modelVisitor);
  final ModelVisitor modelVisitor;

  @override
  void visitParameterElement(ParameterElement element) {
    modelVisitor.visitFieldOrArgElement(FieldDescription(
      element: element,
      type: element.type,
      name: element.name,
    ));
    super.visitParameterElement(element);
  }
}

bool _isAssignable(Type type, Element element) =>
    TypeChecker.fromRuntime(type).isAssignableFrom(element);

String _getCleanCollectionType(DartType e) {
  String gen = '';
  if (e is InterfaceType && e.typeArguments.isNotEmpty) {
    gen = '<${e.typeArguments.map(_getCleanCollectionType).join(',')}>';
  }
  if (_isAssignable(List, e.element!)) return 'List$gen';
  if (_isAssignable(Map, e.element!)) return 'Map$gen';
  if (_isAssignable(Set, e.element!)) return 'Set$gen';
  return e.getDisplayString(withNullability: false);
}

String? _getGenericValidator(Element element) {
  final annotConstString = getSourceCodeAnnotation(element.metadata.firstWhere(
    (element) => const TypeChecker.fromRuntime(Valida)
        .isAssignableFromType(element.computeConstantValue()!.type!),
  ));
  final genericValidator = const TypeChecker.fromRuntime(Valida)
          .firstAnnotationOfExact(element)!
          .getField('genericValidator')
          ?.serde(SerdeType.function) as String? ??
      (annotConstString.contains(
              RegExp(r'genericValidator[\s]*:[\s]*Validators.instance'))
          ? 'Validators.instance'
          : null);
  return genericValidator;
}

String _validaNested(FieldDescription e) {
  final annot = const TypeChecker.fromRuntime(ValidaNested)
      .firstAnnotationOfExact(e.element);
  final _annot = annot?.extractValue(
        ValidaNested.fieldsSerde,
        (map) => ValidaNested<dynamic>.fromJson(map),
      ) ??
      const ValidaNested<dynamic>();
  final typeName = e.type.getDisplayString(withNullability: false);

  final typeNameAndGenerics = _getTypeNameAndGenerics(e);
  final _funcName = _annot.overrideValidationName ??
      '${typeNameAndGenerics.typeName}Validation.fromValue';

  return 'ValidaNested<${typeName}> '
      '(omit: ${_annot.omit}, '
      'customValidate: ${_annot.customValidateName}, '
      'overrideValidation: $_funcName,)';
}

class ModelVisitor extends SimpleElementVisitor<void> {
  ModelVisitor(
    this.className,
    this.typeParamList,
    this.genericValidator,
  );

  final String className;
  final List<TypeParameterElement> typeParamList;
  final String? genericValidator;

  late final Map<String, TypeParameterElement> typeParamMap = Map.fromIterables(
    typeParamList.map((e) => e.name),
    typeParamList,
  );

  final allFieldNames = <String>{};
  final fields = <String, _Field>{};
  final validateFunctions = <MethodElement>{};
  final fieldsWithValidate = <_Field>{};

  static const _listAnnotation = TypeChecker.fromRuntime(ValidaList);
  static const _stringAnnotation = TypeChecker.fromRuntime(ValidaString);
  static const _numAnnotation = TypeChecker.fromRuntime(ValidaNum);
  static const _dateAnnotation = TypeChecker.fromRuntime(ValidaDate);
  static const _functionAnnotation = TypeChecker.fromRuntime(ValidaFunction);

  @override
  void visitMethodElement(MethodElement element) {
    if (_functionAnnotation.hasAnnotationOfExact(element)) {
      validateFunctions.add(element);
    }
    super.visitMethodElement(element);
  }

  @override
  dynamic visitFieldElement(FieldElement element) {
    visitFieldOrArgElement(FieldDescription(
      element: element,
      type: element.type,
      name: element.name,
    ));
    return super.visitFieldElement(element);
  }

  dynamic visitFieldOrArgElement(FieldDescription prop) {
    allFieldNames.add(prop.name);

    void _addFields({
      required TypeChecker annotation,
      required Map<String, SerdeType> fieldsSerde,
      required ValidaField<Object?> Function(Map<String, Object?> map) fromJson,
    }) {
      if (annotation.hasAnnotationOfExact(prop.element)) {
        fields[prop.name] = _Field(prop);
      }
    }

    String? nestedValida(String? wrapper, DartType type) {
      final elem = type.element!;
      final hasValidaAnnotation = const TypeChecker.fromRuntime(Valida)
          .annotationsOfExact(elem)
          .toList()
          .isNotEmpty;
      if (hasValidaAnnotation && wrapper == null) {
        fieldsWithValidate.add(_Field(prop));
        return null;
      }

      final typeName = type.getDisplayString(withNullability: false);
      final isGeneric = typeParamMap[typeName] != null;

      final isList = _isAssignable(List, elem);
      final isSet = _isAssignable(Set, elem);
      final isMap = _isAssignable(Map, elem);
      if (isGeneric) {
        if (genericValidator == null) {
          throw 'Valida.genericValidator is required for'
              ' generic types annotated with @Valida.'
              ' You can use the generated "Validators.instance".';
        }
        // TODO: other params
        return '${wrapper ?? ''} ValidaNested<$typeName>(overrideValidation: ${genericValidator}().validate)';
      } else if (hasValidaAnnotation) {
        return '${wrapper} ValidaNested(overrideValidation: ${elem.name}Validation.fromValue)';
      } else if (type is InterfaceType && (isList || isSet || isMap)) {
        final typeParameters = type.typeArguments;
        String generics = '';
        if (type.getDisplayString(withNullability: false).contains('<')) {
          generics =
              '<${typeParameters.map(_getCleanCollectionType).join(',')}>';
        }
        final _wrapper = wrapper ?? '';

        // TODO: make sure the generics really map into dart core types
        if (typeParameters.length == 2 && isMap) {
          final key = nestedValida('eachKey:', typeParameters.first);
          final value = nestedValida('eachValue:', typeParameters.last);
          if (key != null || value != null) {
            final inner = [key, value].where((e) => e != null).join(',');
            return '$_wrapper ValidaMap$generics($inner)';
          }
        } else if (typeParameters.length == 1 && (isList || isSet)) {
          final inner = nestedValida('each:', typeParameters.first);
          if (inner != null) {
            return '$_wrapper Valida${isSet ? 'Set' : 'List'}$generics($inner)';
          }
        }
      }
      return null;
    }

    final elementType = prop.type.element;
    if (elementType != null) {
      final collectionNestedAnnotation = nestedValida(null, prop.type);
      if (collectionNestedAnnotation != null) {
        fields[prop.name] = _Field(
          prop,
          nestedAnnotation: collectionNestedAnnotation,
        );
      }
    }

    // Primitives
    _addFields(
      annotation: _stringAnnotation,
      fieldsSerde: ValidaString.fieldsSerde,
      fromJson: (map) => ValidaString.fromJson(map),
    );
    _addFields(
      annotation: _numAnnotation,
      fieldsSerde: ValidaNum.fieldsSerde,
      fromJson: (map) => ValidaNum.fromJson(map),
    );
    // Date and Duration
    _addFields(
      annotation: _dateAnnotation,
      fieldsSerde: ValidaDate.fieldsSerde,
      fromJson: (map) => ValidaDate.fromJson(map),
    );
    _addFields(
      annotation: const TypeChecker.fromRuntime(ValidaDuration),
      fieldsSerde: ValidaDuration.fieldsSerde,
      fromJson: (map) => ValidaDuration.fromJson(map),
    );
    // Collections
    _addFields(
      annotation: _listAnnotation,
      fieldsSerde: ValidaList.fieldsSerde,
      fromJson: (map) => ValidaList<Object?>.fromJson(map),
    );
    _addFields(
      annotation: const TypeChecker.fromRuntime(ValidaSet),
      fieldsSerde: ValidaSet.fieldsSerde,
      fromJson: (map) => ValidaSet<Object?>.fromJson(map),
    );
    _addFields(
      annotation: const TypeChecker.fromRuntime(ValidaMap),
      fieldsSerde: ValidaMap.fieldsSerde,
      fromJson: (map) => ValidaMap<Object?, Object?>.fromJson(map),
    );
  }
}

class FieldDescription {
  final Element element;
  final DartType type;
  final String name;

  const FieldDescription({
    required this.element,
    required this.type,
    required this.name,
  });
}

///
extension ConsumeSerdeType on DartObject {
  T extractValue<T>(
    Map<String, SerdeType> fields,
    T Function(Map<String, Object?>) fromJson,
  ) {
    final jsonMap = fields.map((key, value) {
      final field = this.getField(key);
      if (field == null) {
        return MapEntry(key, null);
      }
      final _value = field.serde(value);
      return MapEntry(key, _value);
    });
    return fromJson(jsonMap);
  }

  Object? serde(SerdeType serde) {
    final _value = serde.when<Object?>(
      bool: () => this.toBoolValue(),
      str: () => this.toStringValue(),
      num: () => this.toDoubleValue() ?? this.toIntValue(),
      int: () => this.toIntValue(),
      function: () {
        final f = this.toFunctionValue();
        if (f == null) {
          return null;
        }
        final enclosing = f.declaration.enclosingElement.name;
        return '${enclosing == null ? '' : '$enclosing.'}${f.name}';
      },
      duration: () => this.getField('_duration')?.toIntValue(),
      option: (inner) => this.serde(inner),
      list: (list) =>
          this.toListValue()?.map((e) => e.serde(list.generic)).toList(),
      set: (set) =>
          this.toListValue()?.map((e) => e.serde(set.generic)).toSet(),
      map: (map) => this.toMapValue()?.map(
            (key, value) => MapEntry(
              key?.serde(map.genericKey),
              value?.serde(map.genericValue),
            ),
          ),
      enumV: (enumV) {
        final enumIndex = this.getField('index')?.toIntValue();
        return enumIndex == null ? null : enumV.values[enumIndex];
      },
      nested: (nested) {
        return nested.props.map(
          (key, value) => MapEntry(key, this.getField(key)?.serde(value)),
        );
      },
      union: (union) {
        final eValue = this.getField(union.discriminator);
        final t = eValue?.type;

        final String? discriminator;
        if (t?.element.runtimeType == EnumElementImpl) {
          final index = eValue?.getField('index')?.toIntValue();
          final v = (t!.element! as EnumElementImpl).fields[index! + 2];
          discriminator = v.name;
        } else {
          discriminator = eValue?.toStringValue() ??
              eValue?.getField('_inner')?.toStringValue();
        }

        final variant = union.variants[discriminator];
        if (variant == null) {
          return null;
        }
        final result = this.serde(variant);
        if (result is Map && !result.containsKey(union.discriminator)) {
          result[union.discriminator] = discriminator;
        }
        return result;
      },
      unionType: (union) {
        return null;
      },
      late: (l) {
        return this.serde(l.func());
      },
      dynamic: () {
        final v = this.toBoolValue() ??
            this.toIntValue() ??
            this.toDoubleValue() ??
            this.toStringValue() ??
            this.toListValue() ??
            this.toSetValue() ??
            this.toMapValue();
        if (v == null) {
          final durMicro = this.getField('_duration')?.toIntValue();
          return durMicro == null ? null : Duration(microseconds: durMicro);
        }
        return v;
      },
    );
    return _value;
  }
}

class _Field {
  const _Field(
    this.element, {
    this.nestedAnnotation,
  });
  final FieldDescription element;
  final String? nestedAnnotation;
}

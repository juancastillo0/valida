// ignore_for_file: require_trailing_commas

import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/visitor.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:valida/serde_type.dart';
import 'package:valida/valida.dart';

class ValidatorGenerator extends GeneratorForAnnotation<Valida> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    try {
      final ModelVisitor visitor;
      if (element is FunctionElement) {
        final funcVisitor = FunctionVisitor();
        element.visitChildren(funcVisitor);
        visitor = funcVisitor.modelVisitor;

        final firstIndex = element.name.replaceFirstMapped(
            RegExp('[a-zA-Z0-9]'),
            (match) =>
                match.input.substring(match.start, match.end).toUpperCase());
        visitor.className = '${firstIndex}Args';
      } else {
        visitor = ModelVisitor();
        element.visitChildren(visitor);
        final _visited = <Element>{element};
        ClassElement? elem = element is ClassElement ? element : null;
        while (elem?.supertype != null) {
          final currelem = elem!.supertype!.element;
          if (_visited.contains(currelem)) {
            elem = null;
            continue;
          }
          _visited.add(currelem);
          currelem.visitChildren(visitor);
          elem = currelem;
        }
      }

      final annotationValue = annotation.objectValue.extractValue(
        Valida.fieldsSerde,
        (p0) => Valida.fromJson(p0),
      );
      final nullableErrorLists = annotationValue.nullableErrorLists;
      final hasGlobalFunctionValidators =
          visitor.validateFunctions.isNotEmpty ||
              annotationValue.customValidateName != null;
      final className = visitor.className;

      String _fieldIdent(String fieldName) {
        return '${visitor.className}Field.$fieldName';
      }

      return '''
${element is FunctionElement ? generateArgsClass(className!, element) : ''}
enum ${className}Field {
  ${visitor.fields.entries.map((e) {
        return '${e.key},';
      }).join()}
  ${visitor.fieldsWithValidate.map((e) => '${e.name},').join()}
  ${hasGlobalFunctionValidators ? 'global,' : ''}
}

class ${className}ValidationFields {
  const ${className}ValidationFields(this.errorsMap);
  final Map<${className}Field, List<ValidaError>> errorsMap;

  ${visitor.fieldsWithValidate.map((e) {
        final retType =
            '${e.type.getDisplayString(withNullability: false)}Validation?';
        return '$retType get ${e.name} {'
            ' final l = errorsMap[${_fieldIdent(e.name)}];'
            ' return (l != null && l.isNotEmpty) ? l.first.nestedValidation as $retType : null;}';
      }).join()}
  ${visitor.fields.entries.map((e) {
        return 'List<ValidaError>${nullableErrorLists ? '?' : ''} get ${e.key} '
            '=> errorsMap[${_fieldIdent(e.key)}]${nullableErrorLists ? '' : '!'};';
      }).join()}
}

class ${className}Validation extends Validation<${className}, ${className}Field> {
  ${className}Validation(this.errorsMap, this.value, this.fields) : super(errorsMap);

  final Map<${className}Field, List<ValidaError>> errorsMap;

  final ${className} value;

  final ${className}ValidationFields fields;

  static const validationSpec = {
    ${visitor.fields.entries.map(
        (e) {
          final value = e.value;
          final annot = value.element.element.metadata.firstWhere(
            (element) => const TypeChecker.fromRuntime(ValidaField)
                .isAssignableFromType(element.computeConstantValue()!.type!),
          );
          return "'${e.key}': ${getSouceCodeAnnotation(buildStep, annot)},";
        },
      ).join()}
  };

  static List<ValidaError> globalValidate($className value) => ${_globalFunctionValidation(annotationValue, visitor.validateFunctions)};

  static Object? getField(${className} value, String field) {
    switch (field) {
      ${visitor.fields.entries.map(
        (e) {
          return "case '${e.key}': return value.${e.key};";
        },
      ).join()}
      default:
        throw Exception();
    }
  }
}

${className}Validation ${_functionValidateName(className!)}(${className} value) {
  final errors = <${className}Field, List<ValidaError>>{};

  ${visitor.fieldsWithValidate.map((e) {
        final isNullable =
            e.type.nullabilitySuffix == NullabilitySuffix.question;
        return '''
        final _${e.name}Validation = ${isNullable ? 'value.${e.name} == null ? null : ' : ''}
          validate${e.type.getDisplayString(withNullability: false)}(value.${e.name}!).toError(property: '${e.name}');
        errors[${className}Field.${e.name}] = [if (_${e.name}Validation != null) _${e.name}Validation];
        ''';
      }).join()}
  ${!hasGlobalFunctionValidators ? '' : 'errors[${className}Field.global] = ${_globalFunctionValidation(annotationValue, visitor.validateFunctions)};'}
  ${visitor.fields.entries.map((e) {
        final isNullable = e.value.element.type.nullabilitySuffix ==
            NullabilitySuffix.question;
        final fieldName = '${e.key}${isNullable ? '!' : ''}';
        final getter = 'value.$fieldName';
        final validations = e.value.annotation.validations(
          fieldName: fieldName,
          prefix: 'value.',
        );
        if (validations.isEmpty) {
          return '';
        }
        final _nullable = isNullable
            ? nullableErrorLists
                ? 'if(value.${e.key} != null) '
                : 'if(value.${e.key} == null) errors[${_fieldIdent(e.key)}] = []; else'
            : '';

        String _mapValidationItem(ValidationItem valid) {
          if (valid.iterable != null) {
            return '${valid.iterable} ...[${valid.nested!.map(_mapValidationItem).join(",")}]';
          }
          return 'if (${valid.condition}) ${valid.errorTemplate(e.key, getter)}';
        }

        final _custom = e.value.annotation.customValidateName == null
            ? ''
            : '...${e.value.annotation.customValidateName}($getter),';

        return '${_nullable} errors[${_fieldIdent(e.key)}] = [$_custom${validations.map(_mapValidationItem).join(",")}];';
      }).join()}
  ${nullableErrorLists ? 'errors.removeWhere((k, v) => v.isEmpty);' : ''}

  return ${className}Validation(errors, value, ${className}ValidationFields(errors),);
}
''';
    } catch (e, s) {
      return 'const error = """$e\n$s""";';
    }
  }
}

String _globalFunctionValidation(
  Valida annotationValue,
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

String getSouceCodeAnnotation(BuildStep buildStep, ElementAnnotation e) {
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
class $className {
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
  ${className}Validation validate() => ${_functionValidateName(className)}(this);


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

  /// Returns a Map with all fields
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

String _functionValidateName(String className) {
  return className.startsWith('_')
      ? '_validate${className.substring(1)}'
      : 'validate${className}';
}

class ValidationItem {
  final String defaultMessage;
  final String condition;
  final String errorCode;
  final Object? param;
  final String? iterable;
  final List<ValidationItem>? nested;

  const ValidationItem({
    required this.defaultMessage,
    required this.condition,
    required this.errorCode,
    required this.param,
    this.iterable,
    this.nested,
  });

  String errorTemplate(String fieldName, String getter) {
    // ignore: leading_newlines_in_multiline_strings
    return '''ValidaError(
        message: r'$defaultMessage',
        errorCode: '$errorCode',
        property: '$fieldName',
        validationParam: $param,
        value: $getter,
      )''';
  }
}

class FunctionVisitor extends SimpleElementVisitor<void> {
  final modelVisitor = ModelVisitor();

  @override
  void visitParameterElement(ParameterElement element) {
    element.defaultValueCode;
    modelVisitor.visitFieldOrArgElement(FieldDescription(
      element: element,
      type: element.type,
      name: element.name,
    ));
    super.visitParameterElement(element);
  }
}

class ModelVisitor extends SimpleElementVisitor<void> {
  String? className;
  final fields = <String, _Field>{};
  final validateFunctions = <MethodElement>{};
  final fieldsWithValidate = <FieldDescription>{};

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
  dynamic visitConstructorElement(ConstructorElement element) {
    className ??= element.returnType.toString();
    return super.visitConstructorElement(element);
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
    void _addFields({
      required TypeChecker annotation,
      required Map<String, SerdeType> fieldsSerde,
      required ValidaField Function(Map<String, Object?> map) fromJson,
    }) {
      if (annotation.hasAnnotationOfExact(prop.element)) {
        final annot = annotation.annotationsOfExact(prop.element).first;
        final _annot = annot.extractValue(
          fieldsSerde,
          (map) => fromJson(map),
        );

        fields[prop.name] = _Field(prop, _annot);
      }
    }

    final elementType = prop.type.element;
    if (elementType != null) {
      final fieldType = const TypeChecker.fromRuntime(Valida)
          .annotationsOfExact(elementType, throwOnUnresolved: false)
          .toList();
      if (fieldType.isNotEmpty) {
        fieldsWithValidate.add(prop);
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
  const _Field(this.element, this.annotation);
  final FieldDescription element;
  final ValidaField annotation;
}

///
extension TemplateValidateField on ValidaField {
  List<ValidationItem> validations({
    required String fieldName,
    required String prefix,
  }) {
    final getter = '$prefix$fieldName';
    final validations = <ValidationItem>[];

    this.when(
      string: (v) {
        validations.addAll(stringValidations(v, getter));
      },
      num: (v) {
        if (v.isInt != null && v.isInt == true) {
          validations.add(ValidationItem(
            condition: '$getter.round() != $getter',
            defaultMessage: 'Should be an integer',
            errorCode: 'ValidaNum.isInt',
            param: null,
          ));
        }
        if (v.comp != null) {
          validations.addAll(compValidations(
            v.comp!,
            prefix: prefix,
            fieldName: fieldName,
          ));
        }
        if (v.min != null) {
          validations.add(ValidationItem(
            condition: '$getter < ${v.min}',
            defaultMessage: 'Should be at a minimum ${v.min}',
            errorCode: 'ValidaNum.min',
            param: v.min,
          ));
        }
        if (v.max != null) {
          validations.add(ValidationItem(
            condition: '$getter > ${v.max}',
            defaultMessage: 'Should be at a maximum ${v.max}',
            errorCode: 'ValidaNum.max',
            param: v.max,
          ));
        }
      },
      date: (v) {
        String dateFromStr(String repr) {
          final lowerRepr = repr.toLowerCase();
          if (lowerRepr == 'now') {
            return 'DateTime.now()';
          } else {
            final _p = DateTime.parse(repr);
            return 'DateTime.fromMillisecondsSinceEpoch'
                '(${_p.millisecondsSinceEpoch})';
          }
        }

        if (v.comp != null) {
          validations.addAll(compValidations(
            v.comp!,
            makeString: dateFromStr,
            prefix: prefix,
            fieldName: fieldName,
          ));
        }

        if (v.min != null) {
          final minDate = dateFromStr(v.min!);
          validations.add(ValidationItem(
            condition: '$minDate.isAfter($getter)',
            defaultMessage: 'Should be at a minimum ${v.min}',
            errorCode: 'ValidaDate.min',
            param: '"${v.min}"',
          ));
        }
        if (v.max != null) {
          final maxDate = dateFromStr(v.max!);
          validations.add(ValidationItem(
            condition: '$maxDate.isAfter($getter)',
            defaultMessage: 'Should be at a maximum ${v.max}',
            errorCode: 'ValidaDate.max',
            param: '"${v.max}"',
          ));
        }
      },
      duration: (v) {
        if (v.comp != null) {
          validations.addAll(compValidations<Duration>(
            v.comp!,
            prefix: prefix,
            makeString: (dur) =>
                'Duration(microseconds: ${dur.inMicroseconds})',
            fieldName: fieldName,
          ));
        }
      },
      list: (v) {
        if (v.each != null) {
          validations.add(ValidationItem(
            defaultMessage: '',
            errorCode: '',
            iterable: 'for (final i in Iterable<int>.generate($getter.length))',
            condition: '',
            param: null,
            nested: v.each!.validations(
              fieldName: '$fieldName[i]',
              prefix: prefix,
            ),
          ));
        }
        validations.addAll(lengthValidations(v, getter));
      },
      set: (v) {
        if (v.each != null) {
          validations.add(ValidationItem(
            defaultMessage: '',
            errorCode: '',
            iterable: 'for (final ${fieldName}Item in $getter)',
            condition: '',
            param: null,
            nested: v.each!.validations(
              fieldName: '${fieldName}Item',
              prefix: '',
            ),
          ));
        }
        validations.addAll(lengthValidations(v, getter));
      },
      map: (v) {
        if (v.eachKey != null) {
          validations.add(ValidationItem(
            defaultMessage: '',
            errorCode: '',
            iterable: 'for (final ${fieldName}Key in $getter.keys)',
            condition: '',
            param: null,
            nested: v.eachKey!.validations(
              fieldName: '${fieldName}Key',
              prefix: '',
            ),
          ));
        }
        if (v.eachValue != null) {
          validations.add(ValidationItem(
            defaultMessage: '',
            errorCode: '',
            iterable: 'for (final ${fieldName}Value in $getter.Values)',
            condition: '',
            param: null,
            nested: v.eachValue!.validations(
              fieldName: '${fieldName}Value',
              prefix: '',
            ),
          ));
        }
        validations.addAll(lengthValidations(v, getter));
      },
    );

    return validations;
  }
}

String _defaultMakeString(Object? obj) => obj.toString();

List<ValidationItem> compValidations<T extends Comparable<T>>(
  ValidaComparison<T> comp, {
  required String fieldName,
  required String prefix,
  String Function(T) makeString = _defaultMakeString,
}) {
  String comparison(CompVal<T> c, String operator) {
    return c.when(ref: (ref) {
      return '$prefix$fieldName.compareTo($prefix$ref) $operator';
    }, single: (single) {
      return '$prefix$fieldName.compareTo(${makeString(single)}) $operator';
    }, list: (list) {
      return list.map((v) => comparison(v, operator)).join(' || ');
    });
  }

  return [
    if (comp.less != null)
      ValidationItem(
        condition: comparison(comp.less!, '>= 0'),
        defaultMessage: 'Should be at a minimum ${comp.less}',
        errorCode: 'ValidaComparable.less',
        param: '"${comp.less}"',
      ),
    if (comp.lessEq != null)
      ValidationItem(
        condition: comparison(comp.lessEq!, '> 0'),
        defaultMessage: 'Should be at a less than or equal to ${comp.lessEq}',
        errorCode: 'ValidaComparable.lessEq',
        param: '"${comp.lessEq}"',
      ),
    if (comp.more != null)
      ValidationItem(
        condition: comparison(comp.more!, '<= 0'),
        defaultMessage: 'Should be at a minimum ${comp.more}',
        errorCode: 'ValidaComparable.more',
        param: '"${comp.more}"',
      ),
    if (comp.moreEq != null)
      ValidationItem(
        condition: comparison(comp.moreEq!, '< 0'),
        defaultMessage: 'Should be at a more than or equal to ${comp.moreEq}',
        errorCode: 'ValidaComparable.moreEq',
        param: '"${comp.moreEq}"',
      ),
  ];
}

List<ValidationItem> lengthValidations(ValidaLength v, String getter) {
  return [
    if (v.minLength != null)
      ValidationItem(
        condition: '$getter.length < ${v.minLength}',
        defaultMessage: 'Should be at a minimum ${v.minLength} in length',
        errorCode: 'ValidaList.minLength',
        param: v.minLength,
      ),
    if (v.maxLength != null)
      ValidationItem(
        condition: '$getter.length > ${v.maxLength}',
        defaultMessage: 'Should be at a maximum ${v.maxLength} in length',
        errorCode: 'ValidaList.maxLength',
        param: v.maxLength,
      ),
  ];
}

List<ValidationItem> stringValidations(ValidaString v, String getter) {
  final validations = <ValidationItem>[];
  if (v.minLength != null) {
    validations.add(ValidationItem(
      condition: '$getter.length < ${v.minLength}',
      defaultMessage: 'Should be at a minimum ${v.minLength} in length',
      errorCode: 'ValidaString.minLength',
      param: v.minLength,
    ));
  }
  if (v.maxLength != null) {
    validations.add(ValidationItem(
      condition: '$getter.length > ${v.maxLength}',
      defaultMessage: 'Should be at a maximum ${v.maxLength} in length',
      errorCode: 'ValidaString.maxLength',
      param: v.maxLength,
    ));
  }
  if (v.isUppercase != null && v.isUppercase == true) {
    validations.add(ValidationItem(
      condition: '$getter.toUpperCase() != $getter',
      defaultMessage: 'Should be uppercase',
      errorCode: 'ValidaString.isUppercase',
      param: null,
    ));
  }
  if (v.isLowercase != null && v.isLowercase == true) {
    validations.add(ValidationItem(
      condition: '$getter.toLowerCase() != $getter',
      defaultMessage: 'Should be lowercase',
      errorCode: 'ValidaString.isLowercase',
      param: null,
    ));
  }
  if (v.isNum != null && v.isNum == true) {
    validations.add(ValidationItem(
      condition: 'double.tryParse($getter) == null',
      defaultMessage: 'Should be a number',
      errorCode: 'ValidaString.isNum',
      param: null,
    ));
  }
  if (v.isBool != null && v.isBool == true) {
    validations.add(ValidationItem(
      condition: '$getter != "true" && $getter != "false"',
      defaultMessage: 'Should be a "true" or "false"',
      errorCode: 'ValidaString.isBool',
      param: null,
    ));
  }
  if (v.contains != null) {
    validations.add(ValidationItem(
      condition: '!$getter.contains(r"${v.contains}")',
      defaultMessage: 'Should contain ${v.contains}',
      errorCode: 'ValidaString.contains',
      param: "r'${v.contains}'",
    ));
  }
  if (v.matches != null) {
    validations.add(ValidationItem(
      condition: '!RegExp(r"${v.matches}").hasMatch($getter)',
      defaultMessage: 'Should match ${v.matches}',
      errorCode: 'ValidaString.matches',
      param: 'RegExp(r"${v.matches}")',
    ));
  }
  return validations;
}

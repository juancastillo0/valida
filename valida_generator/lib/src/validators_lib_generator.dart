import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:valida/valida.dart';
import 'package:valida_generator/src/generator_utils.dart';

class ValidatorsLibGenerator implements Builder {
  final BuilderOptions options;

  ValidatorsLibGenerator(this.options);

  @override
  Map<String, List<String>> get buildExtensions {
    return const {
      r'$lib$': ['all_validators.dart']
    };
  }

  static AssetId _allFileOutput(BuildStep buildStep) {
    return AssetId(
      buildStep.inputId.package,
      p.join('lib', 'all_validators.dart'),
    );
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    final allElements = <Element>[];

    await for (final input in buildStep.findAssets(Glob('lib/**.dart'))) {
      try {
        final library = await buildStep.resolver.libraryFor(input);
        final classesInLibrary = LibraryReader(library).classes;
        final functionsInLibrary =
            LibraryReader(library).allElements.whereType<FunctionElement>();

        allElements.addAll(
          classesInLibrary.where(
            (element) => const TypeChecker.fromRuntime(Valida)
                .hasAnnotationOfExact(element),
          ),
        );
        allElements.addAll(
          functionsInLibrary.where(
            (element) => const TypeChecker.fromRuntime(Valida)
                .hasAnnotationOfExact(element),
          ),
        );
      } catch (_) {}
    }
    allElements.removeWhere((e) => _name(e).startsWith('_'));

    try {
      // final outputAsset =
      //     AssetId(buildStep.inputId.package, 'lib/global.validations.dart');

      String out = '''
import 'package:valida/valida.dart';
${allElements.map((e) => "import '${e.source!.uri}';").toSet().join()}

/// A validator with all the validators
/// found in code generation.
class Validators with GenericValidator {
  Validators._() {
    for (final v in <Validator>[
      ${allElements.map((e) {
        return 'validator${_name(e)},';
      }).join()}
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

  ${allElements.map((e) {
        return 'static const validator${_name(e)} = Validator(${_name(e)}Validation.fromValue);';
      }).join()}
}
''';
      try {
        out = DartFormatter().format(out);
      } catch (_) {}

      await buildStep.writeAsString(_allFileOutput(buildStep), out);
    } catch (e, s) {
      print('$e $s');
    }
  }
}

String _name(Element e) {
  if (e is FunctionElement) {
    return getFunctionArgsClassName(e);
  }
  return e.name!;
}

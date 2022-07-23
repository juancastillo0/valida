library valida_generator;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:valida_generator/src/validator_generator.dart';
import 'package:valida_generator/src/validators_lib_generator.dart';

/// Returns a Builder that generates the validation logic for each class
Builder validatorGen(BuilderOptions options) =>
    SharedPartBuilder([ValidatorGenerator(options)], 'validator_gen');

/// Returns a Builder that generates the file that centralizes all
/// validators in the project
Builder validatorsLibGen(BuilderOptions options) =>
    ValidatorsLibGenerator(options);

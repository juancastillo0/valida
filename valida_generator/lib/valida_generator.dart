library valida_generator;

import 'package:build/build.dart';
import 'package:valida_generator/src/validator_generator.dart';
import 'package:valida_generator/src/validators_lib_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder validatorGen(BuilderOptions options) =>
    SharedPartBuilder([ValidatorGenerator()], 'validator_gen');

Builder validatorsLibGen(BuilderOptions options) =>
    ValidatorsLibGenerator(options);

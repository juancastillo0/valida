import 'package:analyzer/dart/element/element.dart';

String getFunctionArgsClassName(FunctionElement functionElement) {
  final mapped = functionElement.name.replaceFirstMapped(
    RegExp('[a-zA-Z0-9]'),
    (match) => match.input.substring(match.start, match.end).toUpperCase(),
  );
  return '${mapped}Args';
}

import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:indent/indent.dart';

class Formatter {
  Formatter._();
  static String formatAndStringify({
    required Spec spec,
  }) {
    final emitter = DartEmitter(
      allocator: Allocator.simplePrefixing(),
      useNullSafetySyntax: true,
    );

    final formattedStr = DartFormatter()
        .format(
          "${spec.accept(emitter)}",
        )
        .unindent();

    return formattedStr;
  }
}

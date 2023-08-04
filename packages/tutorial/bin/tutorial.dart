// 🎯 Dart imports:
// ignore: unused_import
import 'dart:convert';
import 'dart:io';

// 📦 Package imports:
import 'package:args/args.dart';
import 'package:code_builder/code_builder.dart';
// ignore: unused_import
import 'package:tint/tint.dart';
import 'package:tutorial/build.dart';
// ignore: unused_import
import 'package:yaml/yaml.dart';

const configName = 'game_tutorial.yaml';

/// *********** CONSOLE ARGUMENTS *********
const help = 'help';
const debug = 'debug';

/// *********** YAML CONFIG NAMES **************
/// The path to the all tutorial json files
const configJsonDataPath = 'json_data_path';

/// The path to the all tutorial json files
const defaultJsonDataPath = 'lib/data/tutorial/';

/// The property wich has a name of class and property
/// For example: [CampaignTutorialActions.welcome].
/// This would generate a class [CampaignTutorialActions]
/// and property [welcome] will have all properties for example
/// [title] or [description]. If [title] will have args to replace
/// it will be converted to function with args
const configPropertyWithClassName = 'property_with_class_name';
const defaultPropertyWithClassName = 'enumAction';

const defaultClassNamePostfix = 'Steps';

Future<void> main(List<String> args) async {
  /// presume success
  exitCode = 0;

  /// ******** CONSOLE ARGUMENTS PARSING ********
  final parser = ArgParser();
  parser.addFlag(help, abbr: 'h');
  parser.addFlag(debug, abbr: 'd');
  final argResults = parser.parse(args);
  final bool isDebugging = argResults[debug] as bool? ?? false;
  void stDebug(String message) {
    if (isDebugging) stdout.writeln("[DEBUG] $message");
  }

  void stInfo(String message) => stdout.writeln("[INFO] $message");

  /// ******** CONFIG PARAMS PARSING ********
  final currentPath = '${Directory.current.path}/';
  final configPath = '$currentPath$configName';
  final configFile = File(configPath);
  final isConfigExists = await configFile.exists();

  if (!isConfigExists) {
    throw Exception(
      'please provide config with name: "game_tutorial.yaml"'
      ' in your application root',
    );
  }
  final configFileStr = configFile.readAsStringSync();
  stDebug(
    'config have ${configFileStr.isEmpty ? "no values" : "values"}',
  );

  final config = loadYaml(configFileStr);

  final maybeDataPaths = config[configJsonDataPath];

  final List<String> dataPaths = (() {
    if (maybeDataPaths is YamlList) {
      return maybeDataPaths.nodes.map((e) => e.value as String).toList();
    } else {
      return [defaultJsonDataPath];
    }
  })();

  final String classPropertyName =
      config[configPropertyWithClassName] as String? ??
          defaultPropertyWithClassName;

  stInfo('Config loaded');

  /// ********** DATA TRANSFORMATION ***********
  stDebug('use pathes to json files: $dataPaths');

  for (final relativePath in dataPaths) {
    final absoluteDirPath = '$currentPath$relativePath';
    if (await FileSystemEntity.isDirectory(absoluteDirPath)) {
      stDebug("path: $relativePath.");
      Directory(absoluteDirPath).list().listen(
        (entity) {
          stDebug("entity ${entity.path} is ${entity.runtimeType}");
          if (entity is! File || entity.path.contains('.dart')) return;
          final jsonStr = entity.readAsStringSync();
          stDebug("jsonStr is empty ${jsonStr.isEmpty}");
          if (jsonStr.isEmpty) return;
          final maybeList = jsonDecode(jsonStr);
          stDebug("maybeList is empty ${maybeList.isEmpty}");
          if (maybeList is List) {
            Library library = Library();
            Class mainClass = Class((c) => c.name = '');
            if (maybeList.isEmpty) return;
            final helperClasses = <MapEntry<String, Class>>{};
            for (final step in maybeList) {
              if (step is Map) {
                final maybeClassNameAndProperty = step[classPropertyName];
                if (maybeClassNameAndProperty is String &&
                    maybeClassNameAndProperty.isNotEmpty) {
                  final classNameAndProperty =
                      maybeClassNameAndProperty.split('.');
                  final className = classNameAndProperty[0];
                  final propertyName = classNameAndProperty[1];
                  if (className is! String) {
                    stDebug("step has empty class name. skipping");
                    continue;
                  } else if (mainClass.name.isEmpty) {
                    mainClass = mainClass.rebuild(
                      (c) => c.name = '$className$defaultClassNamePostfix',
                    );
                  }
                  if (propertyName is! String) {
                    stDebug("step has empty property name. skipping");
                    continue;
                  }
                  stDebug(
                    "step has className: $className, propertyName: $propertyName",
                  );
                  Class helperClass = Class(
                    (c) => c..name = "${propertyName.toProperCase()}Step",
                  );
                  final parameters = <MapEntry>[];
                  final methods = <Method>[];
                  const stringRef = Reference('String');
                  const stringNullRef = Reference('String?');

                  /// Check all proeprties for {} expressions
                  for (final stepEntry in step.entries) {
                    final stepEntryKey = stepEntry.key;
                    if (stepEntryKey is! String ||
                        stepEntryKey == maybeClassNameAndProperty) continue;
                    final strValue = stepEntry.value;
                    if (strValue is List) {
                      parameters.add(
                        MapEntry<String, dynamic>(
                          stepEntryKey,
                          strValue
                              .where((e) => e is String && e.isNotEmpty)
                              .map((e) => "'$e'")
                              .toList(),
                        ),
                      );

                      continue;
                    } else if (strValue is! String) {
                      parameters.add(stepEntry);
                      continue;
                    }

                    final regexp = RegExp(r'\{([^\}]*)\}');
                    final matches =
                        regexp.allMatches(strValue).map((r) => r[1]);
                    if (matches.isEmpty) {
                      parameters.add(stepEntry);
                      continue;
                    }
                    String bodyStr = strValue.substring(0);
                    for (final match in matches) {
                      final matchArg = "{$match}";
                      bodyStr = bodyStr.replaceAll(matchArg, "\$$match");
                    }

                    final method = Method(
                      (m) => m
                        ..name = stepEntryKey
                        ..body = Code("return '$bodyStr';")
                        ..returns = stringRef
                        ..optionalParameters.addAll(
                          matches.whereType<String>().map(
                                (m) => Parameter(
                                  (p) => p
                                    ..name = m
                                    ..named = true
                                    ..type = stringNullRef,
                                ),
                              ),
                        ),
                    );
                    methods.add(method);
                  }
                  stDebug(
                    "added ${methods.length} methods from step",
                  );
                  helperClass = helperClass.rebuild(
                    (h) => h
                      ..methods.addAll(methods)
                      ..fields.addAll(
                        [
                          Field(
                            (f) => f
                              ..name = 'json'
                              ..modifier = FieldModifier.final$
                              ..assignment = Code(() {
                                final map = Map.fromEntries(
                                  step.entries.map(
                                    (e) {
                                      final value = () {
                                        final eValue = e.value;
                                        if (eValue is bool || eValue is num) {
                                          return e.value;
                                        }
                                        if (eValue is List) {
                                          return eValue
                                              .map((val) => "'$val'")
                                              .toList();
                                        }

                                        return "'${e.value}'";
                                      }();
                                      return MapEntry(
                                        "'${e.key}'",
                                        value,
                                      );
                                    },
                                  ),
                                );
                                return "$map";
                              }()),
                          ),
                          ...parameters
                              .whereType<MapEntry<String, dynamic>>()
                              .map(
                            (p) {
                              final runtimeType =
                                  p.value.runtimeType.toString();
                              final String value = p.value is String
                                  ? "'${p.value}'"
                                  : "${p.value}";
                              return Field(
                                (f) => f
                                  ..name = p.key
                                  ..type = Reference(runtimeType)
                                  ..modifier = FieldModifier.final$
                                  ..assignment = Code(value),
                              );
                            },
                          ),
                        ],
                      ),
                  );
                  helperClasses.add(
                    MapEntry(propertyName, helperClass),
                  );
                  stDebug("step helper class added");
                } else {
                  stDebug("step has empty class name property. skipping");
                  continue;
                }
              } else {
                stDebug("step has not supported format ${step.runtimeType}");
              }
            }

            mainClass = mainClass.rebuild(
              (c) => c
                ..constructors.addAll(
                  [
                    Constructor(
                      (c) => c
                        ..body = Code(
                          'steps = [${helperClasses.map((h) => h.key).join(',')}];',
                        ),
                    ),
                  ],
                )
                ..fields.addAll(
                  [
                    ...helperClasses.map(
                      (h) => Field(
                        (f) => f
                          ..name = h.key
                          ..assignment = Code("${h.value.name}()")
                          ..modifier = FieldModifier.final$,
                      ),
                    ),

                    /// adding all steps as list
                    Field(
                      (f) => f
                        ..name = 'steps'
                        ..type = refer('List')
                        ..assignment = const Code('[]')
                        ..modifier = FieldModifier.var$,
                    ),

                    /// assign itself to get static access
                    Field(
                      (f) => f
                        ..name = 'current'
                        ..type = Reference(mainClass.name)
                        ..assignment = Code('${mainClass.name}()')
                        ..static = true,
                    ),
                  ],
                ),
            );
            stDebug("mainClass rebuilded");

            library = library.rebuild(
              (l) => l
                ..body.addAll(
                  [
                    ...helperClasses.map((h) => h.value),
                    mainClass,
                  ],
                ),
            );
            stDebug("library rebuilded");
            final str = Formatter.formatAndStringify(spec: library);
            final newPath = entity.path.split('.')[0];
            final newPathWithExt = "$newPath.g.dart";
            stDebug("path regenerated");

            File(newPathWithExt).writeAsStringSync(" \n$str");
            stInfo("file ${mainClass.name} written");
          } else {
            stInfo(
              "file content has not supported format ${maybeList.runtimeType}",
            );
          }
        },
      );
    }
  }
}

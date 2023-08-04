import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

// import 'package:path_provider/path_provider.dart'; //can't use flutter packages as they rely on UI

import 'package:vector_math/vector_math.dart';

/// pre-process assets to be shipped with the game
class AssetPreprocessor {
  AssetPreprocessor() {
    initialized = initialize();
  }

  /// completes to true when assets have been pre-loaded
  late Future<bool> initialized;

  /// stub imported from the to-illustrator-exporter script that has graphics and positioning related information but no historic info
  late Map<String, dynamic> _provinceStubs;

  /// historic ref has the manually generated info relating to province ownership, population, fortification etc
  late Map<String, dynamic> _historicRef;

  /// province forts map. Use [_allProvincesFortKey] to extract key for name
  /// of fort for all provinces
  late Map<String, dynamic> _provinceForts;
  static const _allProvincesFortKey = 'all_provinces';

  Future<bool> initialize() async {
    _provinceStubs = await readJsonFile('assets/json/province-stubs.json');
    _historicRef = await readJsonFile('assets/json/historic-provinces.json');
    _provinceForts = await readJsonFile('assets/json/provinces_forts.json');
    return true;
  }

  /// convert the province stub data into TO province JSON format with edges
  Future<void> processProvinces() async {
    final List<dynamic> provinceList =
        _provinceStubs['provinces'] as List<dynamic>;
    final List<Map<String, dynamic>> provinceHistoryList =
        (_historicRef['historicProvinces'] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList();

    final Map<String, _ProvinceData> preprocessedProvinces = {};

    // deserialize
    provinceList.asMap().forEach((int i, province) {
      final name = province['name'] as String;
      String fortJsonName;
      if (_provinceForts.containsKey(name)) {
        fortJsonName = _provinceForts[name] ?? '';
      } else {
        fortJsonName = _provinceForts[_allProvincesFortKey] ?? '';
      }
      // update positional data
      final _ProvinceData provinceData = _ProvinceData(
        id: name,
        name: name,
        mask: province['mask'] as String,
        x: (province['x'] as num).toDouble(),
        y: (province['y'] as num).toDouble(),
        friendlyX: (province['friendlyX'] as num?)?.toDouble(),
        friendlyY: (province['friendlyY'] as num?)?.toDouble(),
        enemyX: (province['enemyX'] as num?)?.toDouble(),
        enemyY: (province['enemyY'] as num?)?.toDouble(),
        width: (province['width'] as num).toDouble(),
        height: (province['height'] as num).toDouble(),
        fortPath: fortJsonName.isNotEmpty ? "fort_$fortJsonName.json" : null,
      );

      // update points
      for (var point in (province['points'] as List<dynamic>)) {
        final List<double> processedPoint = [
          (point[0] as num).toDouble(),
          (point[1] as num).toDouble()
        ];
        provinceData.points.add(processedPoint);
      }

      // update historic reference data
      final historicRefIndex = provinceHistoryList
          .indexWhere((element) => element['name'] == province['name']);

      final Map<String, dynamic>? historicRef = () {
        if (historicRefIndex < 0) return null;
        return provinceHistoryList[historicRefIndex];
      }();
      historicRef == null
          ? provinceData.updateFromDefaults()
          : provinceData.updateFromHistoricRef(historicRef);

      // commit the province
      preprocessedProvinces[provinceData.id] = provinceData;
    });

    final RegExp pattern = RegExp(
      '<style>.*</style>',
      multiLine: true,
      caseSensitive: false,
      dotAll: true,
    );
    final List<String> provinceMaskSvgFileList = [];
    // check all masks are present and save them in a separate asset file for pre-loading
    await Future.forEach(preprocessedProvinces.values,
        (_ProvinceData province) async {
      // check mask is present
      final String maskFilePath = 'assets/images/${province.mask}';
      final File maskFile = await localFile(maskFilePath);
      assert(
        maskFile.existsSync(),
        'Province mask not found: ${province.mask}',
      );

      final String maskXmlString = await readStringFile(maskFilePath);
      writeStringFile(
        maskFilePath,
        maskXmlString.replaceFirst(pattern, ''),
      ); //no need to await this

      if (maskFilePath.split('.').last.toLowerCase() == 'svg') {
        provinceMaskSvgFileList.add(maskFilePath);
      }
    });

    // write the mask file list to a JSON asset file
    if (provinceMaskSvgFileList.isNotEmpty) {
      writeJsonFile(
        'assets/json/province-masks.json',
        {'files': provinceMaskSvgFileList},
      );
    }

    double progress = 0.0;
    final double progressStep = 1 /
        (preprocessedProvinces.length * preprocessedProvinces.length); // 1 / N2

    // calculate edges
    for (var provinceA in preprocessedProvinces.values) {
      for (var provinceB in preprocessedProvinces.values) {
        progress += progressStep;

        if (provinceA.points.isEmpty ||
            provinceB.points.isEmpty) {
          throw 'Error processing provinces - names or points null/empty';
        }

        // not the same province and not already an edge
        if (provinceA != provinceB && !provinceA.edges.contains(provinceB.id)) {
          final Vector2 centerA = Vector2(
            provinceA.x - provinceA.width / 2.0,
            provinceA.y - provinceA.height / 2.0,
          );
          final Vector2 centerB = Vector2(
            provinceB.x - provinceB.width / 2.0,
            provinceB.y - provinceB.height / 2.0,
          );

          final double distanceThreshold = math.max(
            provinceA.width + provinceA.height,
            provinceB.width + provinceB.height,
          );

          // closer centers than the distance threshold
          if (centerA.distanceToSquared(centerB) <
              distanceThreshold * distanceThreshold) {
            if (provinceA.isAdjacent(provinceB)) {
              provinceA.edges.add(provinceB.id);
              provinceB.edges.add(provinceA.id);
            } else {
              //not adjacent
            }
          }
        }

        log('${(100 * progress).round()}% processed');
      }
    }

    writeJsonFile(
      'assets/json/province-generated.json',
      {'provinces': preprocessedProvinces},
    );
  }
}

typedef _Id = String;

@Deprecated('replace with new ProvinceData class')
class _ProvinceData {
  _ProvinceData({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.name,
    required this.id,
    required this.mask,
    required this.fortPath,
    this.friendlyX,
    this.friendlyY,
    this.enemyX,
    this.enemyY,
  }) {
    friendlyX ??= x + width * 0.45;
    friendlyY ??= y + height * 0.45;
    enemyX ??= friendlyX! + math.min(width * 0.05, 64.0 * 5.0);
    enemyY ??= friendlyY! + math.min(height * 0.05, 48.0 * 5.0);
  }

  String name;
  String mask;
  _Id id;
  double x;
  double y;
  double? friendlyX;
  double? friendlyY;
  double? enemyX;
  double? enemyY;
  double width;
  double height;

  final List<List<double>> points = [];
  final List<_Id> edges = [];
  final List<String> specialUnits = [];

  double? population;
  double? provisionsCapacity;
  double? provisionsStored;
  double? provisionsYield;
  String? nationId;
  String? map;
  String? fortPath;

  final List<List<int>> attackDeploymentPoints = [];
  final List<List<int>> defenceDeploymentPoints = [];

  void updateFromHistoricRef(Map<String, dynamic> ref) {
    if (ref['mask'] != null) mask = ref['mask'] as String;
    population = (ref['population'] as num).toDouble();
    provisionsCapacity = (ref['provisionsCapacity'] as num).toDouble();
    provisionsStored = (ref['provisionsStored'] as num).toDouble();
    provisionsYield = (ref['provisionsYield'] as num).toDouble();
    nationId = ref['nationId'] as String?;
    final refFortPath = ref['fortPath'] as String?;
    if (refFortPath != null && refFortPath.isNotEmpty) {
      fortPath = refFortPath;
    }
    map = ref['map'] as String?;

    if (ref['attackDeploymentPoints'] != null) {
      for (var element in (ref['attackDeploymentPoints'] as List<dynamic>)) {
        attackDeploymentPoints.add([element[0] as int, element[1] as int]);
      }
    }
    if (ref['defenceDeploymentPoints'] != null) {
      for (var element in (ref['defenceDeploymentPoints'] as List<dynamic>)) {
        defenceDeploymentPoints.add([element[0] as int, element[1] as int]);
      }
    }

    if (ref['specialUnits'] != null) {
      specialUnits
          .addAll((ref['specialUnits'] as List<dynamic>).map((e) => e as String));
    }

    // TODO: add custom edges here
  }

  /// if no historic ref for the province, provide default resource values
  void updateFromDefaults() {
    population = 35000.0;
    provisionsCapacity = 45000.0;
    provisionsStored = provisionsCapacity! * 0.75;
    provisionsYield = 30000.0;
    nationId = 'independent';
  }

  Map<String, dynamic> toJson() {
    return Map.fromEntries([
      MapEntry('id', id),
      MapEntry('name', name),
      MapEntry('x', x),
      MapEntry('y', y),
      MapEntry('friendlyX', friendlyX),
      MapEntry('friendlyY', friendlyY),
      MapEntry('enemyX', enemyX),
      MapEntry('enemyY', enemyY),
      MapEntry('width', width),
      MapEntry('height', height),
      MapEntry('edges', edges),
      MapEntry('specialUnits', specialUnits),
      MapEntry('mask', mask),
      MapEntry('population', population),
      MapEntry('provisionsCapacity', provisionsCapacity),
      MapEntry('provisionsStored', provisionsStored),
      MapEntry('nationId', nationId),
      MapEntry('map', map),
      MapEntry('fortPath', fortPath),
      MapEntry('attackDeploymentPoints', attackDeploymentPoints),
      MapEntry('defenceDeploymentPoints', defenceDeploymentPoints),
    ]);
  }

  bool isAdjacent(_ProvinceData otherProvince) {
    for (int i = 0; i < points.length - 1; i++) {
      final Vector2 startVectorA = Vector2(points[i][0], points[i][1]);
      final Vector2 endVectorA = Vector2(points[i + 1][0], points[i + 1][1]);

      for (int k = 0; k < otherProvince.points.length - 1; k++) {
        final Vector2 startVectorB =
            Vector2(otherProvince.points[k][0], otherProvince.points[k][1]);
        final Vector2 endVectorB = Vector2(
          otherProvince.points[k + 1][0],
          otherProvince.points[k + 1][1],
        );

        final Vector2 originVectorA = endVectorA - startVectorA;
        final Vector2 originVectorB = endVectorB - startVectorB;

        final double absoluteDotProduct =
            originVectorA.normalized().dot(originVectorB.normalized()).abs();

        // path segments are nearly parallel if absolute dot product is close to 1.0
        if ((absoluteDotProduct - 1.0).abs() < 0.1) {
          // difference between the mid points of the two segments is less than sqrt 1600.0
          if ((startVectorA + endVectorA)
                  .scaled(0.5)
                  .distanceToSquared((startVectorB + endVectorB).scaled(0.5)) <
              1400.0) {
            return true;
          }
        }
      }
    }

    return false;
  }
}

Future<void> main() async {
  /// presume success
  exitCode = 0;
  final AssetPreprocessor processor = AssetPreprocessor();

  await processor.initialized;
  await processor.processProvinces();
}

Future<String> get localPath async {
  // final directory = await getApplicationDocumentsDirectory();
  final currentPath = Directory.current.path;
  return currentPath;
  // return 'C:/src/transoxiana/'; // TODO: generalize
  // return 'C:/Users/pgain/StudioProjects/transoxiana/'; // TODO: generalize
}

Future<File> localFile(String name) async {
  final path = await localPath;
  return File('$path/$name');
}

Future<File> writeJsonFile(String fileName, Map<String, dynamic> data) async {
  final File file = await localFile(fileName);

  // Write the file.
  return file.writeAsString(jsonEncode(data));
}

Future<Map<String, dynamic>> readJsonFile(String fileName) async {
  try {
    final File file = await localFile(fileName);

    // Read the file.
    final String contents = await file.readAsString();

    return jsonDecode(contents) as Map<String, dynamic>;
  } catch (e) {
    // If encountering an error, return 0.
    rethrow;
  }
}

Future<String> readStringFile(String fileName) async {
  try {
    final File file = await localFile(fileName);

    // Read the file.
    final String contents = await file.readAsString();

    return contents;
  } catch (e) {
    // If encountering an error, return 0.
    rethrow;
  }
}

Future<File> writeStringFile(String fileName, String data) async {
  final File file = await localFile(fileName);

  // Write the file.
  return file.writeAsString(data);
}

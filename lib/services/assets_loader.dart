import 'dart:convert';
import 'dart:developer';

import 'package:flame/flame.dart';
import 'package:flutter_gifimage/flutter_gifimage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:transoxiana/services/audio/sfx.dart';
import 'package:transoxiana/widgets/ui_constants.dart';

Future<void> loadAssets() async {
  // load assets in parallel
  await Future.wait([
    // load raster image assets
    Flame.images.loadAll([
      'strategic_map.jpg',
      'background.jpg',
      'walls/walls_dmg_0.png',
      'walls/walls_dmg_1.png',
      'walls/walls_dmg_2.png',
      'walls/walls_dmg_3.png',
      'units/units.png',
      'units/pikemen-0.png',
      'units/pikemen-1.png',
      'units/pikemen-2.png',
      'units/pikemen-3.png',
      'units/pikemen-4.png',
      'units/pikemen-5.png',
      'units/mlc-0.png',
      'units/mlc-1.png',
      'units/mlc-2.png',
      'units/mlc-3.png',
      'units/mlc-4.png',
      'units/mlc-5.png',
      'units/Heavy-Cavalry-0.png',
      'units/Heavy-Cavalry-1.png',
      'units/Heavy-Cavalry-2.png',
      'units/Heavy-Cavalry-3.png',
      'units/Heavy-Cavalry-4.png',
      'units/Heavy-Cavalry-5.png',
      'units/Swordsmen-0.png',
      'units/Swordsmen-1.png',
      'units/Swordsmen-2.png',
      'units/Swordsmen-3.png',
      'units/Swordsmen-4.png',
      'units/Swordsmen-5.png',
      'units/archers-0.png',
      'units/archers-1.png',
      'units/archers-2.png',
      'units/archers-3.png',
      'units/archers-4.png',
      'units/archers-5.png',
      'weather/clouds1.png',
      'weather/clouds2.png',
      'weather/clouds3.png',
      'weather/darkclouds1.png',
      'weather/darkclouds2.png',
      'weather/darkclouds3.png',
      'weather/lightningcloud1.png',
      'weather/lightningcloud2.png',
      'weather/lightningcloud3.png',
    ]),
    // pre-cache gif hourglass to make transition from static hourglass to animated smoother
    fetchGif(UiRasterAssets.hourglassAnimated),
    () async {
      // pre-cache SVG provinces
      final String fileListString =
          await Flame.assets.readFile('json/province-masks.json');
      await Future.forEach(
          (jsonDecode(fileListString) as Map<String, dynamic>)['files']
              as List<dynamic>, (final dynamic filePathString) async {
        await precachePicture(
          ExactAssetPicture(
            SvgPicture.svgStringDecoderBuilder,
            filePathString as String,
          ),
          null,
        );
      });
    }(),
    // pre-cache SVG icons to avoid annoying split second delay
    // when campaign map loads or you select a unit for the first time
    Future.forEach<String>(
      UiIcons.asList,
      (final iconString) async => precachePicture(
        ExactAssetPicture(SvgPicture.svgStringDecoderBuilder, iconString),
        null,
      ),
    ),
    MultiTrackSfx.initAllPools(),
  ]);

  log('Assets loaded.');
}

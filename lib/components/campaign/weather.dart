import 'dart:math';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:json_annotation/json_annotation.dart';
import 'package:transoxiana/components/campaign/province.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/components_render_priority.dart';
import 'package:transoxiana/data/season.dart';

enum WeatherType {
  sunny,
  cloudy,
  rain,
  snow,
}

/// only the "extend" versions below should be used
class Weather extends Component with EquatableMixin {
  Weather({
    required this.type,
    this.province,
    this.campaignSpeedFactor = 1.0,
  }) : super(priority: ComponentsRenderPriority.campaignWeather.value);

  @JsonKey(ignore: true)
  Province? province;

  @JsonKey(ignore: true)
  Random get rand => _rand;
  // static final ColorFilter filter = ColorFilter.mode(
  //   Colors.transparent.withOpacity(0.5),
  //   BlendMode.srcIn,
  // );

  ///used to add transparency to the component image
  static final Random _rand = Random();
  static final Paint paint = Paint()
    ..color = const Color.fromRGBO(
      0,
      0,
      0,
      0.35,
    );

  /// used for serialization, must be static wrt the extended class
  final WeatherType type;

  final double campaignSpeedFactor;

  @override
  void render(final Canvas canvas) {
    if (province == null || province!.isNotVisibleToPlayer) return;
    super.render(canvas);
  }

  @override
  List<Object?> get props => [type];
}

//TODO: correlations with neighbouring provinces?
Future<Weather> generateWeather(final Season currentSeason) async {
  late Weather weather;

  final Random rand = Random();
  final int outcome = rand.nextInt(9);

  if (currentSeason == Season.winter) {
    if (outcome < 5) {
      weather = await Snow.load();
    } else if (outcome < 7) {
      weather = await Rain.load();
    } else if (outcome < 8) {
      weather = await Cloudy.load();
    } else {
      weather = Sunny();
    }
  } else if (currentSeason == Season.spring) {
    if (outcome < 1) {
      weather = await Snow.load();
    } else if (outcome < 4) {
      weather = await Rain.load();
    } else if (outcome < 7) {
      weather = await Cloudy.load();
    } else {
      weather = Sunny();
    }
  } else if (currentSeason == Season.summer) {
    if (outcome < 2) {
      weather = await Rain.load();
    } else if (outcome < 4) {
      weather = await Cloudy.load();
    } else {
      weather = Sunny();
    }
  } else if (currentSeason == Season.autumn) {
    if (outcome < 1) {
      weather = await Snow.load();
    } else if (outcome < 6) {
      weather = await Rain.load();
    } else if (outcome < 8) {
      weather = await Cloudy.load();
    } else {
      weather = Sunny();
    }
  }

  return weather;
}

Future<Weather> getWeatherByType(final WeatherType type) async {
  switch (type) {
    case WeatherType.sunny:
      return Sunny();
    case WeatherType.cloudy:
      return Cloudy.load();
    case WeatherType.rain:
      return Rain.load();
    case WeatherType.snow:
      return Snow.load();
    default:
      throw Exception('Invalid index provided to getWeatherByIndex: $type');
  }
}

class Sunny extends Weather {
  Sunny({final Province? province})
      : super(
          type: WeatherType.sunny,
          campaignSpeedFactor: 0.9,
          province: province,
        );
}

class Cloudy extends Weather {
  Cloudy._({
    required final WeatherType type,
    required final double campaignSpeedFactor,
    required this.image,
    final Province? province,
  }) : super(
          type: type,
          campaignSpeedFactor: campaignSpeedFactor,
          province: province,
        );
  final Image image;

  /// Alwyas use [load] instead

  static Future<Cloudy> load() async {
    final int i = Weather._rand.nextInt(2);
    final image = await () async {
      if (!isHeadless) {
        final cloud = [
          'weather/clouds1.png',
          'weather/clouds2.png',
          'weather/clouds3.png',
        ][i];
        return Flame.images.load(cloud);
      }
      return null;
    }();
    if (image == null) throw ArgumentError.notNull('no cloud image found');
    final cloudy = Cloudy._(
      campaignSpeedFactor: 1,
      type: WeatherType.cloudy,
      image: image,
    );
    return cloudy;
  }

  @override
  void render(final Canvas canvas) {
    final resolvedProvince = province;
    final resolvedImage = image;
    super.render(canvas);
    if (resolvedProvince == null || resolvedProvince.isNotVisibleToPlayer)
      return;

    canvas.drawImageRect(
      resolvedImage,
      Rect.fromPoints(
        Offset.zero,
        Offset(
          resolvedImage.width.toDouble(),
          resolvedImage.height.toDouble(),
        ),
      ),
      resolvedProvince.touchRect.shift(const Offset(-10.0, -25.0)),
      Weather.paint,
    );
  }
}

class Rain extends Weather {
  Rain._({
    required final WeatherType type,
    required final double campaignSpeedFactor,
    final Province? province,
  }) : super(
          type: type,
          campaignSpeedFactor: campaignSpeedFactor,
          province: province,
        );
  final List<Image> frames = [];
  double timer = 0.0;
  static const double threshold = 400.0 / 1000.0; //s between frame changes
  int frameIndex = 0;

  /// Alwyas use [load] instead
  @factory
  // ignore: invalid_factory_method_impl
  static Future<Rain> load() async {
    final rain = Rain._(
      campaignSpeedFactor: 0.85,
      type: WeatherType.rain,
    );
    final int i = rain.rand.nextInt(2);
    if (!isHeadless) {
      final darkCloudName = [
        'weather/darkclouds1.png',
        'weather/darkclouds2.png',
        'weather/darkclouds3.png',
      ][i];
      final lightningCloudName = [
        'weather/lightningcloud1.png',
        'weather/lightningcloud2.png',
        'weather/lightningcloud3.png',
      ][i];
      final clouds = [darkCloudName, lightningCloudName];
      final images = await Flame.images.loadAll(clouds);
      rain.frames.addAll(images);
    }
    return rain;
  }

  @override
  void update(final double dt) {
    timer += dt;

    if (timer > threshold) {
      frameIndex += 1;
      if (frameIndex >= frames.length) frameIndex = 0;
      timer = 0.0;
    }

    super.update(dt);
  }

  @override
  void render(final Canvas canvas) {
    final resolvedProvince = province;

    super.render(canvas);
    if (resolvedProvince == null || resolvedProvince.isNotVisibleToPlayer)
      return;

    final Image image = frames[frameIndex];
    canvas.drawImageRect(
      image,
      Rect.fromPoints(
        Offset.zero,
        Offset(image.width.toDouble(), image.height.toDouble()),
      ),
      resolvedProvince.touchRect.shift(const Offset(-10.0, -25.0)),
      Weather.paint,
    );
  }
}

class Snow extends Weather {
  /// Alwyas use [load] instead
  Snow._({
    required final WeatherType type,
    required final double campaignSpeedFactor,
    required this.image,
    final Province? province,
  }) : super(
          type: type,
          campaignSpeedFactor: campaignSpeedFactor,
          province: province,
        );

  final Image image;

  static Future<Snow> load() async {
    final int i = Weather._rand.nextInt(2);
    final image = await () async {
      if (!isHeadless) {
        final cloud = [
          'weather/clouds1.png',
          'weather/clouds2.png',
          'weather/clouds3.png',
        ][i];
        return Flame.images.load(cloud);
      }
      return null;
    }();
    if (image == null) throw ArgumentError.notNull('no snow image found');
    final snow = Snow._(
      campaignSpeedFactor: 0.5,
      type: WeatherType.snow,
      image: image,
    );
    return snow;
  }

  @override
  void render(final Canvas canvas) {
    final resolvedProvince = province;
    final resolvedImage = image;
    super.render(canvas);
    if (resolvedProvince == null || resolvedProvince.isNotVisibleToPlayer)
      return;

    canvas.drawImageRect(
      resolvedImage,
      Rect.fromPoints(
        Offset.zero,
        Offset(
          resolvedImage.width.toDouble(),
          resolvedImage.height.toDouble(),
        ),
      ),
      resolvedProvince.touchRect.shift(const Offset(-10.0, -25.0)),
      Weather.paint,
    );
    // if(this.province.image != null) paintImage(
    //   rect: this.province.touchRect.shift(Offset(-30.0, -75.0)),
    //   image: image,
    //   canvas: c,
    //   colorFilter: Weather.filter,
    // );
  }
}

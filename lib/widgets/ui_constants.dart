import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum Corner { topLeft, topRight }

// Helper class that holds UI colors.
// Usage: e.g. UiColors.greyStone
abstract class UiColors {
  UiColors._();
  static const Color greyStone = Color(0xFF848795);
  static const Color blackAsh = Color(0xFF333333);
  static const Color gold = Color(0xFFF1C431);
  static const Color lightGrey = Color(0xFFC4C4C4);
  static const Color yellowPapyrus = Color(0xFFFFE09F);
  static const Color brownWood = Color(0xFF785531);
  static Color goldTransparent =
      gold.withOpacity(UiSettings.buttonHighlightOpacity);
}

abstract class UiSizes {
  static const double buttonSize = 70;
  static const double cornerButtonSize = 150;
  static const double buttonImageSize = buttonSize * 2 / 3;
  static const double paddingXS = 3;
  static const double paddingS = 5;
  static const double paddingM = 8;
  static const double paddingL = 10;
  static const double paddingXL = 20;

  static const double tabIconSize = 30;
  static const double statusIconSize = 20;
  static const double roundIconButtonSizeL = 60.0;
  static const double roundIconButtonSizeS = 38.0;

  // keep borderWidth even for better results in UI
  static const double borderWidth = 4;
  static const double borderRadius = 16;
  static const double borderRadiusSmall = 10;
  static const double innerBorderRadiusOffset = borderWidth / 2;

  static const double minBattleZoom = 1.5;
  static const double maxBattleZoom = 3.0;

  static const double minCampaignZoom = 1.0;
  static const double maxCampaignZoom = 3.0;

  static const double maxCameraVelocity = 30.0;

  static const double zoomStep = 0.5;
  static const double zoomStepForTouch = 0.05;
  static const double zoomPerScrollUnit = 0.1;
  static const double tileSize = 32.0;
  static const double maxWorldSize = 2000.0;

  static const double drawerMenuHeight = 400.0;
  static const double drawerMenuWidth = 300.0;
}

abstract class UiSettings {
  UiSettings._();
  static BoxShadow buttonShadow = BoxShadow(
    color: Colors.black.withOpacity(buttonHighlightOpacity),
    blurRadius: 4,
    offset: const Offset(2, 3),
  );
  static BoxShadow widgetShadow = BoxShadow(
    color: Colors.black.withOpacity(0.5),
    blurRadius: 4,
    spreadRadius: 2,
  );
  static const Shadow textShadow = Shadow(
    offset: Offset(0.75, 0.5),
  );

  static const List<Shadow> textShadows = [
    textShadow,
  ];
  static BorderRadius borderRadiusAll =
      const BorderRadius.all(Radius.circular(UiSizes.borderRadius));
  static double buttonFillOpacity = 0.15;
  static double buttonHighlightOpacity = 0.5;
  static NumberFormat wholeNumberFormat = NumberFormat('#,###');
  static NumberFormat decimalNumberFormat = NumberFormat('#,###.#');
}

abstract class UiIcons {
  UiIcons._();
  static const String _path = 'assets/images/ui/icons/';
  static const String help = '${_path}help.svg';
  static const String war = '${_path}rally-the-troops.svg';
  static const String peace = '${_path}classical-knowledge.svg';
  static const String diplomacy = '${_path}medieval-pavilion.svg';
  static const String zoomIn = '${_path}zoom_in.svg';
  static const String zoomOut = '${_path}zoom_out.svg';
  static const String attack = '${_path}attack.svg';
  static const String allAttack = '${_path}sword-array.svg';
  static const String allCancel = '${_path}directions_alt_off-48px.svg';
  static const String defend = '${_path}defend.svg';
  static const String allDefend = '${_path}shield-echoes.svg';
  static const String fastForward = '${_path}keyboard_double_arrow_right.svg';
  static const String bombard = '${_path}bombard.svg';
  static const String cancel = '${_path}cancel.svg';
  static const String scroll = '${_path}scroll.svg';
  static const String arrowLeft = '${_path}arrow_left.svg';
  static const String arrowRight = '${_path}arrow_right.svg';
  static const String signpost = '${_path}signpost.svg';
  static const String helmet = '${_path}helmet.svg';
  static const String laurels = '${_path}laurels.svg';
  static const String compass = '${_path}compass.svg';
  static const String catapult = '${_path}catapult.svg';
  static const String cogwheel = '${_path}cogwheel.svg';
  static const String flag = '${_path}flag.svg';
  static const String crossedSwords = '${_path}crossed_swords.svg';
  static const String horse = '${_path}horse.svg';
  static const String spring = '${_path}spring.svg';
  static const String summer = '${_path}summer.svg';
  static const String autumn = '${_path}autumn.svg';
  static const String winter = '${_path}winter.svg';
  static const String cityWalls = 'images/ui/icons/qaitbay-citadel.svg';

  static List<String> get asList => [
        help,
        war,
        peace,
        diplomacy,
        zoomOut,
        zoomIn,
        attack,
        allAttack,
        defend,
        allDefend,
        bombard,
        cancel,
        scroll,
        arrowLeft,
        arrowRight,
        signpost,
        helmet,
        laurels,
        compass,
        catapult,
        cogwheel,
        flag,
        crossedSwords,
        horse,
        summer,
        autumn,
        winter,
        spring,
        // cityWalls,
      ];
}

abstract class UiRasterAssets {
  UiRasterAssets._();
  static const Image hourglass = Image(
    image: AssetImage('assets/images/ui/raster/hourglass.gif'),
    height: UiSizes.buttonImageSize,
    gaplessPlayback: true,
  );
  static const AssetImage hourglassAnimated =
      AssetImage('assets/images/ui/raster/hourglass_animated.gif');
  static DecorationImage scroll = DecorationImage(
    fit: BoxFit.cover,
    colorFilter: ColorFilter.mode(
      UiColors.yellowPapyrus.withOpacity(UiSettings.buttonFillOpacity * 2),
      BlendMode.dstATop,
    ),
    image: const ExactAssetImage(UiBackgrounds.papyrus),
  );
}

abstract class UiBackgrounds {
  static const String _path = 'assets/images/ui/backgrounds/';
  static const String papyrus = '${_path}papyrus.png';
  static const String stone = '${_path}stone.png';
  static const String wood = '${_path}wood.png';
}

abstract class UiThemes {
  UiThemes._();
  static ThemeData defaultTheme = ThemeData(
    // primarySwatch: Colors.blueGrey,
    backgroundColor: Colors.amberAccent.withOpacity(0.65),
    //const Color(0xfff1deda),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.blueGrey,
      accentColor: Colors.redAccent.shade700,
    ),
    // accentColor: Colors.redAccent.shade700,
    highlightColor: Colors.deepPurple,
    cardColor: UiColors.yellowPapyrus,
    textTheme: defaultTextTheme,
    tooltipTheme: TooltipThemeData(
      textStyle: defaultTextTheme.bodyText2,
      decoration: BoxDecoration(
        color: UiColors.yellowPapyrus,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 4,
          ),
        ],
      ),
    ),
  );

  static TextTheme defaultTextTheme = const TextTheme(
    /// smaller font (e.g. "army X of Y" text)
    bodyText1: TextStyle(
      backgroundColor: Colors.transparent,
      color: UiColors.blackAsh,
      fontWeight: FontWeight.normal,
      fontSize: 14.0,
      fontFamily: 'Quattrocento',
    ),

    /// default text style for many Material widgets
    bodyText2: TextStyle(
      backgroundColor: Colors.transparent,
      color: Colors.black,
      fontWeight: FontWeight.normal,
      fontSize: 16.0,
      fontFamily: 'Quattrocento',
    ),

    /// bold and size 20 for headings in menu widgets
    headline2: TextStyle(
      backgroundColor: Colors.transparent,
      color: UiColors.blackAsh,
      fontWeight: FontWeight.bold,
      fontSize: 20.0,
      fontFamily: 'Quattrocento',
    ),

    /// largest text (size 32)
    headline3: TextStyle(
      fontSize: 32.0,
      color: Colors.black,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.normal,
      fontFamily: 'Quattrocento',
      decoration: TextDecoration.none,
    ),

    /// larger text for status bar
    headline4: TextStyle(
      backgroundColor: Colors.transparent,
      color: UiColors.blackAsh,
      fontWeight: FontWeight.normal,
      fontSize: 20.0,
      fontFamily: 'Quattrocento',
    ),

    /// size 24 larger text
    headline5: TextStyle(
      fontSize: 24.0,
      color: Colors.black,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.normal,
      fontFamily: 'Quattrocento',
      decoration: TextDecoration.none,
    ),
  );
}

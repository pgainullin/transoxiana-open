# transoxiana

Transoxiana Game Demo Is Now Open Source

# Data managing

All classes defined in `DataModel` - `RuntimeController`

## `DataModel` is what is used for serialization and saving.

It keeps all saving/serializable properties of the object and doesn't keep logic at all
It also has a loader function, often - `DataModel.toRuntime()`

To build the generated JSON serializers use `flutter pub run build_runner build`

## `RuntimeController` is the logic class.

It should always implement `DataSourceRef` to provide `DataModel` instance and `GameRef` a `game` reference

Also for reverse conversion, it should always have `RuntimeController.toData()` to save required changes to `DataModel`

## For example:

UnitData.toRuntime() => Unit()
Unit.toData() => UnitData()

# Asset Processing

1. Any changes to Province SVG assets need to be accompanied with an updated province-stubs.json file generated from the Adobe Illustrator [exporter script](https://github.com/pgainullin/to-illustrator-exporter).
2. Any historical and gameplay related information (other than campaign_init.json data) must be added to historic-provinces.json.
3. Once both of the above JSON files are up to date run `flutter pub run assets_preprocessor` which will create an updated province-generated.json and province-masks.json files which the game uses.
4. To optimise SVG files and improve performance run the AssetProcessor workflow in Github Actions and merge the resulting pull request.

# String Management

1. Install [this plugin](https://plugins.jetbrains.com/plugin/13666-flutter-intl) for Android Studio - it is required for placeholder support in strings.
2. Add a string you need to `lib/l10n/intl_en_GB.arb`, this is basically a JSON file. Keys should be camelCase; to create a placeholder, use {}, e.g. `"logRangedKill": "{killerNation}'s {killerUnit} killed {killedNation}'s {killedUnit} by shooting them {location}"`
3. File -> Save All (or Ctrl + S on Windows). This is needed for the plugin to re-generate helper classes with placeholders.
4. To use strings in code: `S.of(context).logRangedKill(killerNation, killerUnit, killedNation, killedUnit, location)` (if you have context, i.e. in widgets) **OR** `S.current.logRangedKill(......)` (if no context, i.e. from Flame components like unit, army etc.)
5. Run game and string will be there.

# Tutorial Management

To edit the tutorial content edit the .json files located in /lib/data/tutorials.

Any edits to configuration have to be run through a builder:

`flutter pub run tutorial`

Upon running the builder the resulting lib/data/tutorials/main_menu_tutorial_steps.g.dart file will have an error since it will generate as null-safe. To fix it add `` at the top of that file.

To edit the specific steps and their order look for tutorialService.setState usages. Currently the campaign tutorial is mainly loaded in campaign_tutorial_initializer.dart.


## Structure

The tutorial system consists of the following key elements:

- Steps: each step describes what triggers the this part of the tutorial (Actions), what UI this step provides (eg Next/Back/Close), what elements the step highlights (see Keys) and finally the text content of the tip.
- Modes: The game has several tutorial modes (Main Menu, Campaign, Battle and Independent). Each mode has its set of Steps and an order in which they are played.
- Actions: serializable identifier for the tutorial step that will determine when this step will be called. The builder will create the relevant functions from the .json files in data/tutorials, however the actions enums need to exist in package:tutorial/lib/src/data/data.dart.
- Keys: GlobalKeys that are referenced by tutorial Steps. Keys need to be added to tutorial_settings/tutorial_keys.dart and the relevant widgets as well as the tutorial steps. They can further be referenced in the data/tutorials folder for the specific tutorial mode linking it with the Actions.
- TutorialService: manages tutorial state and is accessed anywhere in code where you need to read or write tutorial Steps.
- Overlay + FloatingTip: Actual UI elements that shades the screen (excluding the highlighted element) and displays a dialogue with the text content.

## Tutorial Service - in memory state of all tutorial steps

### Purpose

- keeps all actual steps inside game memory in unified format and instant access.
- tutorial steps inside service have access to gameRef and because of that they can manage any functionality inside game.
- independent from any json files - it makes easier to add steps dynamically and with dynamic content

### Structure

-                  {key               : value}
- all steps map -> {Tutorial Mode enum: TutorialMode}

#### TutorialMode

- has Tutorial Steps inside linked hash set to keep order of added steps and make no duplicates.
- has keys map (optional) - it keeps links between enumAction as a key and globalkey as a value. Refills automatically from any new TutorialSteps.

## Package - Tutorial - tools to build data and tutorial system for the game.

### Purpose

- provides core models for tutorial
- can build TutorialSteps with automatic serialisation/deserialisation
- provides serialisation functions for data enums
- it has no connection with TutorialService, so service actually using Tutorial package functions and models.

### Why an independent package

- easier to maintain with single responsibility principle
- makes it possible to create special UI for any tutorial scenario development and save all information to json and then load when required.

# Running & Building for Web

The web version of the app should be built in SKIA mode to work correctly.

### To run:

```
flutter run -d Chrome --dart-define=FLUTTER_WEB_USE_SKIA=true
```

### To build:

```
flutter build web --release --dart-define=FLUTTER_WEB_USE_SKIA=true
```

Web support is generally patchy as this version is primarily used for testing and demos. 


# Contributors #

Code originally developed by: 

https://github.com/pgainullin
https://github.com/Arenukvern
https://github.com/IgorKrupenja


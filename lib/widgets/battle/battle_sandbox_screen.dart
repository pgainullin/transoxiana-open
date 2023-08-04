import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:transoxiana/components/battle/battle.dart';
import 'package:transoxiana/components/campaign/province.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/nation.dart';
import 'package:transoxiana/data/constants.dart';

Future<void> showBattleSandboxDialog({
  required final BuildContext context,
  required final TransoxianaGame game,
}) async {
  return showDialog(
    context: context,
    builder: (final _) {
      final theme = Theme.of(context);
      return SimpleDialog(
        backgroundColor: theme.cardColor,
        contentPadding: const EdgeInsets.only(bottom: 16),
        clipBehavior: Clip.hardEdge,
        children: [
          Builder(
            builder: (final context) {
              final theme = Theme.of(context);
              return AppBar(
                backgroundColor: theme.cardColor,
                titleTextStyle: theme.textTheme.bodyText2,
                leading: BackButton(
                  color: theme.textTheme.bodyText2?.color,
                ),
                title: const Text('Battle Sandbox'),
              );
            },
          ),
          SizedBox(
            height: 500,
            width: 500,
            child: BattleSandboxScreen(
              game: game,
            ),
          ),
        ],
      );
    },
  );
}

class BattleSandboxScreen extends StatefulWidget {
  const BattleSandboxScreen({
    required this.game,
    final Key? key,
  }) : super(key: key);
  final TransoxianaGame game;

  @override
  State<BattleSandboxScreen> createState() => _BattleSandboxScreenState();
}

class _BattleSandboxScreenState extends State<BattleSandboxScreen> {
  BattleMap? map;
  Province? province;
  Nation? playerNation;
  Nation? enemyNation;

  @override
  Widget build(final BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          BattleMapAutocomplete(
            game: widget.game,
            selected: map,
            onSelected: (final selectedMap) {
              if (province?.mapPath != selectedMap.path) {
                province = null;
              }
              map = selectedMap;
              setState(() {});
            },
          ),
          BattleProvinceAutocomplete(
            battleMap: map,
            onSelected: (final selectedProvince) {
              province = selectedProvince;
              if (map?.path != province?.mapPath) {
                map = tacticalMaps.firstWhereOrNull(
                  (final map) => map.path == province?.mapPath,
                );
              }
              setState(() {});
            },
            game: widget.game,
            selected: province,
          ),
          NationAutocomplete(
            nations: widget.game.campaignRuntimeData.playableNations,
            onSelected: (final newNation) {
              playerNation = newNation;
              setState(() {});
            },
            selected: playerNation,
            hintText: 'Select your nation',
          ),
          NationAutocomplete(
            nations: widget.game.campaignRuntimeData.nonPlayableNations,
            onSelected: (final newNation) {
              enemyNation = newNation;
              setState(() {});
            },
            selected: playerNation,
            hintText: 'Select enemy nation',
          ),
          // TODO(arenukvern): add translation
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              BattleStandaloneLoader(game: widget.game).start(
                context: context,
                playerNation: playerNation,
                enemyNation: enemyNation,
                province: province,
              );
            },
            child: const Text('Start Battle'),
          ),
        ],
      ),
    );
  }
}

class NationAutocomplete extends StatelessWidget {
  const NationAutocomplete({
    required this.nations,
    required this.onSelected,
    required this.selected,
    required this.hintText,
    final Key? key,
  }) : super(key: key);
  final Iterable<Nation> nations;
  final ValueChanged<Nation> onSelected;
  final Nation? selected;
  final String hintText;
  @override
  Widget build(final BuildContext context) {
    return ListTile(
      title: Autocomplete<Nation>(
        onSelected: onSelected,
        optionsBuilder: (final textEditingValue) {
          return nations.where(
            (final nation) => nation.name.contains(textEditingValue.text),
          );
        },
        displayStringForOption: (final nation) => nation.name,
      ),
      subtitle: Text(hintText),
    );
  }
}

class BattleMapAutocomplete extends ReactiveStatelessWidget {
  const BattleMapAutocomplete({
    required this.game,
    required this.onSelected,
    required this.selected,
    final Key? key,
  }) : super(key: key);
  final TransoxianaGame game;
  final ValueChanged<BattleMap> onSelected;
  final BattleMap? selected;
  @override
  Widget build(final BuildContext context) {
    return ListTile(
      title: Autocomplete<BattleMap>(
        onSelected: onSelected,
        optionsBuilder: (final textEditingValue) => tacticalMaps.where(
          (final map) => map.containsValue(textEditingValue),
        ),
        displayStringForOption: (final map) => map.title,
      ),
      subtitle: const Text('Select Map'),
    );
  }
}

class BattleProvinceAutocomplete extends ReactiveStatelessWidget {
  const BattleProvinceAutocomplete({
    required this.game,
    required this.onSelected,
    required this.selected,
    required this.battleMap,
    final Key? key,
  }) : super(key: key);
  final TransoxianaGame game;
  final ValueChanged<Province> onSelected;
  final Province? selected;
  final BattleMap? battleMap;

  @override
  Widget build(final BuildContext context) {
    return ListTile(
      title: Autocomplete<Province>(
        onSelected: onSelected,
        optionsBuilder: (final textEditingValue) =>
            game.campaignRuntimeData.provinces.values.where((final province) {
          final pathIsChosen = battleMap?.path != null;
          if (pathIsChosen) {
            final hasMap = province.mapPath == battleMap?.path;
            if (!hasMap) return false;
          }
          if (textEditingValue.text.isEmpty) return true;
          return province.name
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        }),
        displayStringForOption: (final province) => province.name,
      ),
      subtitle: const Text('Select province'),
    );
  }
}

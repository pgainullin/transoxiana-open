import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:simple_rich_text/simple_rich_text.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:transoxiana/components/battle/battle.dart';
import 'package:transoxiana/components/campaign/campaign.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/nation.dart';
import 'package:transoxiana/data/campaign_data_source.dart';
import 'package:transoxiana/data/tutorial_settings/tutorial_settings.dart';
import 'package:transoxiana/data/tutorials/main_menu_tutorial_steps.g.dart';
import 'package:transoxiana/generated/l10n.dart';
import 'package:transoxiana/widgets/base/dialogues.dart';
import 'package:transoxiana/widgets/base/rounded_border_container.dart';
import 'package:transoxiana/widgets/tutorial/tutorial.dart';
import 'package:transoxiana/widgets/ui_constants.dart';
import 'package:tutorial/tutorial.dart';
import 'package:utils/utils.dart';

const _listTilePadding = EdgeInsets.symmetric(vertical: 6, horizontal: 16);

class MainMenu extends ReactiveStatelessWidget {
  const MainMenu({required this.game, final Key? key}) : super(key: key);
  final TransoxianaGame game;

  List<Widget> getButtons() {
    final List<Widget> buttons = [];
    final latestSave = game.latestSave;
    final autosaves = game.campaignSortedSavesBuffer.autosaves;
    final quickSave = game.campaignSortedSavesBuffer.quickSave;
    if (latestSave != null) {
      Widget buildContinueButton(final CampaignSaveData save) =>
          _ContinueCampaignButton(
            game: game,
            save: save,
          );
      Widget buildQuickLoadButton() => _ContinueCampaignButton(
            game: game,
            save: quickSave,
            title: S.current.quickLoad,
          );

      if (latestSave == quickSave &&
          game.campaignRuntimeData.id == quickSave?.id) {
        buttons.add(buildContinueButton(latestSave));
      } else {
        buttons
          ..add(buildContinueButton(autosaves.first))
          ..add(buildQuickLoadButton());
      }
    }

    buttons
      ..add(
        TutorialStepState(
          game: game,
          tutorialSteps: [
            TutorialStep.fromStaticJson(
              json: MainMenuTutorialActionsSteps
                  .current.mainMenuCampaignButton.json,
            ).copyWith(
              title: MainMenuTutorialActionsSteps.current.mainMenuCampaignButton
                  .title(player: 'wise player'),
            )
          ],
          key: TutorialKeys.mainMenuCampaignTutorialButton,
          child: _StartCampaignWidget(game: game),
        ),
      )
      ..add(_QuickSaveButton(game: game))
      ..add(_SavesButton(game: game))
      ..add(debugMode ? _BattleSandboxButton(game: game) : Container())
      //settings
      //DLCs
      ..addAll([
        TutorialStepState(
          game: game,
          tutorialSteps: [
            TutorialStep.fromStaticJson(
              json: MainMenuTutorialActionsSteps
                  .current.mainMenuBattleButton.json,
            )
          ],
          key: TutorialKeys.mainMenuBattleTutorialButton,
          child: _StartRandomBattleButton(game: game),
        ),
        _CreditsButton(game: game),
        if (debugMode)
          TutorialOverlaySwitch(
            padding: _listTilePadding,
            text: 'Open tutorial',
            game: game,
            mode: TutorialModes.mainMenu,
          )
        else
          Container(),
      ]);
    return buttons;
  }

  @override
  Widget build(final BuildContext context) {
    log('Main menu rebuilding');

    final Size screenSize = MediaQuery.of(context).size;
    final double width = math.max(screenSize.width / 2, 200.0);
    final double height = math.max(screenSize.height * 0.85, 300.0);

    final List<Widget> buttons = getButtons();

    return Card(
      color: Theme.of(context).primaryColor.withAlpha(125),
      child: Stack(
        children: [
          SizedBox(
            height: screenSize.height,
            width: screenSize.width,
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: (screenSize.width - width) / 2,
            top: (screenSize.height - height) / 2,
            child: MenuBox(
              width: width,
              height: height,
              child: ListView.separated(
                shrinkWrap: true,
                separatorBuilder: (final _, final index) => const Divider(
                  thickness: 3.0,
                  height: 3,
                ),
                itemBuilder: (final _, final index) => buttons[index],
                itemCount: buttons.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StartCampaignWidget extends StatefulWidget {
  const _StartCampaignWidget({required this.game, final Key? key})
      : super(key: key);
  final TransoxianaGame game;
  @override
  _StartCampaignWidgetState createState() => _StartCampaignWidgetState();
}

class _StartCampaignWidgetState extends State<_StartCampaignWidget> {
  Nation? _selectedNation;
  bool _expandedSettings = false;

  TransoxianaGame get game => widget.game;

  void setNation(final Nation? nation) {
    _selectedNation = nation;
    setState(() {});
  }

  void toggleSettingsPanel(final int _, final bool __) {
    _expandedSettings = !_expandedSettings;
    setState(() {});
  }

  Future<void> startCampaign(final BuildContext context) async =>
      CampaignLoader(game: game).start(
        context: context,
        playerNation: _selectedNation,
      );

  @override
  Widget build(final BuildContext context) {
    return ListTile(
      contentPadding: _listTilePadding,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextButton(
            key: const Key('startCampaignButton'),
            onPressed: () => startCampaign(context),
            style: TextButton.styleFrom(
              backgroundColor: UiColors.brownWood,
              minimumSize: const Size(200, 75),
              elevation: 6,
            ),
            child: Text(
              S.of(context).startCampaign,
              style: Theme.of(context).textTheme.headline3?.copyWith(
                    color: UiColors.yellowPapyrus,
                  ),
            ),
          ),
          const Divider(),
          Center(
            child: SimpleRichText(
              game.campaignRuntimeData.narrative?.campaignTitle ?? '',
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          const Divider(),
          SimpleRichText(
            game.campaignRuntimeData.narrative?.menuIntroText ?? '',
            style: Theme.of(context).textTheme.bodyText2,
            textAlign: TextAlign.justify,
          ),
          const Divider(),
        ],
      ),
      subtitle: _NationSelectorWidget(
        game: game,
        onChanged: setNation,
        nation: _selectedNation,
        expanded: _expandedSettings,
        expansionCallback: toggleSettingsPanel,
      ),
    );
  }
}

class _NationSelectorWidget extends StatelessWidget {
  const _NationSelectorWidget({
    required this.game,
    required this.onChanged,
    required this.nation,
    required this.expansionCallback,
    required this.expanded,
    final Key? key,
  }) : super(key: key);
  final ValueChanged<Nation?> onChanged;
  final TransoxianaGame game;
  final Nation? nation;
  final ExpansionPanelCallback? expansionCallback;
  final bool expanded;
  @override
  Widget build(final BuildContext context) {
    final List<Widget> nationWidgets = game.campaignRuntimeData.playableNations
        .map(
          (final e) => ListTile(
            onTap: () => onChanged(e),
            title: Text(
              e.name,
              style:
                  Theme.of(context).textTheme.headline5!.apply(color: e.color),
            ),
            subtitle: SimpleRichText(
              game.campaignRuntimeData.narrative?.objectives[game
                      .campaignRuntimeData.playableNations
                      .toList()
                      .indexOf(e)] ??
                  '',
              style: Theme.of(context).textTheme.bodyText2,
            ),
            trailing: Radio<Nation>(
              value: e,
              groupValue: nation,
              onChanged: onChanged,
            ),
          ),
        )
        .toList()
      ..add(
        ListTile(
          onTap: () => onChanged(null),
          title: Text(
            S.of(context).randomNation,
            style: Theme.of(context).textTheme.headline5,
          ),
          trailing: Radio<Nation?>(
            value: null,
            groupValue: nation,
            onChanged: onChanged,
          ),
        ),
      );

    return ExpansionPanelList(
      expansionCallback: expansionCallback,
      children: [
        ExpansionPanel(
          canTapOnHeader: true,
          isExpanded: expanded,
          body: Column(
            children: nationWidgets,
          ),
          headerBuilder: (final context, final isExpanded) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                isExpanded
                    ? S.of(context).setSettingsColon
                    : S.of(context).customCampaignSettings,
                style: Theme.of(context).textTheme.headline4,
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Button to open [BattleSandboxScreen]
class _BattleSandboxButton extends StatelessWidget {
  const _BattleSandboxButton({required this.game, final Key? key})
      : super(key: key);
  final TransoxianaGame game;

  @override
  Widget build(final BuildContext context) {
    return ListTile(
      contentPadding: _listTilePadding,
      title: Text(
        S.current.battleSandbox,
        textAlign: TextAlign.center,
        // S.of(context).quickLoad,
        style: Theme.of(context).textTheme.headline3,
      ),
      onTap: () => game.navigator.showBattleSandboxScreen(
        game: game,
        context: context,
      ),
    );
  }
}

/// Button for navigation to [LoadScreen]
class _SavesButton extends StatelessWidget {
  const _SavesButton({required this.game, final Key? key}) : super(key: key);
  final TransoxianaGame game;

  @override
  Widget build(final BuildContext context) {
    return ListTile(
      contentPadding: _listTilePadding,
      title: Text(
        S.of(context).savedGames,
        textAlign: TextAlign.center,
        // S.of(context).quickLoad,
        style: Theme.of(context).textTheme.headline3,
      ),
      onTap: () => game.navigator.showSavesLoadScreen(
        game: game,
        context: context,
      ),
    );
  }
}

class _QuickSaveButton extends StatelessWidget {
  const _QuickSaveButton({required this.game, final Key? key})
      : super(key: key);
  final TransoxianaGame game;

  @override
  Widget build(final BuildContext context) {
    if (!game.campaignRuntimeData.isCampaignStarted) return const SizedBox();
    return ListTile(
      contentPadding: _listTilePadding,
      title: Text(
        S.current.quickSave,
        textAlign: TextAlign.center,
        // S.of(context).quickLoad,
        style: Theme.of(context).textTheme.headline3,
      ),
      onTap: () async {
        await asyncInfoDialog(
          context,
          'Saved',
          'To load your game use Quick Load button',
        );
        await CampaignLoader(game: game)
            .saveRuntime(reservedId: SaveReservedIds.quickSave);
      },
    );
  }
}

/// loads or just continues latest loaded campaign
class _ContinueCampaignButton extends ReactiveStatelessWidget {
  const _ContinueCampaignButton({
    required this.save,
    required this.game,
    final Key? key,
    this.title,
  }) : super(key: key);
  final TransoxianaGame game;
  final CampaignSaveData? save;
  final String? title;
  @override
  Widget build(final BuildContext context) {
    final latestSave = save;
    if (latestSave == null) return const SizedBox();

    return ListTile(
      contentPadding: _listTilePadding,
      onTap: () async {
        /// if save is latest running game then just
        /// continue game without loading{
        ///
        /// But if it's not - then load save
        if (latestSave.id == game.campaignRuntimeData.id) {
          if (game.useSaveToStart) {
            game.useSaveToStart = false;
            switch (latestSave.sourceType) {
              case CampaignDataSourceType.campaign:
                await CampaignLoaderRunner(
                  context: context,
                  game: game,
                  saveSource: latestSave,
                  sourceType: GameLoaderSource.save,
                ).postStart();
                break;
              case CampaignDataSourceType.battle:
                await BattleLoaderRunner(
                  context: context,
                  game: game,
                  saveSource: latestSave,
                  sourceType: GameLoaderSource.save,
                ).postStart();
                break;
              default:
                throw UnimplementedError('latestSave.sourceType');
            }
          } else {
            game.hideMainMenu();
          }
        } else {
          switch (latestSave.sourceType) {
            case CampaignDataSourceType.campaign:
              await CampaignLoader(game: game).continueFrom(
                source: latestSave,
                context: context,
              );
              break;
            case CampaignDataSourceType.battle:
              await BattleStandaloneLoader(game: game).continueFrom(
                source: latestSave,
                context: context,
              );
              break;
            default:
              throw UnimplementedError('latestSave.sourceType');
          }
        }
      },
      title: Text(
        title ?? S.of(context).continueCampaign,
        style: Theme.of(context).textTheme.headline3,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _StartRandomBattleButton extends StatelessWidget {
  const _StartRandomBattleButton({required this.game, final Key? key})
      : super(key: key);
  final TransoxianaGame game;
  @override
  Widget build(final BuildContext context) {
    return ListTile(
      contentPadding: _listTilePadding,
      onTap: () async {
        await BattleStandaloneLoader(game: game).start(
          context: context,
          playerNation: game.campaignRuntimeData.nations.values.randomElement(),
        );
      },
      title: Text(
        S.of(context).randomBattle,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headline3,
      ),
    );
  }
}

/// Button for navigation to [CreditsScreen]
class _CreditsButton extends StatelessWidget {
  const _CreditsButton({required this.game, final Key? key}) : super(key: key);
  final TransoxianaGame game;

  @override
  Widget build(final BuildContext context) {
    return ListTile(
      contentPadding: _listTilePadding,
      onTap: () => game.navigator.showCreditsScreen(context),
      title: Text(
        S.of(context).credits,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headline3,
      ),
    );
  }
}

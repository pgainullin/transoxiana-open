part of 'campaign.dart';

extension CampaignEventsExt on Campaign {
  Future<void> onTap(final TapDownInfo info) async {
    bool isHandled = false;

    final gameData = game.temporaryCampaignDataService;

    if (!gameData.state.inCommand) return;
    final translatedVector2Position =
        game.camera.screenToWorld(info.eventPosition.widget);
    final translatedOffsetPosition = translatedVector2Position.toOffset();

    // log('${translatedPosition}');

    final selectedArmies = Map.fromEntries(
      game.campaignRuntimeData.armies.values
          .where(
            (final army) =>
                army.location?.isVisibleToPlayer == true &&
                army.touchRect?.contains(translatedOffsetPosition) == true,
          )
          .map((final e) => MapEntry(e.id, e)),
    );

    final previousSelectedArmy = gameData.state.selectedArmy;

    // prioritise selecting own armies
    final selectedArmy = selectedArmies.values
            .where((final element) => element.nation == game.player)
            .firstOrNull ??
        selectedArmies.values.firstOrNull;

    if (previousSelectedArmy != null) {
      if (previousSelectedArmy.nation == game.player) {
        if (selectedArmy == previousSelectedArmy) {
          //deselect
          await selectArmy(null);
          isHandled = true;
        } else if (selectedArmy != null) {
          //order to this army's province (can be friendly or not)
          await gameData.state.selectedArmy
              ?.orderToProvince(selectedArmy.location!);
          _selectProvince(selectedArmy.location);
          isHandled = true;
        } else {
          /// send army to another province
          isHandled = false;
        }
      } else {
        if (selectedArmy == null) {
          //deselect
          await selectArmy(null);
        } else if (gameData.state.selectedArmy == selectedArmy) {
          //deselect
          await selectArmy(null);
          isHandled = true;
        } else {
          await selectArmy(selectedArmy);
          _selectProvince(selectedArmy.location);
          isHandled = true;
        }
      }
    } else {
      await selectArmy(selectedArmy);
      if (selectedArmy != null) {
        _selectProvince(selectedArmy.location);
        isHandled = true;
      }
    }

    if (isHandled == false) {
      double shortestDistance = double.infinity;
      Province? shortestDistanceProvince;

      for (final province in provinces) {
        if (province.touchRect.contains(translatedOffsetPosition)) {
          // log('touched ${province.name}');
          if ((translatedOffsetPosition - province.touchRect.center).distance <
              shortestDistance) {
            shortestDistance =
                (province.touchRect.center - translatedOffsetPosition).distance;
            shortestDistanceProvince = province;
          }
        }
      }

      if (shortestDistanceProvince != null) {
        _selectProvince(shortestDistanceProvince);
        if (gameData.state.selectedArmy != null &&
            gameData.state.selectedArmy?.nation == game.player) {
          if (shortestDistanceProvince !=
              gameData.state.selectedArmy?.location) {
            //order to another province
            await gameData.state.selectedArmy!
                .orderToProvince(shortestDistanceProvince);
          } else {
            //touched current location = cancel move
            await gameData.state.selectedArmy!.cancelOrders();
          }
        }
        isHandled = true;
      }
    }

    if (isHandled == false &&
        (gameData.state.selectedArmy != null ||
            gameData.state.selectedProvince != null)) await selectArmy(null);

    // this.visible = false;
    // game.startBattle(game.getRandomMap());
  }

  void clearSelectedArmyAndProvince(){
    game.temporaryCampaignData.selectedArmy = null;
    _selectProvince(null);
  }

  void clearSelectionAndNotify() {
    clearSelectedArmyAndProvince();
    game.temporaryCampaignDataService.notify();
  }

  /// currently creates a new event triggered on selection of the player's army.
  Future<void> selectArmy(final Army? army) async {
    final resolvedArmy = army;
    // gameData.state.selectedArmy = null;
    clearSelectionAndNotify();
    if (resolvedArmy == null) return;
    // gameData.state.selectedArmy = army;
    game.temporaryCampaignData.selectedArmy = resolvedArmy;

    _selectProvince(resolvedArmy.location);
    if (resolvedArmy.nation == game.player) {
      resolvedArmy.pathSelector.showFor(1.0);
    }
    await processArmySelectionEvents(resolvedArmy);
  }

  Future<void> processArmySelectionEvents(final Army army) async {
    if (army.nation == game.player) {
      if (!temporaryData.armyEventCreated) {
        await addArmySelectionTutorialEvent();
      }

      final newEvents = getArmySelectEvents();
      await EventResolver.evaluateEvents(
        newEvents: newEvents,
        eventsStack: game.player!.events,
        trigger: EventTriggerType.selection,
      );
    }
  }

  Iterable<Event> getArmySelectEvents() => game.player!.events.where(
        (final event) =>
            event.condition.type == EventConditionType.campaignSelectPlayerArmy,
      );

  // TODO(arenukvern): make events permanent via service
  static Event? armySelectionTutorialEvent;

  Future<void> addArmySelectionTutorialEvent() async {
    armySelectionTutorialEvent ??=
        await EventData.fromConditionAndConsequenceTypes(
      condition: EventConditionType.campaignSelectPlayerArmy,
      consequence: EventConsequenceType.campaignPlayerArmySelected,
      nationId: game.player!.id,
      trigger: EventTriggerType.selection,
    ).toEvent(game: game);
    game.player!.events.add(armySelectionTutorialEvent!);
    temporaryData.armyEventCreated = true;
  }

  /// Used to reset the triggered status of any player army selection events
  /// ensuring tutorials based on that event run again.
  void resetArmySelectionEvents() {
    for (final event in game.player!.events.where(
      (final element) =>
          element.condition.type == EventConditionType.campaignSelectPlayerArmy,
    )) {
      event.data.triggered = false;
    }
  }

  void _selectProvince(final Province? province) {
    final oldSelection = game.temporaryCampaignData.selectedProvince;
    game
      ..temporaryCampaignData.selectedProvince = province
      ..temporaryCampaignDataService.notify();

    if (province != null) province.renderFilter.updateFilters();

    if (oldSelection != null) oldSelection.renderFilter.updateFilters();
  }
}

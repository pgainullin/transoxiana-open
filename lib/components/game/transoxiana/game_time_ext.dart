part of game;

extension GameTimeExtension on TransoxianaGame {
  void resetTimer({final bool showPauseOverlayAtEnd = true}) {
    campaignRuntimeData.gameTime = 0.0;
    campaignRuntimeDataService.notify();

    pause(showPauseOverlayAtEnd: showPauseOverlayAtEnd);
  }

  Future<void> pause({
    final bool inCommand = true,
    final bool setCommand = true,
    final bool showPauseOverlayAtEnd = true,
  }) async {
    //if in campaign or in a non-AI battle, give player control
    // if (campaignRuntimeData.inCampaign ||
    //     (campaignRuntimeData.isBattleStarted &&
    //         activeBattle?.isAiBattle == false)) {}
    if (setCommand) temporaryCampaignData.inCommand = inCommand;
    temporaryCampaignData.isPaused = true;
    temporaryCampaignDataService.notify();

    await singleTrackSfxController.forceStopAll();

    // set the countdown timer back back to max value
    reactiveTimer.state = GameConsts.secondsToCommand;

    // if in battle that is in fast forward, avoid the pause overlay
    if (campaignRuntimeData.isBattleStarted &&
        (activeBattle?.fastForwardEnabled == true ||
            activeBattle?.isAiBattle == true)) {
      return;
    }

    if (inCommand && setCommand && showPauseOverlayAtEnd) showPauseOverlay();
    // addRegisteredOverlay(
    //     'PauseOverlay', PauseOverlay(removeCallback: removePauseOverlay));
  }

  void unpause() {
    temporaryCampaignData
      ..isPaused = false
      ..inCommand = false
      ..selectedUnit = null;
    temporaryCampaignDataService.notify();
  }
}

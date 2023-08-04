import 'package:flutter/material.dart';
import 'package:transoxiana/components/battle/battle.dart';
import 'package:transoxiana/components/campaign/campaign.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/data/campaign_data_source.dart';

class LatestGameLoader {
  LatestGameLoader({
    required this.game,
    required this.context,
  });
  final TransoxianaGame game;
  final BuildContext context;

  Future<void> run() async {
    final latestSave = game.latestSave;
    if (latestSave != null) {
      game.useSaveToStart = true;
      if (latestSave.sourceType == CampaignDataSourceType.campaign) {
        await CampaignLoaderRunner(
          context: context,
          game: game,
          saveSource: latestSave,
          sourceType: GameLoaderSource.save,
        ).preload();
      } else {
        await BattleLoaderRunner(
          context: context,
          game: game,
          saveSource: latestSave,
          sourceType: GameLoaderSource.save,
        ).preload();
      }
    } else {
      /// load template data to configure first game
      await game.loadRuntimeData(
        dataSource: await game.temporaryCampaignData.getDataTemplate(),
      );
      game.useTemplateToStart = true;
    }
  }
}

part of 'campaign.dart';

extension CampaignLoadingExt on Campaign {
  void postLoadScaling({final Province? province}) {
    game.mapCamera.setMinZoom();

    if (province != null) {
      game.mapCamera.toProvince(province);
    } else {
      if (game.campaignRuntimeData.armies.values
          .where(
            (final element) =>
                element.nation == game.player && element.location != null,
          )
          .isEmpty) {
        log(
          'ERROR, no armies found for Player: ${game.player} \n'
          '(${game.player.hashCode}), \n'
          'Armies set: ${game.campaignRuntimeData.armies.values.map((final e) => '${e.nation} ${e.nation.hashCode}').join(',')}',
        );
      } else {
        final Army playerArmy =
            game.campaignRuntimeData.armies.values.firstWhere(
          (final army) => army.nation == game.player && army.location != null,
        );
        log('Moving camera to ${playerArmy.name} located in ${playerArmy.location}');

        game.mapCamera.toArmy(playerArmy);
      }
    }
  }
}

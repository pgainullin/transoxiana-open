import 'dart:convert';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:transoxiana/components/battle/battle.dart';
import 'package:transoxiana/components/battle/node.dart';
import 'package:transoxiana/components/battle/unit.dart';
import 'package:transoxiana/components/campaign/campaign.dart';
import 'package:transoxiana/components/campaign/province.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/army.dart';
import 'package:transoxiana/data/campaign_data_source.dart';
import 'package:universal_io/io.dart';

int logLength = 0; //TODO: fix this hack
bool resultCalled = false;
Future<void> headlessUpdate(final TransoxianaGame game) async {
  //runner for AI training without anything being rendered
  final temporaryCampaignDataService = game.temporaryCampaignDataService;
  final savableCampaignDataService = game.campaignRuntimeDataService;
  final ReactiveModel<double> reactiveTimer = RM.get<double>('reactiveTimer');

  const double campaignPeriod =
      0.5; //how much game time passes between updates

  // if (game.log.length > logLength) {
  //   log(game.log.last);
  //   logLength = game.log.length;
  // }
  final savableCampaignData = savableCampaignDataService.state;

  if (savableCampaignData.currentYear < 1250) {
    if (game.campaignRuntimeData.inCampaign) {
      //run campaign
      log(
        '${savableCampaignData.currentDate} - '
        '${savableCampaignData.gameTime} - '
        '${temporaryCampaignDataService.state.inCommand}',
      );

      /// AI campaign orders function refers to the relevant API call
      game.campaign?.endTurn();

      for (double i = 0.0;
          i <= GameConsts.secondsToCommand;
          i += campaignPeriod) {
        savableCampaignData.gameTime += campaignPeriod;
        game.campaign?.update(campaignPeriod);
      }
      await game.campaign?.processEngagements();
      await game.campaign?.advanceCampaignTime();
      await game.campaign?.seasonStartReport();
    } else {
      //TODO: refactor to use the Ai-to-Ai battle code in Battle class itself.
      //run battle
      final effectiveBattle = game.activeBattle;
      if (effectiveBattle == null) {
        throw ArgumentError.notNull('game.activeBattle');
      }
      final aiBattleUpdateTime = Battle.aiBattleUpdateTime.inSeconds.toDouble();
      effectiveBattle.update(aiBattleUpdateTime);
      savableCampaignData.gameTime += aiBattleUpdateTime;

      if (savableCampaignData.gameTime > 200.0 && game.activeBattle != null) {
        dumpBattleData(savableCampaignData);
      }

      if (reactiveTimer.state <= 0.0) {
        if (effectiveBattle.armies.length < 2) {
          effectiveBattle.battleOutcomeCompleter.complete();
        } else {
          await effectiveBattle.turnStartCallback();

          // TODO: ensure AI calls the "player" too - this will be broken due stream logic
          effectiveBattle.endTurn();
          reactiveTimer.state = GameConsts.secondsToCommand;
        }
      } else {
        reactiveTimer.state -= aiBattleUpdateTime;
      }
    }
  } else {
    if (resultCalled == false) {
      resultCalled = true;
      await apiGetRequest(
        'report_outcome',
        Map.fromEntries([MapEntry('outcome', 127.toString())]),
      );
      //TODO: fix infinite loop if get fails to return 200
      exit(127);
    }
  }
}

Future<void> getCampaignOrdersFromApi(
    final CampaignRuntimeData runtimeData,) async {
  // try {
  int index = 0;
  final List<dynamic> apiOrders = jsonDecode(
    await apiPostRequest('post_campaign_save', jsonEncode(runtimeData)),
  ) as List<dynamic>;
  if (apiOrders != null) {
    for (final element in apiOrders) {
      // TODO(arenukvern): fixme
      final Army army = runtimeData.armies.values.toList()[index];

      //_army.nation != game.player
      //for AI training purposes ignore who the player is
      if (army.location != null && army.nation == runtimeData.player) {
        //only accept orders for the "player"
        final String orderedProvinceName = element as String;
        final Province? province =
            runtimeData.provinces.values.firstWhereOrNull(
          (final element) =>
              element.name.toLowerCase() == orderedProvinceName.toLowerCase(),
        );

        if (army.location != province && province != null) {
          log('***to_api*** orders ${army.name} to ${province.name}');
          await army
              .orderToProvince(province); //TODO: avoid overwriting progress
          army.data.siegeMode = false; //TODO: get this from the API
        }
      }

      index += 1;
    }
  } else {
    log('API returned null orders');
  }
  // } catch (error) {
  //   log(error.toString());
  // }
}

Future<void> getBattleOrdersFromApi(
    final CampaignRuntimeData runtimeData,) async {
  // try {
  final effectiveBattle = runtimeData.activeBattle;
  final List<dynamic> orders = jsonDecode(
    await apiPostRequest('post_battle_turn', jsonEncode(effectiveBattle)),
  ) as List<dynamic>;
  if (effectiveBattle != null &&
      !effectiveBattle.battleOutcomeCompleter.isCompleted &&
      effectiveBattle.nodes.isNotEmpty) {
    int index = 0;
    final List<Unit> unitList = runtimeData.units.values
        .toList(); //TODO: ensure units are never deleted from game.units
    final List<Node> nodeList = effectiveBattle.nodes;
    for (final element in orders) {
      final Unit unit = unitList.elementAt(index);

      //_army.nation != game.player
      //for AI training purposes ignore who the player is
      final int orderedNodeIndex = element as int;
      final Node node = nodeList[orderedNodeIndex];
      if (unit.location != null &&
          unit.location != node &&
          unit.nation == runtimeData.player &&
          unit.isFighting) {
        //only accept orders for the "player"
        log('***to_api*** orders ${unit.name} to $node');
        unit.orderToNode(node); //TODO: avoid overwriting progress
      }

      index += 1;
    }
  }
  // } catch (error) {
  //   log(error.toString());
  // }
}

Future<String> apiPostRequest(
    final String endPoint, final String jsonString,) async {
  // const String url =
  //     'http://10.0.2.2/put_campaign_save';
  // HttpClient httpClient = new HttpClient(); //TODO: consider reusing
  // HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
  // request.headers.set('content-type', 'application/json');
  // request.add(utf8.encode(json.encode(jsonMap)));
  // HttpClientResponse response = await request.close();
  // // todo - you should check the response.statusCode
  // String reply = await response.transform(utf8.decoder).join();
  // httpClient.close();

  log('Starting POST request to $endPoint'); //with data: $jsonString

  const String localhost = kIsWeb ? 'localhost' : '10.0.2.2';
  final Uri uri = Uri.dataFromString(
    'http://$localhost:8000/$endPoint/?gameTimeStamp=${gameTimeStamp.toString()}',
  );

  final http.Response response = await http
      .post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonString,
      )
      .timeout(const Duration(milliseconds: 10000));
  if (response.statusCode == 200) {
    // log(response.body);
    return response.body;
  } else {
    throw 'HTTP POST request failed with code ${response.statusCode}';
  }
}

Future<String> apiGetRequest(
  final String endPoint,
  final Map<String, String> params,
) async {
  const String localhost = kIsWeb ? 'localhost' : '10.0.2.2';

  final String requestString =
      'http://$localhost:8000/$endPoint/?gameTimeStamp=${gameTimeStamp.toString()}${params.isNotEmpty ? '&${params.map((final key, final value) => MapEntry(key, '$key=$value')).values.join('&')}' : ''}';
  final Uri uri = Uri.dataFromString(requestString);

  log('Starting GET request: $requestString');
  final http.Response response = await http.get(
    uri,
    headers: <String, String>{
      // 'Content-Type': 'application/json; charset=UTF-8',
    },
    // body: jsonString,
  ).timeout(const Duration(milliseconds: 5000));
  if (response.statusCode == 200) {
    log(response.body);
    return response.body;
  } else {
    throw 'HTTP GET request failed with code ${response.statusCode}';
  }
}

void dumpBattleData(final CampaignRuntimeData game) {
  log('Battle timed out in ${game.activeBattle?.province.name} - dumping unit data:');
  for (final army in game.activeBattle?.armies ?? <Army>{}) {
    log('Nation: ${army.nation.name}, Army: ${army.name}');
    for (final unit in army.units) {
      log('${unit.name} at ${unit.army?.location?.id} isFighting = ${unit.isFighting}');
    }
  }
  game.activeBattle?.battleOutcomeCompleter.complete();
}

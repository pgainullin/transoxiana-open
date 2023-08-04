library game_stream;

import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:transoxiana/components/battle/battle.dart';
import 'package:transoxiana/components/campaign/campaign.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/data/campaign_data_source.dart';

part 'game_stream_event.dart';
part 'game_stream_runner.dart';
part 'turn_timer.dart';

class GameStream {
  StreamController<GameStreamEvent> controller = StreamController.broadcast();
  final subscriptions = LinkedHashMap<ValueChanged<GameStreamEvent>,
      StreamSubscription<GameStreamEvent>?>.identity();

  Stream<GameStreamEvent> get stream => controller.stream;

  void add(final GameStreamEvent event) {
    controller.add(event);
  }

  void listen(final ValueChanged<GameStreamEvent> listener) {
    subscriptions[listener] = stream.listen(listener);
  }

  void unlisten(final ValueChanged<GameStreamEvent> listener) {
    final subscription = subscriptions[listener];
    if (subscription != null) {
      subscription.cancel();
    }
    subscriptions.remove(listener);
  }

  void broadcast() {
    close();
    controller = StreamController.broadcast();
  }

  void close() {
    controller.close();
    subscriptions.clear();
  }
}

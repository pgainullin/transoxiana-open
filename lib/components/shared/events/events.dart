import 'dart:async';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:transoxiana/components/campaign/province.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/army.dart';
import 'package:transoxiana/components/shared/nation.dart';
import 'package:transoxiana/data/campaign_data_source.dart';
import 'package:transoxiana/generated/l10n.dart';
import 'package:transoxiana/widgets/base/dialogues.dart';
import 'package:utils/utils.dart';

part 'event.dart';
part 'event_condition.dart';
part 'event_consequence.dart';
part 'event_types.dart';
part 'eventful.dart';
part 'events.g.dart';

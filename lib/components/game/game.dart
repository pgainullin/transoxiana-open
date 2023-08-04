library game;

import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:transoxiana/components/battle/battle.dart';
import 'package:transoxiana/components/battle/battle_overlays.dart';
import 'package:transoxiana/components/battle/foreground.dart';
import 'package:transoxiana/components/battle/hex_tiled_component.dart';
import 'package:transoxiana/components/battle/unit.dart';
import 'package:transoxiana/components/campaign/campaign.dart';
import 'package:transoxiana/components/campaign/campaign_overlays.dart';
import 'package:transoxiana/components/campaign/province.dart';
import 'package:transoxiana/components/game/latest_game_loader.dart';
import 'package:transoxiana/components/game_stream/game_stream.dart';
import 'package:transoxiana/components/shared/army.dart';
import 'package:transoxiana/components/shared/background.dart';
import 'package:transoxiana/components/shared/components_render_priority.dart';
import 'package:transoxiana/components/shared/event_handlers/first_tutorial_event_handler.dart';
import 'package:transoxiana/components/shared/event_handlers/tutorial_event_handler_system.dart';
import 'package:transoxiana/components/shared/game_overlay.dart';
import 'package:transoxiana/components/shared/nation.dart';
import 'package:transoxiana/components/shared/shared_component_overlays.dart';
import 'package:transoxiana/components/shared/shared_overlays.dart';
import 'package:transoxiana/data/campaign_data_source.dart';
import 'package:transoxiana/data/temporary_game_data.dart';
import 'package:transoxiana/generated/l10n.dart';
import 'package:transoxiana/services/assets_loader.dart';
import 'package:transoxiana/services/audio/music.dart';
import 'package:transoxiana/services/audio/sfx.dart';
import 'package:transoxiana/services/debug_game_service.dart';
import 'package:transoxiana/services/python_interface.dart';
import 'package:transoxiana/services/save_service.dart';
import 'package:transoxiana/services/tutorial/tutorial_states.dart';
import 'package:transoxiana/widgets/base/dialogues.dart';
import 'package:transoxiana/widgets/base/flame_splash_screen.dart';
import 'package:transoxiana/widgets/battle/battle_sandbox_screen.dart';
import 'package:transoxiana/widgets/battle/loading_screen.dart';
import 'package:transoxiana/widgets/credits.dart';
import 'package:transoxiana/widgets/load_screen.dart';
import 'package:transoxiana/widgets/tutorial/tutorial.dart';
import 'package:transoxiana/widgets/ui_constants.dart';
import 'package:tutorial/tutorial.dart';
import 'package:universal_io/io.dart';
import 'package:utils/utils.dart';
import 'package:uuid/uuid.dart';

part 'abstract_battle_loader.dart';
part 'abstract_game_loader.dart';
part 'debug/army_view.dart';
part 'debug/battle_units_view.dart';
part 'debug/battle_view.dart';
part 'debug/camera_view.dart';
part 'debug/campaign_runtime_view.dart';
part 'debug/controls_view.dart';
part 'debug/debug_window.dart';
part 'debug/nation_view.dart';
part 'debug/province_view.dart';
part 'debug/saves_list.dart';
part 'debug/tutorial_view.dart';
part 'debug/unit_view.dart';
part 'debug_overlays.dart';
part 'game_loader_lifecycle.dart';
part 'map_camera/map_camera.dart';
part 'map_camera/map_camera_battle.dart';
part 'map_camera/map_camera_campaign.dart';
part 'map_camera/map_camera_movements.dart';
part 'map_camera/map_camera_positioning.dart';
part 'map_camera/map_camera_zoom.dart';
part 'transoxiana/game_abstract_state.dart';
part 'transoxiana/game_app.dart';
part 'transoxiana/game_battle_ext.dart';
part 'transoxiana/game_camera_mixin.dart';
part 'transoxiana/game_constants.dart';
part 'transoxiana/game_crud_mixin.dart';
part 'transoxiana/game_dimensions_mixin.dart';
part 'transoxiana/game_events_shortcuts_ext.dart';
part 'transoxiana/game_globals.dart';
part 'transoxiana/game_navigator.dart';
part 'transoxiana/game_overlays_mixin.dart';
part 'transoxiana/game_ref.dart';
part 'transoxiana/game_saves.dart';
part 'transoxiana/game_services.dart';
part 'transoxiana/game_shortcuts_ext.dart';
part 'transoxiana/game_time_ext.dart';
part 'transoxiana/game_widget.dart';
part 'transoxiana/transoxiana_game.dart';
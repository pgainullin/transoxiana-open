import 'package:flutter/widgets.dart';

/// Map to keep all global keys for tutorials
/// Key is enum, for example [CampaignTutorialActions.mainMenuCampaignButton]
typedef TutorialActionKeysMap<T> = Map<T, GlobalKey?>;

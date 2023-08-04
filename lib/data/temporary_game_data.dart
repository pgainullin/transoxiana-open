import 'dart:developer';

import 'package:transoxiana/components/battle/node.dart';
import 'package:transoxiana/components/battle/unit.dart';
import 'package:transoxiana/components/campaign/province.dart';
import 'package:transoxiana/components/shared/army.dart';
import 'package:transoxiana/components/shared/nation.dart';
import 'package:transoxiana/data/campaign_data_source.dart';

/// Holds dynamic gameplay data in memory.
///
/// Stores all game data that have temporary purpose only,
/// i.e. will be not saved/loaded from [Campaign] save
///
/// If you needed to add new savable data,
/// then use [CampaignSaveData]
class TemporaryGameData {
  TemporaryGameData({
    this.selectedNode,
    this.selectedUnit,
    this.selectedArmy,
    this.selectedProvince,
    this.overlayProvince,
    this.overlayArmy,
    this.winningNation,
    this.battleProvince,
    this.armyEventCreated = false,
    this.diplomacyMenuOpen = false,
    this.inCommand = true,
    this.isPaused = true,
    this.templateDataSource,
    this.unitTypesJson = '',
    this.armyTemplatesJson = '',
    this.campaignInitJson = '',
    this.provincesJson = '',
    final Map<String, CampaignSaveData>? campaignSaves,
    final Map<String, CampaignSaveData>? battleSaves,
  })  : campaignSaves = campaignSaves ?? {},
        battleSaves = battleSaves ?? {};

  Node? selectedNode;
  Unit? selectedUnit;
  Army? selectedArmy;
  Province? selectedProvince;

  // ************************************
  //       Templates start
  // ************************************
  String unitTypesJson;
  String armyTemplatesJson;
  String campaignInitJson;
  String provincesJson;

  /// template cache
  CampaignTemplateData? templateDataSource;

  /// On start it using cached template
  /// Next calls it recreating from jsons
  Future<CampaignTemplateData> getDataTemplate() async {
    CampaignTemplateData? template = templateDataSource;
    template ??= await CampaignTemplateData.fromNamedJson(
      armyTemplatesJson: armyTemplatesJson,
      campaignJson: campaignInitJson,
      provincesJson: provincesJson,
      unitTypesJson: unitTypesJson,
    );

    /// forcing to recreate template on next game start
    templateDataSource = null;

    return template;
  }
  // ************************************
  //       Templates end
  // ************************************

  final Map<Id, CampaignSaveData> campaignSaves;
  final Map<Id, CampaignSaveData> battleSaves;

  bool isPaused;

  /// This is used in tutorial
  bool armyEventCreated;

  /// This [provinceId] for [ArmyManagementOverlay] and any overlay
  Province? overlayProvince;

  /// This [armyId] for [UnitTrainingView] and any overlay
  Army? overlayArmy;

  bool diplomacyMenuOpen;

  /// used to communicate the winner in an AI battle
  Nation? winningNation;

  Province? battleProvince;
  bool inCommand;

  ///Returns copy with template params only
  TemporaryGameData reset() => TemporaryGameData(
        templateDataSource: templateDataSource,
        provincesJson: provincesJson,
        unitTypesJson: unitTypesJson,
        campaignInitJson: campaignInitJson,
        armyTemplatesJson: armyTemplatesJson,
        battleSaves: battleSaves,
        campaignSaves: campaignSaves,
      );

  void clearBattle() {
    log('GameData cleared');
    // selectedTile = null;
    // selectedSuperstructure = null;
    selectedNode = null;
    selectedUnit = null;
    selectedArmy = null;
    selectedProvince = null;
    winningNation = null;
    battleProvince = null;
  }

  void clearCampaign() {
    selectedNode = null;
    selectedUnit = null;
    selectedArmy = null;
    selectedProvince = null;
    winningNation = null;
    battleProvince = null;
    inCommand = true;
  }
}

part of 'campaign.dart';

/// Support class to ensure that class has [campaign]
abstract class CampaignRef {
  CampaignRef(this.campaign);

  /// This is the current used campaign.
  ///
  /// Usually User have a stack of [DataSource]s such as:
  /// [CampaignSaveData] and [CampaignTemplateData]
  ///
  /// When player choose to load or start new campaign,
  /// it should load related source to
  /// [_campaignRuntimeDataService] and [Campaign] should be
  /// started and loaded to this variable
  Campaign? campaign;
}

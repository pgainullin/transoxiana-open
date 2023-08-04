// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign_narrative.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CampaignNarrativeData _$CampaignNarrativeDataFromJson(
        Map<String, dynamic> json) =>
    CampaignNarrativeData(
      menuIntroText: json['menuIntroText'] as String,
      campaignTitle: json['campaignTitle'] as String,
      sentences: json['sentences'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CampaignNarrativeDataToJson(
        CampaignNarrativeData instance) =>
    <String, dynamic>{
      'menuIntroText': instance.menuIntroText,
      'campaignTitle': instance.campaignTitle,
      'sentences': instance.sentences,
    };

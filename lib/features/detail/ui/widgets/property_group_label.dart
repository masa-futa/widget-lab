import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// 仲間の名前。仲間を決めていない収録は「プロパティ」。
String groupLabel(AppLocalizations l10n, PropertyGroup? group) =>
    switch (group) {
      PropertyGroup.size => l10n.detailGroupSize,
      PropertyGroup.spacing => l10n.detailGroupSpacing,
      PropertyGroup.layout => l10n.detailGroupLayout,
      PropertyGroup.paint => l10n.detailGroupPaint,
      PropertyGroup.transform => l10n.detailGroupTransform,
      PropertyGroup.text => l10n.detailGroupText,
      PropertyGroup.behavior => l10n.detailGroupBehavior,
      PropertyGroup.content => l10n.detailGroupContent,
      null => l10n.detailGroupAll,
    };

/// 仲間のアイコン（選ぶ欄のカードと一覧のシートの見出し）。
IconData groupIcon(PropertyGroup? group) => switch (group) {
  PropertyGroup.size => Icons.aspect_ratio,
  PropertyGroup.spacing => Icons.padding,
  PropertyGroup.layout => Icons.align_horizontal_center,
  PropertyGroup.paint => Icons.palette_outlined,
  PropertyGroup.transform => Icons.transform,
  PropertyGroup.text => Icons.text_fields,
  PropertyGroup.behavior => Icons.touch_app_outlined,
  PropertyGroup.content => Icons.widgets_outlined,
  null => Icons.tune,
};

/// 補足のアイコン。
const referencesIcon = Icons.notes;

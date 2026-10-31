import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// [entry] の全プロパティを OFF にした設定（必須は DemoArgs が ON にする）。
Map<String, PropertySetting> allOff(WidgetEntry entry) => {
  for (final spec in entry.properties)
    spec.name: PropertySetting(on: false, value: spec.control.initial),
};

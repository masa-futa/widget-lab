import 'package:flutter/foundation.dart';
import 'package:widget_lab/catalog/model/genre.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// 詳細画面の状態。プレビュー・チップ・編集パネル・比較・コードで共有する。
final class DetailState {
  const DetailState({
    required this.entry,
    required this.genres,
    required this.settings,
    this.selected,
    this.comparing,
  });

  /// [entry] を開いたときの状態。
  DetailState.initial(this.entry, this.genres)
    : settings = entry.initialSettings(),
      selected = _firstSelected(entry),
      comparing = null;

  final WidgetEntry entry;

  /// [entry] が載るジャンル（説明のシートの印）。
  final List<Genre> genres;

  /// OFF にしても値は覚えておく。
  final Map<String, PropertySetting> settings;

  /// 編集パネルで選んでいるプロパティの名前。プロパティがなければ `null`。
  final String? selected;

  /// 比べているプロパティの名前。`null` は比較していない。
  final String? comparing;

  /// 選んでいるプロパティの定義。
  PropertySpec? get selectedSpec => _specOf(selected);

  /// 比べているプロパティの定義。比較していなければ `null`。
  PropertySpec? get comparingSpec => _specOf(comparing);

  /// 最初の値から1つでも変わった、または比較中（初期状態に戻すの活性）。
  /// 選び替えただけでは変わらない。
  bool get isModified =>
      comparing != null || !mapEquals(settings, entry.initialSettings());

  /// [name] のプロパティが最初の値のまま（既定に戻すの活性）。
  bool isDefault(String name) =>
      settings[name] == entry.initialSettings()[name];

  /// 比較の「付けた」（[on] が `true`）か「付けない」側の設定。
  /// 比べるプロパティだけ ON / OFF を変え、値とほかのプロパティはそのまま。
  /// 比較していなければ今の設定。
  Map<String, PropertySetting> settingsForSide({required bool on}) {
    final name = comparing;
    final setting = settings[name];
    if (name == null || setting == null) return settings;
    return {...settings, name: setting.copyWith(on: on)};
  }

  DetailState copyWith({
    Map<String, PropertySetting>? settings,
    String? selected,
    String? Function()? comparing,
  }) => DetailState(
    entry: entry,
    genres: genres,
    settings: settings ?? this.settings,
    selected: selected ?? this.selected,
    comparing: comparing != null ? comparing() : this.comparing,
  );

  PropertySpec? _specOf(String? name) =>
      entry.properties.where((spec) => spec.name == name).firstOrNull;

  /// 最初の ON のプロパティ。なければ最初のプロパティ。
  static String? _firstSelected(WidgetEntry entry) {
    final settings = entry.initialSettings();
    final properties = entry.properties;
    return (properties.where((spec) => spec.isOnIn(settings)).firstOrNull ??
            properties.firstOrNull)
        ?.name;
  }

  @override
  bool operator ==(Object other) =>
      other is DetailState &&
      other.entry == entry &&
      listEquals(other.genres, genres) &&
      mapEquals(other.settings, settings) &&
      other.selected == selected &&
      other.comparing == comparing;

  @override
  int get hashCode => Object.hash(
    entry,
    Object.hashAll(genres),
    Object.hashAllUnordered(settings.entries.map((e) => (e.key, e.value))),
    selected,
    comparing,
  );

  @override
  String toString() =>
      'DetailState(${entry.id}, settings: $settings, '
      'selected: $selected, comparing: $comparing)';
}

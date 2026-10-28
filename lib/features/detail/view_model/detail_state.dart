import 'package:flutter/foundation.dart';
import 'package:widget_lab/catalog/model/genre.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// 詳細画面の状態。プレビュー・操作パネル・比較・コードの4か所で共有する。
final class DetailState {
  const DetailState({
    required this.entry,
    required this.genres,
    required this.settings,
    this.comparing,
  });

  /// [entry] を開いたときの状態。
  DetailState.initial(this.entry, this.genres)
    : settings = entry.initialSettings(),
      comparing = null;

  final WidgetEntry entry;

  /// [entry] が載るジャンル（説明タブのチップ）。
  final List<Genre> genres;

  /// OFF にしても値は覚えておく。
  final Map<String, PropertySetting> settings;

  /// 比べているプロパティの名前。`null` は比較していない。
  final String? comparing;

  /// 比べているプロパティの定義。比較していなければ `null`。
  PropertySpec? get comparingSpec =>
      entry.properties.where((spec) => spec.name == comparing).firstOrNull;

  /// 最初の値から1つでも変わった、または比較中（初期状態に戻すの活性）。
  bool get isModified =>
      comparing != null || !mapEquals(settings, entry.initialSettings());

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
    String? Function()? comparing,
  }) => DetailState(
    entry: entry,
    genres: genres,
    settings: settings ?? this.settings,
    comparing: comparing != null ? comparing() : this.comparing,
  );

  @override
  bool operator ==(Object other) =>
      other is DetailState &&
      other.entry == entry &&
      listEquals(other.genres, genres) &&
      mapEquals(other.settings, settings) &&
      other.comparing == comparing;

  @override
  int get hashCode => Object.hash(
    entry,
    Object.hashAll(genres),
    Object.hashAllUnordered(settings.entries.map((e) => (e.key, e.value))),
    comparing,
  );

  @override
  String toString() =>
      'DetailState(${entry.id}, settings: $settings, comparing: $comparing)';
}

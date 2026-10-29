import 'package:flutter/foundation.dart';
import 'package:widget_lab/catalog/model/genre.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';
import 'package:widget_lab/features/detail/view_model/comparing.dart';
import 'package:widget_lab/features/detail/view_model/exclusion_notice.dart';

/// 詳細画面の状態。プレビュー・チップ・編集パネル・比較・コードで共有する。
final class DetailState {
  const DetailState({
    required this.entry,
    required this.genres,
    required this.settings,
    this.selected,
    this.comparing,
    this.showsReferences = false,
    this.selectedChild,
    this.notice,
  });

  /// [entry] を開いたときの状態。
  DetailState.initial(this.entry, this.genres)
    : settings = entry.initialSettings(),
      selected = _firstSelected(entry),
      comparing = null,
      showsReferences = false,
      notice = null,
      selectedChild = firstChildOf(
        entry,
        _firstSelected(entry),
        entry.initialSettings(),
      );

  final WidgetEntry entry;

  /// [entry] が載るジャンル（説明のシートの印）。
  final List<Genre> genres;

  /// OFF にしても値は覚えておく。
  final Map<String, PropertySetting> settings;

  /// 編集パネルで選んでいるプロパティの名前。プロパティがなければ `null`。
  final String? selected;

  /// 何を比べているか。`null` は比較していない。
  final Comparing? comparing;

  /// 補足のタブを開いているか。
  final bool showsReferences;

  /// 入れ子のプロパティを選んでいるときの、中で選んでいる子。
  final String? selectedChild;

  /// 同時に使えない相手を OFF にした知らせ。`null` は出していない。
  final ExclusionNotice? notice;

  /// 選んでいるプロパティの定義。
  PropertySpec? get selectedSpec => _specOf(selected);

  /// 比べているプロパティの定義。プロパティを比べていなければ `null`
  /// （使った／使わないの比較も `null`）。
  PropertySpec? get comparingSpec => switch (comparing) {
    ComparingProperty(:final name) => _specOf(name),
    ComparingUse() || null => null,
  };

  /// 最初の値から1つでも変わった、または比較中（初期状態に戻すの活性）。
  /// 選び替えただけでは変わらない。
  bool get isModified =>
      comparing != null || !mapEquals(settings, entry.initialSettings());

  /// [name] のプロパティが最初の値のまま（既定に戻すの活性）。
  bool isDefault(String name) =>
      settings[name] == entry.initialSettings()[name];

  /// 比較の「付けた」（[on] が `true`）か「付けない」側の設定。
  /// 比べるプロパティだけ ON / OFF を変え、値とほかのプロパティはそのまま。
  /// プロパティを比べていなければ今の設定（使った／使わないは 2 枚とも同じ設定）。
  Map<String, PropertySetting> settingsForSide({required bool on}) {
    final comparing = this.comparing;
    if (comparing is! ComparingProperty) return settings;
    final setting = settings[comparing.name];
    if (setting == null) return settings;
    final child = comparing.child;
    final value = setting.value;
    if (child == null || value is! NestedValue) {
      return {...settings, comparing.name: setting.copyWith(on: on)};
    }
    final childSetting = value.settings[child];
    if (childSetting == null) return settings;
    return {
      ...settings,
      comparing.name: setting.copyWith(
        value: value.copyWithChild(child, childSetting.copyWith(on: on)),
      ),
    };
  }

  /// 選んでいるプロパティの仲間。
  PropertyGroup? get selectedGroup => selectedSpec?.group;

  /// タブを出すか。仲間が 2 つ以上か、補足がある。
  bool get showsTabs =>
      entry.groups.length + (entry.references.isEmpty ? 0 : 1) >= 2;

  /// 開いているタブのプロパティ（チップの列に並べる）。
  List<PropertySpec> get specsInSelectedGroup => [
    for (final spec in entry.properties)
      if (spec.group == selectedGroup) spec,
  ];

  /// [group] の仲間で ON のプロパティの数（タブの数の印）。
  int onCountIn(PropertyGroup? group) => entry.properties
      .where((spec) => spec.group == group && spec.isOnIn(settings))
      .length;

  /// [name] のプロパティが効くか（`requires` の相手が ON）。相手がなければ常に `true`。
  bool isEffective(String name) {
    final requires = _specOf(name)?.requires;
    if (requires == null) return true;
    return _specOf(requires)?.isOnIn(settings) ?? true;
  }

  DetailState copyWith({
    Map<String, PropertySetting>? settings,
    String? selected,
    Comparing? Function()? comparing,
    bool? showsReferences,
    String? Function()? selectedChild,
    ExclusionNotice? Function()? notice,
  }) => DetailState(
    entry: entry,
    genres: genres,
    settings: settings ?? this.settings,
    selected: selected ?? this.selected,
    comparing: comparing != null ? comparing() : this.comparing,
    showsReferences: showsReferences ?? this.showsReferences,
    selectedChild: selectedChild != null ? selectedChild() : this.selectedChild,
    notice: notice != null ? notice() : this.notice,
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

  /// [name] が入れ子のプロパティなら、[settings] で最初の ON の子（なければ最初の子）の名前。
  /// 入れ子でなければ `null`。
  static String? firstChildOf(
    WidgetEntry entry,
    String? name,
    Map<String, PropertySetting> settings,
  ) {
    final spec = entry.properties.where((p) => p.name == name).firstOrNull;
    if (spec == null) return null;
    final children = spec.children;
    if (children.isEmpty) return null;
    final value = settings[name]?.value;
    if (value is! NestedValue) return null;
    return (children
                .where((c) => value.settings[c.name]?.on ?? false)
                .firstOrNull ??
            children.first)
        .name;
  }

  @override
  bool operator ==(Object other) =>
      other is DetailState &&
      other.entry == entry &&
      listEquals(other.genres, genres) &&
      mapEquals(other.settings, settings) &&
      other.selected == selected &&
      other.comparing == comparing &&
      other.showsReferences == showsReferences &&
      other.selectedChild == selectedChild &&
      other.notice == notice;

  @override
  int get hashCode => Object.hash(
    entry,
    Object.hashAll(genres),
    Object.hashAllUnordered(settings.entries.map((e) => (e.key, e.value))),
    selected,
    comparing,
    showsReferences,
    selectedChild,
    notice,
  );

  @override
  String toString() =>
      'DetailState(${entry.id}, settings: $settings, '
      'selected: $selected, comparing: $comparing, '
      'showsReferences: $showsReferences, selectedChild: $selectedChild, '
      'notice: $notice)';
}

import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';

/// プレビューを組み立てる関数。OFF のプロパティには Widget の既定値を渡す。
typedef DemoBuilder = Widget Function(DemoArgs args);

/// 見た目を持つか（visual）、持たないか（behavior）。
enum EntryKind { visual, behavior }

/// 収録する Widget 1つ分のデータ。
///
/// [id] で一意（全件のテストで確かめる）なので、`==` は [id] で比べる。
final class WidgetEntry {
  const WidgetEntry({
    required this.id,
    required this.name,
    required this.genreIds,
    required this.summary,
    required this.description,
    required this.docUrl,
    required this.properties,
    required this.build,
    required this.codeName,
    this.kind = EntryKind.visual,
  });

  final String id;

  /// 公式カタログでの名前（manifest.dart の名前と同じ）。
  final String name;
  final List<String> genreIds;

  /// 一覧に出す一行の要約。
  final String summary;
  final String description;

  /// 公式の API ドキュメント。
  final Uri docUrl;
  final EntryKind kind;
  final List<PropertySpec> properties;
  final DemoBuilder build;

  /// コードで書く名前（例: `Padding`）。
  final String codeName;

  /// 開いたときの、全プロパティの設定。
  Map<String, PropertySetting> initialSettings() => {
    for (final spec in properties) spec.name: spec.initialSetting,
  };

  @override
  bool operator ==(Object other) => other is WidgetEntry && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'WidgetEntry($id)';
}

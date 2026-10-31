import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/model/code_nest.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';

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
    this.buildWithout,
    this.codeWithout,
    this.codeNest,
    this.codeArguments = const [],
    this.references = const [],
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

  /// 比較の「使わない」側の木。[kind] が behavior なら必ず持ち、visual なら `null`。
  /// 既定は包みを外して中の木を返すだけにする。
  final DemoBuilder? buildWithout;

  /// コードで書く名前（例: `Padding`）。
  final String codeName;

  /// `PropertyArg.nested` のプロパティを書く入れ子の式。なければ `null`。
  final CodeNest? codeNest;

  /// チップに出さない、コードの最後に書く固定の引数（例: `child: const _Readers()`。
  /// 末尾の `,` は付けない）。
  final List<String> codeArguments;

  /// 見た目が変わらない引数（補足に出す）。
  final List<ReferenceArg> references;

  /// プロパティの仲間を、[PropertyGroup] の順に重ねずに並べる。仲間のないもの（`null`）は先頭。
  List<PropertyGroup?> get groups {
    final present = {for (final spec in properties) spec.group};
    return [
      if (present.contains(null)) null,
      for (final group in PropertyGroup.values)
        if (present.contains(group)) group,
    ];
  }

  /// 使わない場合のよくある書き方（手で書いたコード）。包みを外すだけで済む Widget は `null`。
  final String? codeWithout;

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

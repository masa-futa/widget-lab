// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Widget Lab';

  @override
  String get catalogSearchHint => 'Widget 名で検索';

  @override
  String get catalogSearchClear => '検索を消す';

  @override
  String catalogEmpty(String query) {
    return '「$query」に一致する Widget はありません';
  }

  @override
  String catalogSectionLabel(String genre, int count) {
    return '$genre、$count 件';
  }

  @override
  String get detailAbout => 'この Widget について';

  @override
  String get detailReset => '初期状態に戻す';

  @override
  String get detailZoom1 => '×1';

  @override
  String get detailZoom2 => '×2';

  @override
  String get detailZoom1Semantics => '等倍で表示';

  @override
  String get detailZoom2Semantics => '2 倍で表示';

  @override
  String get detailCompareWith => '付けた';

  @override
  String get detailCompareWithout => '付けない';

  @override
  String detailCompareWithSemantics(String name, String value) {
    return '付けた、$name、$value';
  }

  @override
  String get detailCompareWithoutSemantics => '付けない';

  @override
  String get detailCompareDivider => '比較の仕切り';

  @override
  String get detailCodeOpen => '全文';

  @override
  String detailCodeUnset(String name) {
    return '// $name は指定なし（既定値）';
  }

  @override
  String get detailChipDefault => '既定';

  @override
  String get detailChipSelected => '選択中';

  @override
  String get detailCompare => '比べる';

  @override
  String get detailCompareStop => '比べるのをやめる';

  @override
  String get detailDefault => '既定に戻す';

  @override
  String get detailRequired => '必須';

  @override
  String detailToggleLabel(String name) {
    return '$name を付ける';
  }

  @override
  String detailValueLabel(String name) {
    return '$name の値';
  }

  @override
  String get detailNoProperties => 'この Widget には変えられるプロパティがありません';

  @override
  String get detailCodeTitle => 'コード';

  @override
  String get detailCodeLegend => '既定から変えた行';

  @override
  String get detailCopyCode => 'コードをコピー';

  @override
  String get detailCopySucceeded => 'コードをコピーしました';

  @override
  String get detailCopyFailed => 'コピーできませんでした';

  @override
  String detailAboutTitle(String name) {
    return '$name について';
  }

  @override
  String get detailOpenDocs => '公式ドキュメントを開く';

  @override
  String get detailOpenDocsFailed => 'ブラウザを開けませんでした';
}

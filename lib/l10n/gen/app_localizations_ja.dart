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
  String get catalogGroupDesignSystem => 'デザインシステム';

  @override
  String get catalogGroupBase => '基本の Widget';

  @override
  String get catalogCountUnit => '件';

  @override
  String get catalogNameSeparator => '・';

  @override
  String catalogExamplesMore(String examples) {
    return '$examples…';
  }

  @override
  String get catalogReadSeparator => '、';

  @override
  String catalogTileSemantics(String genre, int count, String examples) {
    return '$genre、$count 件、$examples';
  }

  @override
  String catalogTileSemanticsMore(String genre, int count, String examples) {
    return '$genre、$count 件、$examples など';
  }

  @override
  String catalogGenreIntro(int count, String description) {
    return '$count 件・$description';
  }

  @override
  String catalogPropertyCount(int count) {
    return '$count プロパティ';
  }

  @override
  String catalogEntrySemantics(String name, String summary, int count) {
    return '$name、$summary、$count プロパティ';
  }

  @override
  String catalogEntrySemanticsWithGenres(
    String name,
    String summary,
    int count,
    String genres,
  ) {
    return '$name、$summary、$count プロパティ、$genres';
  }

  @override
  String get detailTabOperation => '操作';

  @override
  String get detailTabDescription => '説明';

  @override
  String get detailTabCode => 'コード';

  @override
  String get detailReset => '初期状態に戻す';

  @override
  String get detailCompare => '付けた／付けないを比べる';

  @override
  String get detailComparing => '比較中';

  @override
  String get detailCompareWith => '付けた';

  @override
  String get detailCompareWithout => '付けない';

  @override
  String detailCompareWithSemantics(String name, String value) {
    return '付けた、$name、$value';
  }

  @override
  String detailCompareWithoutSemantics(String name) {
    return '付けない、$name';
  }

  @override
  String detailComparingTarget(String name) {
    return '$name を比較中';
  }

  @override
  String get detailCompareDismiss => '比較をやめる';

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
  String get detailOpenDocs => '公式ドキュメントを開く';

  @override
  String get detailOpenDocsFailed => 'ブラウザを開けませんでした';

  @override
  String get detailCopyCode => 'コードをコピー';

  @override
  String get detailCopySucceeded => 'コードをコピーしました';

  @override
  String get detailCopyFailed => 'コピーできませんでした';
}

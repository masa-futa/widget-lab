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
  String get detailChipInactive => '今は効かない';

  @override
  String get detailCompare => '比べる';

  @override
  String get detailCompareStop => '比べるのをやめる';

  @override
  String get detailDefault => '既定に戻す';

  @override
  String get detailRequired => '必須';

  @override
  String get detailNestedLabel => '中の値';

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

  @override
  String get detailCompareUse => '使わない場合と比べる';

  @override
  String get probeSideUsed => '使った';

  @override
  String get probeSideUnused => '使わない';

  @override
  String probeBuildCount(int count) {
    return 'build $count 回';
  }

  @override
  String probeBuildCountSemantics(String label, int count) {
    return '$label、build $count 回';
  }

  @override
  String probeLogBuild(String label, int count) {
    return '$labelを build（$count 回目）';
  }

  @override
  String probeLogRepeat(String text, int count) {
    return '$text ×$count';
  }

  @override
  String probeLogCount(int count) {
    return '$count 件';
  }

  @override
  String get probeLogEmpty => 'まだ何も起きていません';

  @override
  String get probeLogTitle => 'ログ';

  @override
  String get probeLogClear => 'ログを消す';

  @override
  String probeLogSemantics(int count, String latest) {
    return 'ログ、$count 件、最新: $latest';
  }

  @override
  String get detailGroupSize => '大きさ';

  @override
  String get detailGroupSpacing => '余白';

  @override
  String get detailGroupLayout => '配置';

  @override
  String get detailGroupPaint => '色と装飾';

  @override
  String get detailGroupTransform => '変形';

  @override
  String get detailGroupText => '文字';

  @override
  String get detailGroupBehavior => '挙動';

  @override
  String get detailGroupContent => '中身';

  @override
  String get detailGroupAll => 'プロパティ';

  @override
  String get detailTabReferences => '補足';

  @override
  String detailTabOnCount(String group, int count) {
    return '$group、ON が $count 件';
  }

  @override
  String get detailReferencesLabel => '補足';

  @override
  String get detailPickerPrevious => '前のプロパティ';

  @override
  String get detailPickerNext => '次のプロパティ';

  @override
  String detailPickerSemantics(
    String name,
    String detail,
    int index,
    int count,
  ) {
    return '$name、$detail、$index / $count';
  }

  @override
  String detailPickerReferencesValue(int count) {
    return '$count 件 ・ 読むだけ';
  }

  @override
  String detailPickerSheetTitle(int count) {
    return 'プロパティ（$count）';
  }

  @override
  String detailPickerSheetOnCount(int count) {
    return '指定中 $count';
  }

  @override
  String detailPickerReferencesCount(int count) {
    return '$count 件';
  }

  @override
  String get detailRelationPairs => 'と組で使うことが多い';

  @override
  String get detailRelationRequires => 'が ON のときだけ効く';

  @override
  String get detailRelationRequiresOff => '（今は OFF）';

  @override
  String detailRelationTurnOn(String name) {
    return '$name を ON にする';
  }

  @override
  String get detailRelationExcludes => 'と同時には使えない';

  @override
  String detailExclusionNotice(String on, String off) {
    return '$on と同時には使えないので、$off を OFF にしました';
  }

  @override
  String get detailReferencesTitle => '見た目が変わらない引数';

  @override
  String get detailReferencesNote => '触っても見た目は変わりません。コードを書くときの手がかりに載せています。';
}

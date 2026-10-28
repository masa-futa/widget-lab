import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ja')];

  /// アプリ名。ホーム画面の AppBar にも出す
  ///
  /// In ja, this message translates to:
  /// **'Widget Lab'**
  String get appTitle;

  /// ホーム画面の検索欄のプレースホルダー
  ///
  /// In ja, this message translates to:
  /// **'Widget 名で検索'**
  String get catalogSearchHint;

  /// 検索の入力を消すボタン。消すボタンの読み上げと、空状態のボタンに使う
  ///
  /// In ja, this message translates to:
  /// **'検索を消す'**
  String get catalogSearchClear;

  /// 検索の結果が 0 件のときの文言
  ///
  /// In ja, this message translates to:
  /// **'「{query}」に一致する Widget はありません'**
  String catalogEmpty(String query);

  /// ホームの段の見出し（Cupertino・Material design）
  ///
  /// In ja, this message translates to:
  /// **'デザインシステム'**
  String get catalogGroupDesignSystem;

  /// ホームの段の見出し（残りのジャンル）
  ///
  /// In ja, this message translates to:
  /// **'基本の Widget'**
  String get catalogGroupBase;

  /// ジャンルのタイルの件数の数字のあとに添える単位
  ///
  /// In ja, this message translates to:
  /// **'件'**
  String get catalogCountUnit;

  /// タイルの代表の名前と、検索の結果のジャンル名をつなぐ記号
  ///
  /// In ja, this message translates to:
  /// **'・'**
  String get catalogNameSeparator;

  /// タイルの代表の名前に入りきらない Widget があるとき
  ///
  /// In ja, this message translates to:
  /// **'{examples}…'**
  String catalogExamplesMore(String examples);

  /// 読み上げで名前をつなぐ記号
  ///
  /// In ja, this message translates to:
  /// **'、'**
  String get catalogReadSeparator;

  /// ジャンルのタイルの読み上げ
  ///
  /// In ja, this message translates to:
  /// **'{genre}、{count} 件、{examples}'**
  String catalogTileSemantics(String genre, int count, String examples);

  /// 代表の名前に入りきらない Widget があるジャンルのタイルの読み上げ
  ///
  /// In ja, this message translates to:
  /// **'{genre}、{count} 件、{examples} など'**
  String catalogTileSemanticsMore(String genre, int count, String examples);

  /// ジャンル画面の件数と一言の説明
  ///
  /// In ja, this message translates to:
  /// **'{count} 件・{description}'**
  String catalogGenreIntro(int count, String description);

  /// 見本つきの行のプロパティ数の印
  ///
  /// In ja, this message translates to:
  /// **'{count} プロパティ'**
  String catalogPropertyCount(int count);

  /// 見本つきの行の読み上げ
  ///
  /// In ja, this message translates to:
  /// **'{name}、{summary}、{count} プロパティ'**
  String catalogEntrySemantics(String name, String summary, int count);

  /// 検索の結果の行の読み上げ（載っているジャンルを添える）
  ///
  /// In ja, this message translates to:
  /// **'{name}、{summary}、{count} プロパティ、{genres}'**
  String catalogEntrySemanticsWithGenres(
    String name,
    String summary,
    int count,
    String genres,
  );

  /// 詳細画面のタブ（プロパティの操作）
  ///
  /// In ja, this message translates to:
  /// **'操作'**
  String get detailTabOperation;

  /// 詳細画面のタブ（要約と公式ドキュメント）
  ///
  /// In ja, this message translates to:
  /// **'説明'**
  String get detailTabDescription;

  /// 詳細画面のタブ（今の設定のコード）
  ///
  /// In ja, this message translates to:
  /// **'コード'**
  String get detailTabCode;

  /// 詳細画面の AppBar のボタンのツールチップと読み上げ
  ///
  /// In ja, this message translates to:
  /// **'初期状態に戻す'**
  String get detailReset;

  /// 操作パネルの行の「比べる」ボタンのツールチップと読み上げ
  ///
  /// In ja, this message translates to:
  /// **'付けた／付けないを比べる'**
  String get detailCompare;

  /// 比較中の行の「比べる」ボタンの読み上げ
  ///
  /// In ja, this message translates to:
  /// **'比較中'**
  String get detailComparing;

  /// 比較の上のカードのラベル
  ///
  /// In ja, this message translates to:
  /// **'付けた'**
  String get detailCompareWith;

  /// 比較の下のカードのラベル
  ///
  /// In ja, this message translates to:
  /// **'付けない'**
  String get detailCompareWithout;

  /// 比較の上のカードの読み上げ
  ///
  /// In ja, this message translates to:
  /// **'付けた、{name}、{value}'**
  String detailCompareWithSemantics(String name, String value);

  /// 比較の下のカードの読み上げ
  ///
  /// In ja, this message translates to:
  /// **'付けない、{name}'**
  String detailCompareWithoutSemantics(String name);

  /// 比較しているプロパティ
  ///
  /// In ja, this message translates to:
  /// **'{name} を比較中'**
  String detailComparingTarget(String name);

  /// 比較をやめる文字のボタン
  ///
  /// In ja, this message translates to:
  /// **'比較をやめる'**
  String get detailCompareDismiss;

  /// 必須のプロパティの印（スイッチの代わり）
  ///
  /// In ja, this message translates to:
  /// **'必須'**
  String get detailRequired;

  /// プロパティの ON/OFF のスイッチの読み上げ
  ///
  /// In ja, this message translates to:
  /// **'{name} を付ける'**
  String detailToggleLabel(String name);

  /// プロパティの値の操作の読み上げ
  ///
  /// In ja, this message translates to:
  /// **'{name} の値'**
  String detailValueLabel(String name);

  /// 操作できるプロパティがないときの操作タブ
  ///
  /// In ja, this message translates to:
  /// **'この Widget には変えられるプロパティがありません'**
  String get detailNoProperties;

  /// 説明タブのボタン
  ///
  /// In ja, this message translates to:
  /// **'公式ドキュメントを開く'**
  String get detailOpenDocs;

  /// 公式ドキュメントを開けなかったときの Snackbar
  ///
  /// In ja, this message translates to:
  /// **'ブラウザを開けませんでした'**
  String get detailOpenDocsFailed;

  /// コードタブのボタン
  ///
  /// In ja, this message translates to:
  /// **'コードをコピー'**
  String get detailCopyCode;

  /// コピーできたときの Snackbar
  ///
  /// In ja, this message translates to:
  /// **'コードをコピーしました'**
  String get detailCopySucceeded;

  /// クリップボードに書けなかったときの Snackbar
  ///
  /// In ja, this message translates to:
  /// **'コピーできませんでした'**
  String get detailCopyFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

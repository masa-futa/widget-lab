import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoLocalizationsEntry = WidgetEntry(
  id: 'cupertinoLocalizations',
  name: 'CupertinoLocalizations',
  genreIds: const ['cupertino'],
  summary: 'Cupertino の Widget が使う文言（今日・コピーなど）を言語ごとに持つ',
  description:
      'Widget ではなく、Cupertino の Widget が使う文言（日付の選択の「今日」、メニューの'
      '「コピー」など）を言語ごとに返すクラスです。CupertinoLocalizations.of(context) で読みます。'
      '日本語などを使うには flutter_localizations の GlobalCupertinoLocalizations を'
      'アプリの localizationsDelegates に入れます（プレビューでは Localizations.override で言語を変える）。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoLocalizations-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'locale',
      typeLabel: 'Locale?',
      description: '文言の言語',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice('ja', Locale('ja'), "Locale('ja')"),
          Choice('en', Locale('en'), "Locale('en')"),
        ],
      ),
    ),
  ],
  build: _build,
  codeName: 'Localizations.override',
  codeArguments: const [
    'context: context',
    'delegates: GlobalCupertinoLocalizations.delegates',
    'child: const Labels()',
  ],
);

Widget _build(DemoArgs args) => Builder(
  builder: (context) => Localizations.override(
    context: context,
    locale: args.valueOf<Locale>('locale'),
    delegates: GlobalCupertinoLocalizations.delegates,
    child: const FittedBox(fit: BoxFit.scaleDown, child: _Labels()),
  ),
);

/// CupertinoLocalizations.of(context) の文言を並べる子。
class _Labels extends StatelessWidget {
  const _Labels();

  @override
  Widget build(BuildContext context) {
    final localizations = CupertinoLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('todayLabel: ${localizations.todayLabel}'),
        Text('cutButtonLabel: ${localizations.cutButtonLabel}'),
        Text('copyButtonLabel: ${localizations.copyButtonLabel}'),
        Text('pasteButtonLabel: ${localizations.pasteButtonLabel}'),
        Text('selectAllButtonLabel: ${localizations.selectAllButtonLabel}'),
      ],
    );
  }
}

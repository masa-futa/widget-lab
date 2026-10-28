import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/demo/demo_scope.dart';
import 'package:widget_lab/catalog/demo/rebuild_counter.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/code_nest.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/dart_code.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoThemeEntry = WidgetEntry(
  id: 'cupertinoTheme',
  name: 'CupertinoTheme',
  genreIds: const ['cupertino'],
  summary: '子孫の Cupertino の Widget に色と明るさを配る',
  description:
      '子孫の Cupertino の Widget に CupertinoThemeData（主な色・明るさ・文字）を配ります。'
      'CupertinoTheme.of で読んだ子だけが、値が変わったときに組み直されます。'
      '一部だけ変えるときは、親の値を CupertinoTheme.of(context).copyWith で写して渡します。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoTheme-class.html',
  ),
  kind: EntryKind.behavior,
  properties: [
    PropertySpec(
      name: 'primaryColor',
      typeLabel: 'Color?',
      description: '主な色。ボタンの文字やスイッチなどに使われる',
      arg: PropertyArg.nested,
      control: ColorControl(
        palette: [
          const Choice(
            'systemPink',
            CupertinoColors.systemPink,
            'CupertinoColors.systemPink',
          ),
          const Choice(
            'systemGreen',
            CupertinoColors.systemGreen,
            'CupertinoColors.systemGreen',
          ),
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
        ],
      ),
    ),
    const PropertySpec(
      name: 'brightness',
      typeLabel: 'Brightness?',
      description: '明るさ。dark にすると CupertinoColors の動的な色が暗い側になる',
      arg: PropertyArg.nested,
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('light', Brightness.light, 'Brightness.light'),
          Choice('dark', Brightness.dark, 'Brightness.dark'),
        ],
      ),
    ),
  ],
  build: _build,
  buildWithout: _buildWithout,
  codeName: 'CupertinoTheme',
  codeNest: const CodeNest(
    name: 'data',
    receiver: 'CupertinoTheme.of(context)',
  ),
  codeArguments: const ['child: const Readers()'],
);

Widget _build(DemoArgs args) {
  final primaryColor = args.valueOf<Color>('primaryColor');
  final brightness = args.valueOf<Brightness>('brightness');
  final values = [
    if (primaryColor != null) 'primaryColor: ${colorCode(primaryColor)}',
    if (brightness != null) 'brightness: ${brightness.name}',
  ];
  return DemoScope(
    label: 'CupertinoTheme(${values.join(', ')})',
    child: Builder(
      // OFF の項目は null を渡し、親（アプリ）の値をそのまま配る
      builder: (context) => CupertinoTheme(
        data: CupertinoTheme.of(context)
            .copyWith(primaryColor: primaryColor, brightness: brightness),
        child: const _Readers(),
      ),
    ),
  );
}

/// 包みを外す。子はアプリの CupertinoTheme を読むので、値を変えても届かない。
Widget _buildWithout(DemoArgs args) => const DemoFit(child: _Readers());

/// CupertinoTheme の下に置く子。const にして、テーマが変わったとき、
/// CupertinoTheme.of で読んだ子だけが組み直されるようにする。
class _Readers extends StatelessWidget {
  const _Readers();

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 8,
    children: [
      RebuildCounter(
        label: 'テーマを読む子',
        builder: (context) {
          final theme = CupertinoTheme.of(context);
          return DecoratedBox(
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground.resolveFrom(context),
            ),
            child: Text('主な色の文字', style: TextStyle(color: theme.primaryColor)),
          );
        },
      ),
      RebuildCounter(label: '読まない子', builder: (context) => const Text('固定の文')),
    ],
  );
}

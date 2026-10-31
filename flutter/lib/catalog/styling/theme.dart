import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_scope.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/demo/rebuild_counter.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/code_nest.dart';
import 'package:widget_lab/catalog/model/dart_code.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final themeEntry = WidgetEntry(
  id: 'theme',
  name: 'Theme',
  genreIds: const ['styling'],
  summary: '子孫に色・文字などのテーマ（ThemeData）を配る',
  description:
      'ThemeData（色の組・文字の組・部品ごとの見た目）を子孫に配ります。'
      'ボタンや文字は Theme.of(context) で読んで見た目を決めます。'
      'MediaQuery と違って項目ごとには分かれないので、どれか 1 つが変わると、'
      'Theme.of で読んだ子は全部組み直されます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/Theme-class.html',
  ),
  kind: EntryKind.behavior,
  properties: [
    PropertySpec(
      name: 'colorScheme',
      group: PropertyGroup.paint,
      typeLabel: 'ColorScheme',
      description: '色の組。Theme.of で読んだ子は、色を読んでいなくても組み直されます。',
      arg: PropertyArg.nested,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          for (final (name, color) in _seeds)
            Choice(
              name,
              ColorScheme.fromSeed(seedColor: color),
              'ColorScheme.fromSeed(seedColor: ${colorCode(color)})',
            ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'textTheme',
      group: PropertyGroup.text,
      typeLabel: 'TextTheme',
      description: '文字の組。ここでは bodyMedium の大きさだけを変えます。',
      arg: PropertyArg.nested,
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '大きめ（20）',
            TextTheme(bodyMedium: TextStyle(fontSize: 20)),
            'TextTheme(bodyMedium: TextStyle(fontSize: 20))',
          ),
          Choice(
            '小さめ（12）',
            TextTheme(bodyMedium: TextStyle(fontSize: 12)),
            'TextTheme(bodyMedium: TextStyle(fontSize: 12))',
          ),
        ],
      ),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'data',
      typeLabel: 'ThemeData',
      description: '子孫に配るテーマ。ここでは Theme.of(context).copyWith で、上の項目だけを変える',
    ),
    ReferenceArg(
      name: 'child',
      typeLabel: 'Widget',
      description: 'テーマを受け取る子孫。ここでは Theme.of で読む子の組（コードでは const Readers()）',
    ),
  ],
  build: _build,
  buildWithout: _buildWithout,
  codeName: 'Theme',
  codeNest: const CodeNest(name: 'data', receiver: 'Theme.of(context)'),
  codeArguments: const ['child: const Readers()'],
);

/// 色の組の元にする色（名前と色）。
final _seeds = [
  ('瑠璃', DemoTile.colors[0]),
  ('紅', DemoTile.colors[3]),
  ('若竹', DemoTile.colors[2]),
];

Widget _build(DemoArgs args) {
  final colorScheme = args.valueOf<ColorScheme>('colorScheme');
  final textTheme = args.valueOf<TextTheme>('textTheme');
  final values = [
    if (colorScheme != null) 'colorScheme: ${_seedName(colorScheme)}',
    if (textTheme != null)
      'bodyMedium: ${textTheme.bodyMedium?.fontSize?.round()}',
  ];
  return DemoScope(
    label: 'Theme(${values.join(', ')})',
    child: Builder(
      // OFF の項目は null を渡し、親（アプリ）の値をそのまま配る
      builder: (context) {
        final parent = Theme.of(context);
        return Theme(
          data: parent.copyWith(
            colorScheme: colorScheme,
            // copyWith は textTheme を丸ごと置き換えるので、親の文字の組に重ねる
            textTheme: textTheme == null
                ? null
                : parent.textTheme.merge(textTheme),
          ),
          child: const _Readers(),
        );
      },
    ),
  );
}

/// 札に出す、色の組の元にした色の名前。
String _seedName(ColorScheme scheme) {
  for (final (name, color) in _seeds) {
    if (scheme == ColorScheme.fromSeed(seedColor: color)) return name;
  }
  return '…';
}

/// 包みを外す。子はアプリの Theme を読むので、値を変えても届かない。
Widget _buildWithout(DemoArgs args) => const DemoFit(child: _Readers());

/// Theme の下に置く子。const にして、Theme の値が変わったとき、
/// Theme.of で読んだ子だけが組み直されるようにする。
class _Readers extends StatelessWidget {
  const _Readers();

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 8,
    children: [
      RebuildCounter(
        label: '色を読む子',
        builder: (context) => Align(
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            width: 48,
            height: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      RebuildCounter(
        label: '文字を読む子',
        builder: (context) =>
            Text('本文', style: Theme.of(context).textTheme.bodyMedium),
      ),
      RebuildCounter(label: '読まない子', builder: (context) => const Text('固定の文')),
    ],
  );
}

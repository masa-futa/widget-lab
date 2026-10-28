import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_scope.dart';
import 'package:widget_lab/catalog/demo/rebuild_counter.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/code_nest.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final mediaQueryEntry = WidgetEntry(
  id: 'mediaQuery',
  name: 'MediaQuery',
  genreIds: const ['styling'],
  summary: '子孫に画面の情報（文字の倍率・明るさなど）を配る',
  description:
      '画面の大きさ・文字の倍率・端末の明るさの設定などを、子孫に配ります。'
      'MediaQuery.textScalerOf のように項目ごとに読むと、その項目が変わったときだけ、'
      '読んだ子が組み直されます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/MediaQuery-class.html',
  ),
  kind: EntryKind.behavior,
  properties: [
    PropertySpec(
      name: 'textScaler',
      typeLabel: 'TextScaler',
      description: '文字の倍率。MediaQuery.textScalerOf で読んだ子だけが組み直されます。',
      arg: PropertyArg.nested,
      control: SliderControl(
        min: 1,
        max: 2,
        divisions: 4,
        initialValue: 1,
        resolve: TextScaler.linear,
        code: (v) => 'TextScaler.linear($v)',
      ),
    ),
    const PropertySpec(
      name: 'platformBrightness',
      typeLabel: 'Brightness',
      description: '端末の明るさの設定。MediaQuery.platformBrightnessOf で読んだ子だけが組み直されます。',
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
  codeName: 'MediaQuery',
  codeNest: const CodeNest(name: 'data', receiver: 'MediaQuery.of(context)'),
  codeArguments: const ['child: const Readers()'],
);

Widget _build(DemoArgs args) {
  final textScaler = args.valueOf<TextScaler>('textScaler');
  final brightness = args.valueOf<Brightness>('platformBrightness');
  final values = [
    if (textScaler != null) 'textScaler: ${textScaler.scale(1)}',
    if (brightness != null) 'platformBrightness: ${brightness.name}',
  ];
  return DemoScope(
    label: 'MediaQuery(${values.join(', ')})',
    child: Builder(
      // OFF の項目は null を渡し、親（アプリ）の値をそのまま配る
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: textScaler, platformBrightness: brightness),
        child: const _Readers(),
      ),
    ),
  );
}

/// 包みを外す。子はアプリの MediaQuery を読むので、値を変えても届かない。
Widget _buildWithout(DemoArgs args) => const DemoFit(child: _Readers());

/// MediaQuery の下に置く子。const にして、MediaQuery の値が変わっても、
/// 読んだ項目が変わった子だけが組み直されるようにする。
class _Readers extends StatelessWidget {
  const _Readers();

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 8,
    children: [
      RebuildCounter(
        label: '倍率を読む子',
        builder: (context) =>
            Text('倍率 ${MediaQuery.textScalerOf(context).scale(1)}'),
      ),
      RebuildCounter(
        label: '明るさを読む子',
        builder: (context) =>
            Text(MediaQuery.platformBrightnessOf(context).name),
      ),
      RebuildCounter(label: '読まない子', builder: (context) => const Text('固定の文')),
    ],
  );
}

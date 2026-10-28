import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_scope.dart';
import 'package:widget_lab/catalog/demo/rebuild_counter.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

const _sumi = Color(0xFF18181B);

final defaultTextStyleEntry = WidgetEntry(
  id: 'defaultTextStyle',
  name: 'DefaultTextStyle',
  genreIds: const ['text'],
  summary: '子孫の Text に、既定の文字の見た目を配る',
  description:
      'style・textAlign・maxLines などを、子孫の Text の既定にします。'
      'Text は自分の style をこの既定に重ねて描きます（inherit: false の style は重ねません）。'
      'style は親の既定と重ならず置き換わるので、重ねたいときは DefaultTextStyle.merge を使います。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/DefaultTextStyle-class.html',
  ),
  kind: EntryKind.behavior,
  properties: const [
    PropertySpec(
      name: 'style',
      typeLabel: 'TextStyle',
      description: '既定の文字の見た目。DefaultTextStyle.of で読んだ子だけが組み直されます。',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice(
            '大きく太く',
            TextStyle(color: _sumi, fontSize: 20, fontWeight: FontWeight.bold),
            'TextStyle(fontSize: 20, fontWeight: FontWeight.bold)',
          ),
          Choice(
            '紅の斜体',
            TextStyle(
              color: Color(0xFFD7003A),
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
            'TextStyle(color: Color(0xFFD7003A), fontStyle: FontStyle.italic)',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'maxLines',
      typeLabel: 'int?',
      description: '子孫の Text の行数の上限',
      initiallyOn: false,
      control: SliderControl(
        min: 1,
        max: 3,
        divisions: 2,
        initialValue: 1,
        resolve: asInt,
        code: intCode,
      ),
    ),
    PropertySpec(
      name: 'overflow',
      typeLabel: 'TextOverflow',
      description: '入りきらない文字の見せ方。既定は clip（切る）',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice('clip', TextOverflow.clip, 'TextOverflow.clip'),
          Choice('ellipsis', TextOverflow.ellipsis, 'TextOverflow.ellipsis'),
          Choice('fade', TextOverflow.fade, 'TextOverflow.fade'),
        ],
      ),
    ),
  ],
  build: _build,
  buildWithout: _buildWithout,
  codeName: 'DefaultTextStyle',
  codeArguments: const ['child: const Texts()'],
);

Widget _build(DemoArgs args) {
  // 必須のプロパティなので、常に値がある
  final style = args.valueOf<TextStyle>('style')!;
  final maxLines = args.valueOf<int>('maxLines');
  final overflow = args.valueOf<TextOverflow>('overflow');
  final values = [
    'fontSize: ${style.fontSize?.round()}',
    if (maxLines != null) 'maxLines: $maxLines',
    if (overflow != null) 'overflow: ${overflow.name}',
  ];
  return DemoScope(
    label: 'DefaultTextStyle(${values.join(', ')})',
    child: DefaultTextStyle(
      style: style,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      child: const _Texts(),
    ),
  );
}

/// 包みを外す。子はアプリの既定の文字の見た目を受けるので、値を変えても届かない。
Widget _buildWithout(DemoArgs args) => const DemoFit(child: _Texts());

/// DefaultTextStyle の下に置く子。const にして、読んだ子だけが組み直されるようにする。
class _Texts extends StatelessWidget {
  const _Texts();

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 8,
    children: [
      RebuildCounter(
        label: '大きさを読む子',
        builder: (context) => Text(
          'fontSize ${DefaultTextStyle.of(context).style.fontSize?.round()}',
        ),
      ),
      // style のない Text。自分の中で既定を読むので、見た目は変わるが、包む子は組み直されない
      RebuildCounter(
        label: '受ける Text',
        builder: (context) => const Text('既定の見た目を受けて描く、少し長めの文です'),
      ),
      RebuildCounter(
        // inherit: false の Text。既定を重ねない
        label: '受けない Text',
        builder: (context) => const Text(
          '既定を受けない',
          style: TextStyle(inherit: false, color: _sumi, fontSize: 14),
        ),
      ),
    ],
  );
}

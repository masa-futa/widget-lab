import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoTextMagnifierEntry = WidgetEntry(
  id: 'cupertinoTextMagnifier',
  name: 'CupertinoTextMagnifier',
  genreIds: const ['cupertino'],
  summary: '入力欄で文字を選ぶ間に出る、iOS の見た目の拡大鏡',
  description:
      '入力欄で長押しして指を動かす間、指の上に出る拡大鏡です。指の動きに少し遅れてついていき、'
      '指が下へ離れすぎると消えます。入力欄の magnifierConfiguration の magnifierBuilder で作ります'
      '（プレビューの文字を長押しして左右に動かすと見える）。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoTextMagnifier-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'dragResistance',
      typeLabel: 'double',
      description: '指の上下の動きにどれだけ遅れてついていくか。大きいほど動きにくい',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 40,
        divisions: 8,
        initialValue: 30,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'hideBelowThreshold',
      typeLabel: 'double',
      description: '指が文字の行からこれより下へ離れると消える',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 96,
        divisions: 8,
        initialValue: 96,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'horizontalScreenEdgePadding',
      typeLabel: 'double',
      description: '画面の左右の端から、これより内側に収める',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 40,
        divisions: 8,
        initialValue: 30,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    const PropertySpec(
      name: 'animationCurve',
      typeLabel: 'Curve',
      description: '出るときと消えるときの動きの緩急',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('bounceOut', Curves.bounceOut, 'Curves.bounceOut'),
          Choice('linear', Curves.linear, 'Curves.linear'),
        ],
      ),
    ),
  ],
  build: _build,
  codeName: 'CupertinoTextMagnifier',
  codeArguments: const [
    'controller: controller',
    'magnifierInfo: magnifierInfo',
  ],
);

Widget _build(DemoArgs args) {
  final dragResistance = args.valueOf<double>('dragResistance') ?? 10;
  final hideBelowThreshold = args.valueOf<double>('hideBelowThreshold') ?? 48;
  final horizontalScreenEdgePadding =
      args.valueOf<double>('horizontalScreenEdgePadding') ?? 10;
  final animationCurve =
      args.valueOf<Curve>('animationCurve') ?? Curves.easeOut;
  return _Field(
    magnifierConfiguration: TextMagnifierConfiguration(
      magnifierBuilder: (context, controller, magnifierInfo) =>
          CupertinoTextMagnifier(
            controller: controller,
            magnifierInfo: magnifierInfo,
            dragResistance: dragResistance,
            hideBelowThreshold: hideBelowThreshold,
            horizontalScreenEdgePadding: horizontalScreenEdgePadding,
            animationCurve: animationCurve,
          ),
    ),
  );
}

/// 最初から文字の入った入力欄（長押しして拡大鏡を出すため）。controller を持つので State にする。
class _Field extends StatefulWidget {
  const _Field({required this.magnifierConfiguration});

  final TextMagnifierConfiguration magnifierConfiguration;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  final _controller = TextEditingController(text: '長押しして指を左右に動かします');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 280,
    child: CupertinoTextField(
      controller: _controller,
      magnifierConfiguration: widget.magnifierConfiguration,
    ),
  );
}

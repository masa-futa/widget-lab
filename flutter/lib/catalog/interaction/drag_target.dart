import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_drop_zone.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/demo/demo_value.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final dragTargetEntry = WidgetEntry(
  id: 'dragTarget',
  name: 'DragTarget',
  genreIds: const ['interaction'],
  summary: 'Draggable で運ばれてきた値を受け取る場所',
  description:
      'Draggable を上に重ねると onWillAcceptWithDetails で受けるかを決め、'
      '離すと onAcceptWithDetails で値を受け取ります。'
      '見た目は builder で、重なっている値（candidateData）と断った値（rejectedData）から作ります。'
      'ここでは左に 1 と 2 の箱（Draggable）を置いています。右へドラッグしてみてください。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/DragTarget-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'onWillAcceptWithDetails',
      group: PropertyGroup.behavior,
      typeLabel: 'DragTargetWillAcceptWithDetails<T>?',
      description: '重なった値を受けるか。断ると枠が赤くなる。指定しないと全部受ける',
      control: ChoiceControl(
        choices: [
          Choice('偶数だけ受ける', _evenOnly, '(details) => details.data.isEven'),
          Choice('全部断る', _rejectAll, '(details) => false'),
        ],
      ),
    ),
    PropertySpec(
      name: 'onAcceptWithDetails',
      group: PropertyGroup.behavior,
      typeLabel: 'DragTargetAcceptWithDetails<T>?',
      description: '離したときに値を受け取る。指定しないと、重ねても何も起きない',
      control: FixedControl(
        value: true,
        source: '(details) => setState(() => received = details.data)',
      ),
    ),
    PropertySpec(
      name: 'builder',
      group: PropertyGroup.content,
      typeLabel: 'DragTargetBuilder<T>',
      description: '見た目を作る関数。重なっている間は色を変える',
      required: true,
      control: FixedControl(
        value: true,
        source:
            '(context, candidateData, rejectedData) =>\n'
            '      DropArea(highlighted: candidateData.isNotEmpty)',
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
      name: 'onWillAccept',
      typeLabel: 'DragTargetWillAccept<T>?',
      description: '非推奨。代わりに onWillAcceptWithDetails を使う',
    ),
    ReferenceArg(
      name: 'onAccept',
      typeLabel: 'DragTargetAccept<T>?',
      description: '非推奨。代わりに onAcceptWithDetails を使う',
    ),
    ReferenceArg(
      name: 'onLeave',
      typeLabel: 'DragTargetLeave<T>?',
      description: '重なっていた値が、落とされずに離れていったときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onMove',
      typeLabel: 'DragTargetMove<T>?',
      description: '値を重ねたまま動かしている間、動くたびに呼ばれる',
    ),
    ReferenceArg(
      name: 'hitTestBehavior',
      typeLabel: 'HitTestBehavior',
      description: '値が重なったかを決める当たり判定のしかた。見本の受け取る場所は全面を塗っているので違いは出ない',
    ),
  ],
  build: _build,
  codeName: 'DragTarget<int>',
);

bool _evenOnly(DragTargetDetails<int> details) => details.data.isEven;

bool _rejectAll(DragTargetDetails<int> details) => false;

Widget _build(DemoArgs args) {
  final willAccept = args.valueOf<bool Function(DragTargetDetails<int>)>(
    'onWillAcceptWithDetails',
  );
  final accepts = args.valueOf<bool>('onAcceptWithDetails') != null;
  return DemoValue<int?>(
    initial: null,
    builder: (context, received, onChanged) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const _Source(1),
        const _Source(2),
        DragTarget<int>(
          onWillAcceptWithDetails: willAccept,
          onAcceptWithDetails: accepts
              ? (details) => onChanged(details.data)
              : null,
          builder: (context, candidates, rejected) => DemoDropArea(
            highlighted: candidates.isNotEmpty,
            rejected: rejected.isNotEmpty,
            label: received == null ? 'ここへ落とす' : '受け取った: $received',
          ),
        ),
      ],
    ),
  );
}

/// [number] を運ぶ箱（デモの部品）。
class _Source extends StatelessWidget {
  const _Source(this.number);

  final int number;

  @override
  Widget build(BuildContext context) => Draggable<int>(
    data: number,
    feedback: Opacity(
      opacity: 0.7,
      child: DemoTile(number, width: 40, height: 40),
    ),
    child: DemoTile(number, width: 40, height: 40),
  );
}

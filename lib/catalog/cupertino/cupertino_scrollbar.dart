import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoScrollbarEntry = WidgetEntry(
  id: 'cupertinoScrollbar',
  name: 'CupertinoScrollbar',
  genreIds: const ['cupertino'],
  summary: 'スクロールの位置を示す、iOS の見た目の細いつまみ',
  description:
      '子のスクロールの位置を、右端の細い角丸のつまみで示します。ふつうはスクロールしている間だけ出て、'
      '止まると消えます。つまみを長押しして引くと太くなり、そのまま動かせます。'
      '常に出すときは、子と同じ ScrollController を渡します。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoScrollbar-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'thumbVisibility',
      group: PropertyGroup.behavior,
      typeLabel: 'bool?',
      description: 'true ならスクロールしていなくても、つまみを出し続ける',
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'thickness',
      group: PropertyGroup.size,
      typeLabel: 'double',
      description: 'つまみの太さ。指定しないと 3',
      initiallyOn: false,
      pairsWith: const ['thicknessWhileDragging'],
      control: SliderControl(
        min: 1,
        max: 9,
        divisions: 8,
        initialValue: 6,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'thicknessWhileDragging',
      group: PropertyGroup.size,
      typeLabel: 'double',
      description: 'つまみを長押しして引いている間の太さ。指定しないと 8',
      initiallyOn: false,
      pairsWith: const ['thickness'],
      control: SliderControl(
        min: 2,
        max: 16,
        divisions: 7,
        initialValue: 12,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'radius',
      group: PropertyGroup.paint,
      typeLabel: 'Radius',
      description: 'つまみの角の丸み。指定しないと 1.5',
      initiallyOn: false,
      pairsWith: const ['radiusWhileDragging'],
      control: SliderControl(
        min: 0,
        max: 6,
        divisions: 6,
        initialValue: 0,
        resolve: Radius.circular,
        code: (v) => 'Radius.circular($v)',
      ),
    ),
    PropertySpec(
      name: 'radiusWhileDragging',
      group: PropertyGroup.paint,
      typeLabel: 'Radius',
      description: 'つまみを長押しして引いている間の角の丸み。指定しないと 4',
      initiallyOn: false,
      pairsWith: const ['radius'],
      control: SliderControl(
        min: 0,
        max: 8,
        divisions: 4,
        initialValue: 0,
        resolve: Radius.circular,
        code: (v) => 'Radius.circular($v)',
      ),
    ),
    PropertySpec(
      name: 'scrollbarOrientation',
      group: PropertyGroup.layout,
      typeLabel: 'ScrollbarOrientation?',
      description: 'つまみを出す端。指定しないと縦のスクロールでは右（右から左へ書く言語では左）',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final orientation in const [
            ScrollbarOrientation.left,
            ScrollbarOrientation.right,
          ])
            Choice(
              orientation.name,
              orientation,
              'ScrollbarOrientation.${orientation.name}',
            ),
        ],
      ),
    ),
    PropertySpec(
      name: 'mainAxisMargin',
      group: PropertyGroup.spacing,
      typeLabel: 'double',
      description: 'つまみが動く範囲の、上下の端からの余白。指定しないと 3',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 40,
        divisions: 4,
        initialValue: 20,
        resolve: (v) => v,
        code: (v) => '$v',
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
      name: 'child',
      typeLabel: 'Widget',
      description: 'つまみを付けるスクロールする Widget。ここでは行を並べた ListView',
    ),
    ReferenceArg(
      name: 'controller',
      typeLabel: 'ScrollController?',
      description: '子と同じものを渡すと、つまみの位置を知り、引いて動かせる',
    ),
    ReferenceArg(
      name: 'notificationPredicate',
      typeLabel: 'ScrollNotificationPredicate?',
      description: 'どのスクロールの知らせでつまみを動かすかを決める。入れ子のスクロールで使う',
    ),
  ],
  build: _build,
  codeName: 'CupertinoScrollbar',
  codeArguments: const [
    'controller: controller',
    'child: ListView(controller: controller, children: rows)',
  ],
);

Widget _build(DemoArgs args) => _ScrollbarDemo(
  thumbVisibility: args.valueOf<bool>('thumbVisibility'),
  thickness:
      args.valueOf<double>('thickness') ?? CupertinoScrollbar.defaultThickness,
  thicknessWhileDragging:
      args.valueOf<double>('thicknessWhileDragging') ??
      CupertinoScrollbar.defaultThicknessWhileDragging,
  radius: args.valueOf<Radius>('radius') ?? CupertinoScrollbar.defaultRadius,
  radiusWhileDragging:
      args.valueOf<Radius>('radiusWhileDragging') ??
      CupertinoScrollbar.defaultRadiusWhileDragging,
  scrollbarOrientation: args.valueOf<ScrollbarOrientation>(
    'scrollbarOrientation',
  ),
  // SDK の既定値（_kScrollbarMainAxisMargin）
  mainAxisMargin: args.valueOf<double>('mainAxisMargin') ?? 3,
);

/// ScrollController を持ち、CupertinoScrollbar と ListView の両方に渡す（デモの部品）。
/// thumbVisibility が true のとき、つまみの位置を知るのに同じ controller が要る。
class _ScrollbarDemo extends StatefulWidget {
  const _ScrollbarDemo({
    required this.thumbVisibility,
    required this.thickness,
    required this.thicknessWhileDragging,
    required this.radius,
    required this.radiusWhileDragging,
    required this.scrollbarOrientation,
    required this.mainAxisMargin,
  });

  final bool? thumbVisibility;
  final double thickness;
  final double thicknessWhileDragging;
  final Radius radius;
  final Radius radiusWhileDragging;
  final ScrollbarOrientation? scrollbarOrientation;
  final double mainAxisMargin;

  @override
  State<_ScrollbarDemo> createState() => _ScrollbarDemoState();
}

class _ScrollbarDemoState extends State<_ScrollbarDemo> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 240,
    height: 160,
    child: CupertinoScrollbar(
      controller: _controller,
      thumbVisibility: widget.thumbVisibility,
      thickness: widget.thickness,
      thicknessWhileDragging: widget.thicknessWhileDragging,
      radius: widget.radius,
      radiusWhileDragging: widget.radiusWhileDragging,
      scrollbarOrientation: widget.scrollbarOrientation,
      mainAxisMargin: widget.mainAxisMargin,
      child: ListView.builder(
        controller: _controller,
        itemCount: 30,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text('${index + 1} 行目'),
        ),
      ),
    ),
  );
}

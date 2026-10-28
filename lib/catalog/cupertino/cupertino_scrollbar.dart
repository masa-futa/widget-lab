import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
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
      typeLabel: 'bool?',
      description: 'true ならスクロールしていなくても、つまみを出し続ける',
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'thickness',
      typeLabel: 'double',
      description: 'つまみの太さ。指定しないと 3',
      initiallyOn: false,
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
      name: 'radius',
      typeLabel: 'Radius',
      description: 'つまみの角の丸み。指定しないと 1.5',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 6,
        divisions: 6,
        initialValue: 0,
        resolve: Radius.circular,
        code: (v) => 'Radius.circular($v)',
      ),
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
  radius: args.valueOf<Radius>('radius') ?? CupertinoScrollbar.defaultRadius,
);

/// ScrollController を持ち、CupertinoScrollbar と ListView の両方に渡す（デモの部品）。
/// thumbVisibility が true のとき、つまみの位置を知るのに同じ controller が要る。
class _ScrollbarDemo extends StatefulWidget {
  const _ScrollbarDemo({
    required this.thumbVisibility,
    required this.thickness,
    required this.radius,
  });

  final bool? thumbVisibility;
  final double thickness;
  final Radius radius;

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
      radius: widget.radius,
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

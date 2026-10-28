import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final scrollbarEntry = WidgetEntry(
  id: 'scrollbar',
  name: 'Scrollbar',
  genreIds: const ['scrolling'],
  summary: 'スクロールの位置を示すつまみ（スクロールバー）を付ける',
  description:
      '子のスクロールの横に、今どこを見ているかを示すつまみを出します。'
      '既定ではスクロールしている間だけ出ます。ScrollController を子と同じものにします。'
      'ここでは 20 行の ListView を包んでいます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/Scrollbar-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'thumbVisibility',
      typeLabel: 'bool?',
      // false と trackVisibility: true は組み合わせられない（assert）ので、true だけを選べる
      description: 'スクロールしていないときも、つまみを出したままにする。指定しないとスクロール中だけ出す',
      control: FixedControl(value: true, source: 'true'),
    ),
    PropertySpec(
      name: 'trackVisibility',
      typeLabel: 'bool?',
      description: 'つまみの通り道（トラック）も出すか',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'thickness',
      typeLabel: 'double?',
      description: 'つまみの太さ',
      initiallyOn: false,
      control: SliderControl(
        min: 2,
        max: 16,
        divisions: 7,
        initialValue: 12,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'interactive',
      typeLabel: 'bool?',
      description: 'つまみをドラッグしてスクロールできるか',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
  ],
  build: _build,
  codeName: 'Scrollbar',
  codeArguments: const [
    'controller: controller',
    'child: ListView(controller: controller, children: tiles)',
  ],
);

Widget _build(DemoArgs args) => _ScrollbarDemo(
  thumbVisibility: args.valueOf<bool>('thumbVisibility'),
  trackVisibility: args.valueOf<bool>('trackVisibility'),
  thickness: args.valueOf<double>('thickness'),
  interactive: args.valueOf<bool>('interactive'),
);

/// Scrollbar と ListView に同じ ScrollController を渡す（つまみを出したままにするには要る）。
class _ScrollbarDemo extends StatefulWidget {
  const _ScrollbarDemo({
    required this.thumbVisibility,
    required this.trackVisibility,
    required this.thickness,
    required this.interactive,
  });

  final bool? thumbVisibility;
  final bool? trackVisibility;
  final double? thickness;
  final bool? interactive;

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
  Widget build(BuildContext context) => Scrollbar(
    controller: _controller,
    thumbVisibility: widget.thumbVisibility,
    trackVisibility: widget.trackVisibility,
    thickness: widget.thickness,
    interactive: widget.interactive,
    child: ListView(
      controller: _controller,
      children: [for (var i = 1; i <= 20; i++) DemoTile(i, height: 24)],
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
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
  properties: [
    const PropertySpec(
      name: 'thumbVisibility',
      group: PropertyGroup.behavior,
      typeLabel: 'bool?',
      // false と trackVisibility: true は組み合わせられない（assert）ので、true だけを選べる
      description: 'スクロールしていないときも、つまみを出したままにする。指定しないとスクロール中だけ出す',
      control: FixedControl(value: true, source: 'true'),
    ),
    const PropertySpec(
      name: 'trackVisibility',
      group: PropertyGroup.paint,
      typeLabel: 'bool?',
      description: 'つまみの通り道（トラック）も出すか',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'thickness',
      group: PropertyGroup.paint,
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
    const PropertySpec(
      name: 'interactive',
      group: PropertyGroup.behavior,
      typeLabel: 'bool?',
      description: 'つまみをドラッグしてスクロールできるか',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'radius',
      group: PropertyGroup.paint,
      typeLabel: 'Radius?',
      description: 'つまみの角の丸み',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 8,
        divisions: 2,
        initialValue: 0,
        resolve: Radius.circular,
        code: (v) => 'Radius.circular($v)',
      ),
    ),
    PropertySpec(
      name: 'scrollbarOrientation',
      group: PropertyGroup.layout,
      typeLabel: 'ScrollbarOrientation?',
      description: 'つまみを出す側。縦のスクロールでは left か right。指定しないと文字の向きに合わせて右',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          // 縦のスクロールに top・bottom を渡すと assert で落ちる
          for (final side in [
            ScrollbarOrientation.left,
            ScrollbarOrientation.right,
          ])
            Choice(side.name, side, 'ScrollbarOrientation.${side.name}'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget',
      description: 'つまみを付けるスクロール（20 行の ListView）。Scrollbar と同じ controller を渡す',
      required: true,
      control: FixedControl(
        value: _list,
        source: 'ListView(controller: controller, children: tiles)',
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
      name: 'controller',
      typeLabel: 'ScrollController?',
      description: 'つまみが位置を読むスクロール。子のスクロールと同じものを渡す',
    ),
    ReferenceArg(
      name: 'notificationPredicate',
      typeLabel: 'ScrollNotificationPredicate?',
      description: 'どのスクロールの通知でつまみを動かすか。既定は、すぐ下の子のスクロールだけ',
    ),
  ],
  build: _build,
  codeName: 'Scrollbar',
  codeArguments: const ['controller: controller'],
);

/// つまみを付けるリスト（20 行）。Scrollbar と同じ controller を受け取る。
Widget _list(ScrollController controller) => ListView(
  controller: controller,
  children: [for (var i = 1; i <= 20; i++) DemoTile(i, height: 24)],
);

// child は必須のプロパティなので、常に値がある
Widget _build(DemoArgs args) => _ScrollbarDemo(
  thumbVisibility: args.valueOf<bool>('thumbVisibility'),
  trackVisibility: args.valueOf<bool>('trackVisibility'),
  thickness: args.valueOf<double>('thickness'),
  interactive: args.valueOf<bool>('interactive'),
  radius: args.valueOf<Radius>('radius'),
  scrollbarOrientation: args.valueOf<ScrollbarOrientation>(
    'scrollbarOrientation',
  ),
  child: args.valueOf<_ListBuilder>('child')!,
);

typedef _ListBuilder = Widget Function(ScrollController controller);

/// Scrollbar と ListView に同じ ScrollController を渡す（つまみを出したままにするには要る）。
class _ScrollbarDemo extends StatefulWidget {
  const _ScrollbarDemo({
    required this.thumbVisibility,
    required this.trackVisibility,
    required this.thickness,
    required this.interactive,
    required this.radius,
    required this.scrollbarOrientation,
    required this.child,
  });

  final bool? thumbVisibility;
  final bool? trackVisibility;
  final double? thickness;
  final bool? interactive;
  final Radius? radius;
  final ScrollbarOrientation? scrollbarOrientation;
  final _ListBuilder child;

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
    radius: widget.radius,
    scrollbarOrientation: widget.scrollbarOrientation,
    child: widget.child(_controller),
  );
}

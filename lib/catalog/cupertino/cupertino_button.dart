import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoButtonEntry = WidgetEntry(
  id: 'cupertinoButton',
  name: 'CupertinoButton',
  genreIds: const ['cupertino'],
  summary: 'iOS の見た目のボタン',
  description:
      '押すと薄くなる、iOS の見た目のボタンです。color を指定すると地が塗られます。'
      'onPressed が null なら押せない見た目になります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoButton-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'child',
      typeLabel: 'Widget',
      description: 'ボタンの中身',
      required: true,
      control: FixedControl(value: Text('保存'), source: "Text('保存')"),
    ),
    PropertySpec(
      name: 'sizeStyle',
      typeLabel: 'CupertinoButtonSize',
      description: 'ボタンの大きさ。文字の大きさと内側の余白が変わる',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 2,
        choices: [
          for (final size in CupertinoButtonSize.values)
            Choice(size.name, size, 'CupertinoButtonSize.${size.name}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'color',
      typeLabel: 'Color?',
      description: 'ボタンの地の色。指定しないと地を塗らない',
      control: ColorControl(
        palette: [
          const Choice(
            'activeBlue',
            CupertinoColors.activeBlue,
            'CupertinoColors.activeBlue',
          ),
          const Choice(
            'systemGreen',
            CupertinoColors.systemGreen,
            'CupertinoColors.systemGreen',
          ),
          const Choice(
            'systemRed',
            CupertinoColors.systemRed,
            'CupertinoColors.systemRed',
          ),
          Choice.color('墨', const Color(0xFF18181B)),
        ],
      ),
    ),
    PropertySpec(
      name: 'pressedOpacity',
      typeLabel: 'double?',
      description: '押している間の不透明度',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 1,
        divisions: 10,
        initialValue: 0.4,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'borderRadius',
      typeLabel: 'BorderRadius?',
      description: '地の角の丸み',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 6,
        initialValue: 8,
        resolve: (v) => BorderRadius.circular(v),
        code: (v) => 'BorderRadius.circular($v)',
      ),
    ),
    const PropertySpec(
      name: 'onPressed',
      typeLabel: 'VoidCallback?',
      description: '押したときに呼ばれる。null なら押せない見た目になる',
      control: FixedControl(value: _pressed, source: '() {}'),
    ),
  ],
  build: _build,
  codeName: 'CupertinoButton',
);

void _pressed() {}

Widget _build(DemoArgs args) => CupertinoButton(
  sizeStyle:
      args.valueOf<CupertinoButtonSize>('sizeStyle') ??
      CupertinoButtonSize.large,
  color: args.valueOf<Color>('color'),
  pressedOpacity: args.valueOf<double>('pressedOpacity') ?? 0.4,
  borderRadius: args.valueOf<BorderRadius>('borderRadius'),
  onPressed: args.valueOf<VoidCallback>('onPressed'),
  // 必須のプロパティなので、常に値がある
  child: args.valueOf<Widget>('child')!,
);

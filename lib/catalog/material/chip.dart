import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final chipEntry = WidgetEntry(
  id: 'chip',
  name: 'Chip',
  genreIds: const ['material'],
  summary: '属性やタグを小さな角丸の札で見せる',
  description:
      '人・タグ・属性などを、小さな角丸の札で見せます。左に avatar、右に消すボタンを付けられます。'
      '選んだり押したりする札には ChoiceChip・FilterChip・ActionChip を使います。',
  docUrl: Uri.parse('https://api.flutter.dev/flutter/material/Chip-class.html'),
  properties: [
    const PropertySpec(
      name: 'label',
      typeLabel: 'Widget',
      description: '札の文字',
      required: true,
      control: FixedControl(value: Text('Flutter'), source: "Text('Flutter')"),
    ),
    const PropertySpec(
      name: 'avatar',
      typeLabel: 'Widget?',
      description: '文字の左に置く Widget。ふつうはアイコンか CircleAvatar',
      control: FixedControl(
        value: Icon(Icons.local_offer),
        source: 'Icon(Icons.local_offer)',
      ),
    ),
    const PropertySpec(
      name: 'onDeleted',
      typeLabel: 'VoidCallback?',
      description: '渡すと右に消すボタン（×）が出て、押すと呼ばれる',
      initiallyOn: false,
      control: FixedControl(value: _noop, source: '() {}'),
    ),
    PropertySpec(
      name: 'backgroundColor',
      typeLabel: 'Color?',
      description: '札の地の色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('山吹', const Color(0xFFF8B500)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('白', const Color(0xFFFFFFFF)),
        ],
      ),
    ),
    PropertySpec(
      name: 'elevation',
      typeLabel: 'double?',
      description: '札の浮き上がりの高さ。影が付く',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 8,
        divisions: 4,
        initialValue: 4,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
  ],
  build: _build,
  codeName: 'Chip',
);

void _noop() {}

Widget _build(DemoArgs args) => Chip(
  label: args.valueOf<Widget>('label') ?? const SizedBox.shrink(),
  avatar: args.valueOf<Widget>('avatar'),
  onDeleted: args.valueOf<VoidCallback>('onDeleted'),
  backgroundColor: args.valueOf<Color>('backgroundColor'),
  elevation: args.valueOf<double>('elevation'),
);

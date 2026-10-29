import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoPickerDefaultSelectionOverlayEntry = WidgetEntry(
  id: 'cupertinoPickerDefaultSelectionOverlay',
  name: 'CupertinoPickerDefaultSelectionOverlay',
  genreIds: const ['cupertino'],
  summary: 'ピッカーの、選んでいる行に重ねる帯',
  description:
      'CupertinoPicker の真ん中の行に重ねる、角の丸い帯です。CupertinoPicker の selectionOverlay に渡します。'
      '横に複数のピッカーを並べるときは、つなぎ目の側の角を capStartEdge・capEndEdge で落とします。'
      'プレビューは CupertinoPicker に渡した形で描きます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoPickerDefaultSelectionOverlay-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'background',
      group: PropertyGroup.paint,
      typeLabel: 'Color',
      description: '帯の色。指定しないと tertiarySystemFill',
      control: ColorControl(
        palette: [
          const Choice(
            'systemYellow',
            CupertinoColors.systemYellow,
            'CupertinoColors.systemYellow',
          ),
          Choice.color('瑠璃（薄）', const Color(0x331E50A2)),
          Choice.color('紅（薄）', const Color(0x33D7003A)),
        ],
        initialIndex: 1,
      ),
    ),
    const PropertySpec(
      name: 'capStartEdge',
      group: PropertyGroup.layout,
      typeLabel: 'bool',
      description: '始まりの側（左）の角を丸め、余白を空けるか',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    const PropertySpec(
      name: 'capEndEdge',
      group: PropertyGroup.layout,
      typeLabel: 'bool',
      description: '終わりの側（右）の角を丸め、余白を空けるか',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
  ],
  build: _build,
  codeName: 'CupertinoPickerDefaultSelectionOverlay',
);

Widget _build(DemoArgs args) => SizedBox(
  width: 240,
  height: 150,
  child: CupertinoPicker(
    itemExtent: 32,
    onSelectedItemChanged: null,
    selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
      background:
          args.valueOf<Color>('background') ??
          CupertinoColors.tertiarySystemFill,
      capStartEdge: args.valueOf<bool>('capStartEdge') ?? true,
      capEndEdge: args.valueOf<bool>('capEndEdge') ?? true,
    ),
    children: const [
      Center(child: Text('1')),
      Center(child: Text('2')),
      Center(child: Text('3')),
      Center(child: Text('4')),
      Center(child: Text('5')),
    ],
  ),
);

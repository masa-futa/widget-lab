import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoPickerEntry = WidgetEntry(
  id: 'cupertinoPicker',
  name: 'CupertinoPicker',
  genreIds: const ['cupertino'],
  summary: '筒を回すように選ぶ、iOS の見た目のピッカー',
  description:
      '子を筒の面に並べ、回して真ん中に来たものを選ぶ iOS の見た目のピッカーです。'
      '選んだ番号は onSelectedItemChanged で受け取ります。高さは親が決めます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoPicker-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'itemExtent',
      group: PropertyGroup.size,
      typeLabel: 'double',
      description: '1 行の高さ',
      required: true,
      control: SliderControl(
        min: 24,
        max: 64,
        divisions: 8,
        initialValue: 32,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'diameterRatio',
      group: PropertyGroup.transform,
      typeLabel: 'double',
      description: '筒の直径と、ピッカーの高さの比。小さいほど強く曲がって見える',
      initiallyOn: false,
      control: SliderControl(
        min: 0.5,
        max: 3,
        divisions: 5,
        initialValue: 1.07,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'offAxisFraction',
      group: PropertyGroup.transform,
      typeLabel: 'double',
      description: '筒を横から見たように、行の並びを左右へ曲げる量（ピッカーの幅に対する割合）',
      initiallyOn: false,
      control: SliderControl(
        min: -0.5,
        max: 0.5,
        divisions: 4,
        initialValue: 0.25,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'squeeze',
      group: PropertyGroup.layout,
      typeLabel: 'double',
      description: '行の詰まり具合。大きいほど行が詰まって多く見える',
      initiallyOn: false,
      control: SliderControl(
        min: 0.5,
        max: 2,
        divisions: 6,
        initialValue: 1.45,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    const PropertySpec(
      name: 'useMagnifier',
      group: PropertyGroup.transform,
      typeLabel: 'bool',
      description: 'true なら真ん中の行を magnification の倍率で大きく出す',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'magnification',
      group: PropertyGroup.transform,
      typeLabel: 'double',
      description: 'useMagnifier が true のときの、真ん中の行の倍率',
      initiallyOn: false,
      requires: 'useMagnifier',
      control: SliderControl(
        min: 1,
        max: 1.5,
        divisions: 5,
        initialValue: 1.2,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'backgroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'ピッカーの地の色。不透明でない色にすると、上下の端を薄くする効果が消える',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          const Choice(
            'systemYellow',
            CupertinoColors.systemYellow,
            'CupertinoColors.systemYellow',
          ),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('瑠璃（薄）', const Color(0x331E50A2)),
        ],
      ),
    ),
    const PropertySpec(
      name: 'selectionOverlay',
      group: PropertyGroup.paint,
      typeLabel: 'Widget?',
      description: '真ん中の行に重ねる Widget。指定しないと角の丸い灰色の帯（CupertinoPickerDefaultSelectionOverlay）',
      initiallyOn: false,
      control: FixedControl(value: _overlay, source: _overlaySource),
    ),
    const PropertySpec(
      name: 'looping',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: 'true なら最後の次に最初が来て、ぐるぐる回せる',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'onSelectedItemChanged',
      group: PropertyGroup.behavior,
      typeLabel: 'ValueChanged<int>?',
      description: '真ん中に来た行の番号で呼ばれる',
      required: true,
      control: FixedControl(value: _changed, source: '(index) {}'),
    ),
    const PropertySpec(
      name: 'children',
      group: PropertyGroup.content,
      typeLabel: 'List<Widget>',
      description: '並べる行',
      required: true,
      control: FixedControl(
        value: _fruits,
        source:
            "[for (final name in ['りんご', 'みかん', 'ぶどう', 'もも', 'なし', 'かき']) "
            'Center(child: Text(name))]',
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
      name: 'scrollController',
      typeLabel: 'FixedExtentScrollController?',
      description: '最初に選んでおく行を決めたり、選んでいる行を読んだり動かしたりする',
    ),
    ReferenceArg(
      name: 'changeReportingBehavior',
      typeLabel: 'ChangeReportingBehavior',
      description: 'onSelectedItemChanged を、回している間ずっと呼ぶか、止まったときだけ呼ぶか',
    ),
  ],
  build: _build,
  codeName: 'CupertinoPicker',
);

void _changed(int index) {}

const _fruits = [
  Center(child: Text('りんご')),
  Center(child: Text('みかん')),
  Center(child: Text('ぶどう')),
  Center(child: Text('もも')),
  Center(child: Text('なし')),
  Center(child: Text('かき')),
];

const _overlay = DecoratedBox(
  decoration: BoxDecoration(
    border: Border.symmetric(
      horizontal: BorderSide(color: CupertinoColors.systemBlue),
    ),
  ),
);
const _overlaySource =
    'DecoratedBox(decoration: BoxDecoration(border: Border.symmetric('
    'horizontal: BorderSide(color: CupertinoColors.systemBlue))))';

Widget _build(DemoArgs args) {
  final looping = args.valueOf<bool>('looping') ?? false;
  return SizedBox(
    width: 240,
    height: 180,
    child: CupertinoPicker(
      // looping で子の並べ方（delegate）が変わるので、変わったら作り直す
      key: ValueKey(looping),
      // 必須のプロパティなので、常に値がある
      itemExtent: args.valueOf<double>('itemExtent')!,
      diameterRatio: args.valueOf<double>('diameterRatio') ?? 1.07,
      offAxisFraction: args.valueOf<double>('offAxisFraction') ?? 0,
      squeeze: args.valueOf<double>('squeeze') ?? 1.45,
      useMagnifier: args.valueOf<bool>('useMagnifier') ?? false,
      magnification: args.valueOf<double>('magnification') ?? 1,
      backgroundColor: args.valueOf<Color>('backgroundColor'),
      selectionOverlay:
          args.valueOf<Widget>('selectionOverlay') ??
          const CupertinoPickerDefaultSelectionOverlay(),
      looping: looping,
      onSelectedItemChanged: args.valueOf<ValueChanged<int>>(
        'onSelectedItemChanged',
      ),
      children: args.valueOf<List<Widget>>('children')!,
    ),
  );
}

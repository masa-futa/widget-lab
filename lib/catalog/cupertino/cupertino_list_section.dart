import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoListSectionEntry = WidgetEntry(
  id: 'cupertinoListSection',
  name: 'CupertinoListSection',
  genreIds: const ['cupertino'],
  summary: 'iOS のリストの行を、見出しつきの 1 区画にまとめる',
  description:
      'CupertinoListTile などの行を、見出し（header）・補足（footer）と一緒に 1 区画にまとめ、'
      '行の間に区切り線を引きます。区切り線は行の始まりのアイコンの分だけ右から始まります（hasLeading）。'
      '角の丸い区画にするときは CupertinoListSection.insetGrouped を使います。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoListSection-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'header',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '区画の上に出す見出し',
      control: FixedControl(value: Text('一般'), source: "Text('一般')"),
    ),
    const PropertySpec(
      name: 'footer',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '区画の下に出す補足',
      initiallyOn: false,
      control: FixedControl(
        value: Text('変更はすぐに反映されます'),
        source: "Text('変更はすぐに反映されます')",
      ),
    ),
    const PropertySpec(
      name: 'hasLeading',
      group: PropertyGroup.layout,
      typeLabel: 'bool',
      description: '行の始まりにアイコンがあるか。false なら区切り線を行の端近くから引く',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'dividerMargin',
      group: PropertyGroup.layout,
      typeLabel: 'double',
      description: '区切り線の始まりの余白。指定しないと 20',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 60,
        divisions: 6,
        initialValue: 40,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'additionalDividerMargin',
      group: PropertyGroup.layout,
      typeLabel: 'double?',
      description: '区切り線の始まりに dividerMargin へ足す余白。指定すると hasLeading より優先する。指定しないと hasLeading なら 44、そうでなければ 0',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 80,
        divisions: 8,
        initialValue: 0,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'separatorColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '区切り線と、行のまとまりの上下の線の色。指定しないと separator',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅', const Color(0xFFD7003A)),
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
        ],
      ),
    ),
    PropertySpec(
      name: 'backgroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color',
      description: '区画のまわり（見出しの地）の色。指定しないと systemGroupedBackground',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          const Choice(
            'systemGrey5',
            CupertinoColors.systemGrey5,
            'CupertinoColors.systemGrey5',
          ),
          Choice.color('若竹（薄）', const Color(0x3368BE8D)),
        ],
      ),
    ),
    PropertySpec(
      name: 'decoration',
      group: PropertyGroup.paint,
      typeLabel: 'BoxDecoration?',
      description: '行のまとまりの地に描く飾り。指定しないと secondarySystemGroupedBackground で塗る',
      initiallyOn: false,
      control: _decorationControl(),
    ),
    PropertySpec(
      name: 'margin',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry',
      description: '行のまとまりの外の余白。指定しないと下に 8',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 32,
        divisions: 8,
        initialValue: 16,
        resolve: EdgeInsets.all,
        code: (v) => 'EdgeInsets.all($v)',
      ),
    ),
    PropertySpec(
      name: 'topMargin',
      group: PropertyGroup.spacing,
      typeLabel: 'double?',
      description: '区画の上の余白。指定しないと iOS と同じ 22',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 44,
        divisions: 4,
        initialValue: 0,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    const PropertySpec(
      name: 'children',
      group: PropertyGroup.content,
      typeLabel: 'List<Widget>?',
      description: '区画に並べる行',
      required: true,
      control: FixedControl(
        value: [
          CupertinoListTile(
            leading: Icon(CupertinoIcons.wifi),
            title: Text('Wi-Fi'),
          ),
          CupertinoListTile(
            leading: Icon(CupertinoIcons.bluetooth),
            title: Text('Bluetooth'),
          ),
        ],
        source:
            "[CupertinoListTile(leading: Icon(CupertinoIcons.wifi), title: Text('Wi-Fi')), "
            "CupertinoListTile(leading: Icon(CupertinoIcons.bluetooth), title: Text('Bluetooth'))]",
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
      name: 'clipBehavior',
      typeLabel: 'Clip',
      description:
          '行のまとまりを角の形で切り抜くか。このコンストラクタでは角が丸くないので、見た目は変わらない（insetGrouped で効く）',
    ),
  ],
  build: _build,
  codeName: 'CupertinoListSection',
);

NestedControl _decorationControl() => NestedControl(
  typeName: 'BoxDecoration',
  children: [
    PropertySpec(
      name: 'color',
      typeLabel: 'Color?',
      description: '飾りの地の色',
      control: ColorControl(
        palette: [
          Choice.color('山吹（薄）', const Color(0x33F8B500)),
          Choice.color('瑠璃（薄）', const Color(0x331E50A2)),
        ],
      ),
    ),
    PropertySpec(
      name: 'borderRadius',
      typeLabel: 'BorderRadiusGeometry?',
      description: '角の丸み',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 6,
        initialValue: 12,
        resolve: BorderRadius.circular,
        code: (v) => 'BorderRadius.circular($v)',
      ),
    ),
    PropertySpec(
      name: 'border',
      typeLabel: 'BoxBorder?',
      description: 'まとまりのふちの線',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [Choice('細い線', Border.all(width: 2), 'Border.all(width: 2)')],
      ),
    ),
  ],
  build: (values) => BoxDecoration(
    color: values['color'] as Color?,
    borderRadius: values['borderRadius'] as BorderRadiusGeometry?,
    border: values['border'] as BoxBorder?,
  ),
);

Widget _build(DemoArgs args) => FittedBox(
  // 比較中の低いカードでも Column がはみ出さないよう、収まらなければ縮める
  fit: BoxFit.scaleDown,
  child: SizedBox(
    width: 320,
    child: CupertinoListSection(
      header: args.valueOf<Widget>('header'),
      footer: args.valueOf<Widget>('footer'),
      hasLeading: args.valueOf<bool>('hasLeading') ?? true,
      dividerMargin: args.valueOf<double>('dividerMargin') ?? 20,
      additionalDividerMargin: args.valueOf<double>('additionalDividerMargin'),
      separatorColor: args.valueOf<Color>('separatorColor'),
      backgroundColor:
          args.valueOf<Color>('backgroundColor') ??
          CupertinoColors.systemGroupedBackground,
      decoration: args.valueOf<BoxDecoration>('decoration'),
      margin:
          args.valueOf<EdgeInsetsGeometry>('margin') ??
          const EdgeInsets.only(bottom: 8),
      topMargin: args.valueOf<double>('topMargin') ?? 22,
      children: args.valueOf<List<Widget>>('children'),
    ),
  ),
);

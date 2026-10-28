import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
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
      typeLabel: 'Widget?',
      description: '区画の上に出す見出し',
      control: FixedControl(value: Text('一般'), source: "Text('一般')"),
    ),
    const PropertySpec(
      name: 'footer',
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
      typeLabel: 'bool',
      description: '行の始まりにアイコンがあるか。false なら区切り線を行の端近くから引く',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'dividerMargin',
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
      name: 'backgroundColor',
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
    const PropertySpec(
      name: 'children',
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
  build: _build,
  codeName: 'CupertinoListSection',
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
      backgroundColor:
          args.valueOf<Color>('backgroundColor') ??
          CupertinoColors.systemGroupedBackground,
      children: args.valueOf<List<Widget>>('children'),
    ),
  ),
);

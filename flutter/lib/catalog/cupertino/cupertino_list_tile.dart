import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoListTileEntry = WidgetEntry(
  id: 'cupertinoListTile',
  name: 'CupertinoListTile',
  genreIds: const ['cupertino'],
  summary: 'iOS の設定画面のような、リストの 1 行',
  description:
      '始まりのアイコン（leading）・題（title）・副題（subtitle）・右の補足（additionalInfo）・'
      '終わりの印（trailing）を決まった位置に並べる、iOS のリストの 1 行です。'
      'onTap を渡すと、押している間だけ地の色が変わります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoListTile-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'title',
      group: PropertyGroup.content,
      typeLabel: 'Widget',
      description: '行の題',
      required: true,
      control: FixedControl(value: Text('Wi-Fi'), source: "Text('Wi-Fi')"),
    ),
    const PropertySpec(
      name: 'subtitle',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '題の下の小さな文',
      initiallyOn: false,
      control: FixedControl(value: Text('接続済み'), source: "Text('接続済み')"),
    ),
    const PropertySpec(
      name: 'leading',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '行の始まりのアイコン',
      control: FixedControl(
        value: Icon(CupertinoIcons.wifi),
        source: 'Icon(CupertinoIcons.wifi)',
      ),
    ),
    const PropertySpec(
      name: 'additionalInfo',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '終わりの印の手前に出す補足',
      control: FixedControl(
        value: Text('nimi-home'),
        source: "Text('nimi-home')",
      ),
    ),
    const PropertySpec(
      name: 'trailing',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '行の終わりの印。次の画面へ進む行には CupertinoListTileChevron',
      control: FixedControl(
        value: CupertinoListTileChevron(),
        source: 'CupertinoListTileChevron()',
      ),
    ),
    const PropertySpec(
      name: 'onTap',
      group: PropertyGroup.behavior,
      typeLabel: 'FutureOr<void> Function()?',
      description: '押したときに呼ばれる。渡すと押している間だけ地の色が変わる',
      initiallyOn: false,
      control: FixedControl(value: _tapped, source: '() {}'),
    ),
    PropertySpec(
      name: 'backgroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '行の地の色。指定しないと透明',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          const Choice(
            'systemGrey6',
            CupertinoColors.systemGrey6,
            'CupertinoColors.systemGrey6',
          ),
          Choice.color('山吹（薄）', const Color(0x33F8B500)),
        ],
      ),
    ),
    PropertySpec(
      name: 'backgroundColorActivated',
      group: PropertyGroup.paint,
      requires: 'onTap',
      typeLabel: 'Color?',
      description: '押している間の地の色。指定しないと systemGrey4',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('若竹（薄）', const Color(0x6668BE8D)),
          Choice.color('紅（薄）', const Color(0x66D7003A)),
        ],
      ),
    ),
    PropertySpec(
      name: 'padding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry?',
      description: '行の内側の余白。指定しないと始まり 20・終わり 14',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 32,
        divisions: 8,
        initialValue: 8,
        resolve: EdgeInsets.all,
        code: (v) => 'EdgeInsets.all($v)',
      ),
    ),
    PropertySpec(
      name: 'leadingSize',
      group: PropertyGroup.size,
      typeLabel: 'double',
      description: 'leading を置く正方形の一辺。leading がないときも行の高さの下限になる。指定しないと 28',
      initiallyOn: false,
      control: SliderControl(
        min: 16,
        max: 56,
        divisions: 5,
        initialValue: 48,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'leadingToTitle',
      group: PropertyGroup.spacing,
      requires: 'leading',
      typeLabel: 'double',
      description: 'leading と題の間の幅。指定しないと 16',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 40,
        divisions: 5,
        initialValue: 32,
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
  ],
  build: _build,
  codeName: 'CupertinoListTile',
);

void _tapped() {}

Widget _build(DemoArgs args) => FittedBox(
  // 見本（幅 240）で行の中身がはみ出さないよう、決めた幅で組んでから縮める
  fit: BoxFit.scaleDown,
  child: SizedBox(
    width: 320,
    child: CupertinoListTile(
      // 必須のプロパティなので、常に値がある
      title: args.valueOf<Widget>('title')!,
      subtitle: args.valueOf<Widget>('subtitle'),
      leading: args.valueOf<Widget>('leading'),
      additionalInfo: args.valueOf<Widget>('additionalInfo'),
      trailing: args.valueOf<Widget>('trailing'),
      onTap: args.valueOf<VoidCallback>('onTap'),
      backgroundColor: args.valueOf<Color>('backgroundColor'),
      backgroundColorActivated: args.valueOf<Color>('backgroundColorActivated'),
      padding: args.valueOf<EdgeInsetsGeometry>('padding'),
      leadingSize: args.valueOf<double>('leadingSize') ?? 28,
      leadingToTitle: args.valueOf<double>('leadingToTitle') ?? 16,
    ),
  ),
);

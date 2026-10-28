import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
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
      typeLabel: 'Widget',
      description: '行の題',
      required: true,
      control: FixedControl(value: Text('Wi-Fi'), source: "Text('Wi-Fi')"),
    ),
    const PropertySpec(
      name: 'subtitle',
      typeLabel: 'Widget?',
      description: '題の下の小さな文',
      initiallyOn: false,
      control: FixedControl(value: Text('接続済み'), source: "Text('接続済み')"),
    ),
    const PropertySpec(
      name: 'leading',
      typeLabel: 'Widget?',
      description: '行の始まりのアイコン',
      control: FixedControl(
        value: Icon(CupertinoIcons.wifi),
        source: 'Icon(CupertinoIcons.wifi)',
      ),
    ),
    const PropertySpec(
      name: 'additionalInfo',
      typeLabel: 'Widget?',
      description: '終わりの印の手前に出す補足',
      control: FixedControl(
        value: Text('nimi-home'),
        source: "Text('nimi-home')",
      ),
    ),
    const PropertySpec(
      name: 'trailing',
      typeLabel: 'Widget?',
      description: '行の終わりの印。次の画面へ進む行には CupertinoListTileChevron',
      control: FixedControl(
        value: CupertinoListTileChevron(),
        source: 'CupertinoListTileChevron()',
      ),
    ),
    const PropertySpec(
      name: 'onTap',
      typeLabel: 'FutureOr<void> Function()?',
      description: '押したときに呼ばれる。渡すと押している間だけ地の色が変わる',
      initiallyOn: false,
      control: FixedControl(value: _tapped, source: '() {}'),
    ),
    PropertySpec(
      name: 'backgroundColor',
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
    ),
  ),
);

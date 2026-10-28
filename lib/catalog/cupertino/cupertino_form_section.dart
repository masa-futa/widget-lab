import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoFormSectionEntry = WidgetEntry(
  id: 'cupertinoFormSection',
  name: 'CupertinoFormSection',
  genreIds: const ['cupertino'],
  summary: 'iOS のフォームの行を、見出しつきの 1 区画にまとめる',
  description:
      'CupertinoFormRow などの行を、上の見出し（header）・下の補足（footer）と一緒に 1 区画にまとめ、'
      '行の間に区切り線を引きます。角の丸い区画にするときは CupertinoFormSection.insetGrouped を使います。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoFormSection-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'header',
      typeLabel: 'Widget?',
      description: '区画の上に出す見出し',
      control: FixedControl(value: Text('アカウント'), source: "Text('アカウント')"),
    ),
    const PropertySpec(
      name: 'footer',
      typeLabel: 'Widget?',
      description: '区画の下に出す補足',
      initiallyOn: false,
      control: FixedControl(
        value: Text('名前はほかの人に見えます'),
        source: "Text('名前はほかの人に見えます')",
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
          Choice.color('山吹（薄）', const Color(0x33F8B500)),
        ],
      ),
    ),
    PropertySpec(
      name: 'margin',
      typeLabel: 'EdgeInsetsGeometry',
      description: '区画の外の余白。指定しないと 0',
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
    const PropertySpec(
      name: 'children',
      typeLabel: 'List<Widget>',
      description: '区画に並べる行。1 つ以上',
      required: true,
      control: FixedControl(
        value: [
          CupertinoFormRow(prefix: Text('名前'), child: Text('ニミ')),
          CupertinoFormRow(
            prefix: Text('メール'),
            child: Text('nimi@example.com'),
          ),
        ],
        source:
            "[CupertinoFormRow(prefix: Text('名前'), child: Text('ニミ')), "
            "CupertinoFormRow(prefix: Text('メール'), child: Text('nimi@example.com'))]",
      ),
    ),
  ],
  build: _build,
  codeName: 'CupertinoFormSection',
);

Widget _build(DemoArgs args) => FittedBox(
  // 比較中の低いカードでも Column がはみ出さないよう、収まらなければ縮める
  fit: BoxFit.scaleDown,
  child: SizedBox(
    width: 320,
    child: CupertinoFormSection(
      header: args.valueOf<Widget>('header'),
      footer: args.valueOf<Widget>('footer'),
      backgroundColor:
          args.valueOf<Color>('backgroundColor') ??
          CupertinoColors.systemGroupedBackground,
      margin: args.valueOf<EdgeInsetsGeometry>('margin') ?? EdgeInsets.zero,
      // 必須のプロパティなので、常に値がある
      children: args.valueOf<List<Widget>>('children')!,
    ),
  ),
);

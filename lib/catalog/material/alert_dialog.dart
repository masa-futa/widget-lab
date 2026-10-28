import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_stage.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// ふつうは showDialog で出すものを、AlertDialog そのものをカードの中に置いて見せる。
final alertDialogEntry = WidgetEntry(
  id: 'alertDialog',
  name: 'AlertDialog',
  genreIds: const ['material'],
  summary: '確認や知らせを出し、選んでもらうダイアログ',
  description:
      '大事な知らせや確認を出し、下のボタンで選んでもらうダイアログです。'
      'showDialog(context: context, builder: (context) => AlertDialog(…)) で出します。'
      'ここでは AlertDialog そのものをカードの中に置いて見ます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/AlertDialog-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'icon',
      typeLabel: 'Widget?',
      description: '題の上に置くアイコン',
      initiallyOn: false,
      control: FixedControl(
        value: Icon(Icons.delete_outline),
        source: 'Icon(Icons.delete_outline)',
      ),
    ),
    const PropertySpec(
      name: 'title',
      typeLabel: 'Widget?',
      description: 'ダイアログの題',
      control: FixedControl(value: Text('削除しますか？'), source: "Text('削除しますか？')"),
    ),
    const PropertySpec(
      name: 'content',
      typeLabel: 'Widget?',
      description: '題の下の本文',
      control: FixedControl(
        value: Text('削除したメモは元に戻せません。'),
        source: "Text('削除したメモは元に戻せません。')",
      ),
    ),
    const PropertySpec(
      name: 'actions',
      typeLabel: 'List<Widget>?',
      description: '下に並べるボタン。ふつうは TextButton',
      control: FixedControl(
        value: <Widget>[
          TextButton(onPressed: _noop, child: Text('キャンセル')),
          TextButton(onPressed: _noop, child: Text('削除')),
        ],
        source:
            "[TextButton(onPressed: () {}, child: Text('キャンセル')), "
            "TextButton(onPressed: () {}, child: Text('削除'))]",
      ),
    ),
    PropertySpec(
      name: 'actionsAlignment',
      typeLabel: 'MainAxisAlignment?',
      description: 'ボタンの横の並べ方。指定しないと右寄せ（end）',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final value in const [
            MainAxisAlignment.start,
            MainAxisAlignment.center,
            MainAxisAlignment.end,
            MainAxisAlignment.spaceBetween,
          ])
            Choice(value.name, value, 'MainAxisAlignment.${value.name}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'backgroundColor',
      typeLabel: 'Color?',
      description: 'ダイアログの地の色。指定しないとテーマの surfaceContainerHigh',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('生成', const Color(0xFFFBFAF5)),
          Choice.color('桜', const Color(0xFFFEF4F4)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
        ],
      ),
    ),
  ],
  build: _build,
  codeName: 'AlertDialog',
);

void _noop() {}

Widget _build(DemoArgs args) => DemoStage(
  size: const Size(360, 320),
  child: AlertDialog(
    icon: args.valueOf<Widget>('icon'),
    title: args.valueOf<Widget>('title'),
    content: args.valueOf<Widget>('content'),
    actions: args.valueOf<List<Widget>>('actions'),
    actionsAlignment: args.valueOf<MainAxisAlignment>('actionsAlignment'),
    backgroundColor: args.valueOf<Color>('backgroundColor'),
  ),
);

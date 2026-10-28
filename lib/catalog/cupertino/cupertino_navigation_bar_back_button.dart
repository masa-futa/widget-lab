import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoNavigationBarBackButtonEntry = WidgetEntry(
  id: 'cupertinoNavigationBarBackButton',
  name: 'CupertinoNavigationBarBackButton',
  genreIds: const ['cupertino'],
  summary: '「‹ 前の画面の題」の iOS の戻るボタン',
  description:
      '山かっこと前の画面の題を並べた、iOS の戻るボタンです。'
      'CupertinoNavigationBar は戻れる画面でこれを自動で出します。'
      'onPressed を指定しないと、押したときに Navigator.maybePop で戻ります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoNavigationBarBackButton-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'color',
      typeLabel: 'Color?',
      description: '山かっこと文字の色。指定しないとテーマの主な色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          const Choice(
            'systemPink',
            CupertinoColors.systemPink,
            'CupertinoColors.systemPink',
          ),
          Choice.color('墨', const Color(0xFF18181B)),
        ],
      ),
    ),
    const PropertySpec(
      name: 'previousPageTitle',
      typeLabel: 'String?',
      description: '山かっこの横に出す文字。指定しないと前の Route の題（なければ出さない）',
      control: TextControl(initialValue: '一覧'),
    ),
    // null だとプレビューで押したときにアプリの Navigator を戻し、詳細画面が閉じるので必須にする
    const PropertySpec(
      name: 'onPressed',
      typeLabel: 'VoidCallback?',
      description: '押したときに呼ばれる。null なら Navigator.maybePop で戻る（ここでは何もしない関数）',
      required: true,
      control: FixedControl(value: _pressed, source: '() {}'),
    ),
  ],
  build: _build,
  codeName: 'CupertinoNavigationBarBackButton',
);

void _pressed() {}

Widget _build(DemoArgs args) => CupertinoNavigationBarBackButton(
  color: args.valueOf<Color>('color'),
  previousPageTitle: args.valueOf<String>('previousPageTitle'),
  onPressed: args.valueOf<VoidCallback>('onPressed'),
);

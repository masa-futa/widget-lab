import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final textFieldEntry = WidgetEntry(
  id: 'textField',
  name: 'TextField',
  genreIds: const ['material'],
  summary: 'キーボードで文字を入れる欄',
  description:
      'キーボードで文字を入れる欄です。見出し・ヒント・枠などの見た目は decoration（InputDecoration）で決めます。'
      '入れた文字は controller か onChanged で受け取ります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/TextField-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'decoration',
      typeLabel: 'InputDecoration?',
      description: '欄の見た目。指定しないと下線だけ。null を渡すと飾りなし',
      control: ChoiceControl(
        choices: [
          Choice(
            '見出し',
            InputDecoration(labelText: '名前'),
            "InputDecoration(labelText: '名前')",
          ),
          Choice(
            '枠つき',
            InputDecoration(border: OutlineInputBorder(), labelText: '名前'),
            "InputDecoration(border: OutlineInputBorder(), labelText: '名前')",
          ),
          Choice(
            'ヒント',
            InputDecoration(hintText: '山田 太郎', prefixIcon: Icon(Icons.person)),
            "InputDecoration(hintText: '山田 太郎', prefixIcon: Icon(Icons.person))",
          ),
          Choice(
            '誤り',
            InputDecoration(labelText: '名前', errorText: '入力してください'),
            "InputDecoration(labelText: '名前', errorText: '入力してください')",
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'enabled',
      typeLabel: 'bool?',
      description: '入力できるか。false だと薄い見た目になり、押してもキーボードが出ない',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    const PropertySpec(
      name: 'obscureText',
      typeLabel: 'bool',
      description: '入れた文字を ● で隠すか（パスワード用）。文字を入れると違いが見える',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'maxLength',
      typeLabel: 'int?',
      description: '入れられる文字数の上限。指定すると右下に「0/10」のような数が出る',
      initiallyOn: false,
      control: SliderControl(
        min: 5,
        max: 30,
        divisions: 5,
        initialValue: 10,
        resolve: (v) => v.round(),
        code: (v) => '${v.round()}',
      ),
    ),
    PropertySpec(
      name: 'textAlign',
      typeLabel: 'TextAlign',
      description: '欄の中での文字の横の揃え方',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 2,
        choices: [
          for (final value in const [
            TextAlign.left,
            TextAlign.right,
            TextAlign.center,
            TextAlign.start,
            TextAlign.end,
          ])
            Choice(value.name, value, 'TextAlign.${value.name}'),
        ],
      ),
    ),
  ],
  build: _build,
  codeName: 'TextField',
);

Widget _build(DemoArgs args) => TextField(
  decoration:
      args.valueOf<InputDecoration>('decoration') ?? const InputDecoration(),
  enabled: args.valueOf<bool>('enabled'),
  obscureText: args.valueOf<bool>('obscureText') ?? false,
  maxLength: args.valueOf<int>('maxLength'),
  textAlign: args.valueOf<TextAlign>('textAlign') ?? TextAlign.start,
);

import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoTextFormFieldRowEntry = WidgetEntry(
  id: 'cupertinoTextFormFieldRow',
  name: 'CupertinoTextFormFieldRow',
  genreIds: const ['cupertino'],
  summary: 'フォームの 1 行に置く、見出しつきの入力欄',
  description:
      '左に見出し（prefix）、右に枠のない入力欄を並べた、iOS の設定画面のような 1 行です。'
      'FormField なので、Form の中に置くと validator でまとめて確かめられ、'
      '誤りがあれば行の下に出します。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoTextFormFieldRow-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'prefix',
      typeLabel: 'Widget?',
      description: '行の左に置く見出し',
      control: FixedControl(value: Text('名前'), source: "Text('名前')"),
    ),
    const PropertySpec(
      name: 'placeholder',
      typeLabel: 'String?',
      description: '中が空の間に薄く出す文字',
      control: TextControl(initialValue: '必須'),
    ),
    const PropertySpec(
      name: 'initialValue',
      typeLabel: 'String?',
      description: '最初に入っている文字',
      initiallyOn: false,
      control: TextControl(initialValue: '山田'),
    ),
    const PropertySpec(
      name: 'validator',
      typeLabel: 'FormFieldValidator<String>?',
      description: '入れた文字を確かめる。誤りの文を返すと、行の下に出す',
      control: FixedControl(
        value: _validate,
        source: "(value) => value == null || value.isEmpty ? '入力してください' : null",
      ),
    ),
    PropertySpec(
      name: 'autovalidateMode',
      typeLabel: 'AutovalidateMode',
      description:
          'いつ validator で確かめるか。既定の disabled は Form の validate を呼んだときだけ',
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          for (final mode in const [
            AutovalidateMode.disabled,
            AutovalidateMode.always,
            AutovalidateMode.onUserInteraction,
          ])
            Choice(mode.name, mode, 'AutovalidateMode.${mode.name}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'padding',
      typeLabel: 'EdgeInsetsGeometry?',
      description: '行の内側の余白',
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
  ],
  build: _build,
  codeName: 'CupertinoTextFormFieldRow',
);

String? _validate(String? value) =>
    value == null || value.isEmpty ? '入力してください' : null;

Widget _build(DemoArgs args) {
  final initialValue = args.valueOf<String>('initialValue');
  return FittedBox(
    // 比較中の低いカードでもはみ出さないよう、高さが足りなければ縮める
    fit: BoxFit.scaleDown,
    child: SizedBox(
      width: 300,
      child: CupertinoTextFormFieldRow(
        // 最初の文字は FormField の State が作られたときだけ読まれるので、変えたら作り直す
        key: ValueKey(initialValue),
        prefix: args.valueOf<Widget>('prefix'),
        placeholder: args.valueOf<String>('placeholder'),
        initialValue: initialValue,
        validator: args.valueOf<FormFieldValidator<String>>('validator'),
        autovalidateMode:
            args.valueOf<AutovalidateMode>('autovalidateMode') ??
            AutovalidateMode.disabled,
        padding: args.valueOf<EdgeInsetsGeometry>('padding'),
      ),
    ),
  );
}

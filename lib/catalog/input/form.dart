import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_stage.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final formEntry = WidgetEntry(
  id: 'form',
  name: 'Form',
  genreIds: const ['input'],
  summary: '中の入力欄をまとめて検証・保存・リセットする',
  description:
      '中の FormField（TextFormField など）をまとめます。Form.of(context).validate() で'
      '全部の欄の validator を一度に呼び、エラーを欄の下に出します。'
      'autovalidateMode で、送信を押す前から検証するかを決めます。',
  docUrl: Uri.parse('https://api.flutter.dev/flutter/widgets/Form-class.html'),
  properties: [
    PropertySpec(
      name: 'autovalidateMode',
      typeLabel: 'AutovalidateMode?',
      description:
          'いつ検証するか。always は最初から、onUserInteraction は入力のたび、'
          'disabled（既定）は validate() を呼んだときだけ',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          for (final value in AutovalidateMode.values)
            Choice(value.name, value, 'AutovalidateMode.${value.name}'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'child',
      typeLabel: 'Widget',
      description: '中に置く Widget。ここでは名前とメールの欄と「送信」ボタン',
      required: true,
      control: FixedControl(value: _Fields(), source: 'const Fields()'),
    ),
  ],
  build: _build,
  codeName: 'Form',
);

Widget _build(DemoArgs args) => DemoStage(
  size: const Size(320, 240),
  child: Form(
    autovalidateMode: args.valueOf<AutovalidateMode>('autovalidateMode'),
    child: args.valueOf<Widget>('child') ?? const SizedBox.shrink(),
  ),
);

/// Form の中に置く欄とボタン。
class _Fields extends StatelessWidget {
  const _Fields();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 8,
    children: [
      TextFormField(
        decoration: const InputDecoration(labelText: '名前'),
        validator: (value) =>
            (value == null || value.isEmpty) ? '名前を入れてください' : null,
      ),
      TextFormField(
        decoration: const InputDecoration(labelText: 'メール'),
        validator: (value) => (value ?? '').contains('@') ? null : '@ を含めてください',
      ),
      Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Builder(
          // Form.of は Form の下の context で引く
          builder: (context) => FilledButton(
            onPressed: () => Form.of(context).validate(),
            child: const Text('送信'),
          ),
        ),
      ),
    ],
  );
}

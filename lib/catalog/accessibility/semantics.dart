import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_scope.dart';
import 'package:widget_lab/catalog/demo/semantics_readout.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final semanticsEntry = WidgetEntry(
  id: 'semantics',
  name: 'Semantics',
  genreIds: const ['accessibility'],
  summary: '子に読み上げの名前や役割を付ける',
  description:
      'VoiceOver・TalkBack が読む名前（label）や役割（button など）を子に付けます。'
      '見た目は変わりません。文字のないアイコンだけのボタンは、付けないと何と読めばよいか伝わりません。'
      'プレビューの下に、読み上げの木を書き出します。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/Semantics-class.html',
  ),
  kind: EntryKind.behavior,
  properties: const [
    PropertySpec(
      name: 'label',
      typeLabel: 'String?',
      description: '読み上げる名前',
      control: TextControl(initialValue: '保存'),
    ),
    PropertySpec(
      name: 'button',
      typeLabel: 'bool?',
      description: 'ボタンとして読む（「ボタン」と添えて読む）',
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'hint',
      typeLabel: 'String?',
      description: '押すと何が起きるかの説明。名前のあとに読む',
      initiallyOn: false,
      control: TextControl(initialValue: '書いた内容を保存します'),
    ),
  ],
  build: _build,
  buildWithout: _buildWithout,
  codeName: 'Semantics',
  codeArguments: const ['child: const SaveIcon()'],
);

Widget _build(DemoArgs args) {
  final label = args.valueOf<String>('label');
  final button = args.valueOf<bool>('button');
  final hint = args.valueOf<String>('hint');
  final values = [
    if (label != null) 'label: $label',
    if (button != null) 'button: $button',
    if (hint != null) 'hint: $hint',
  ];
  return DemoFit(
    child: SemanticsReadout(
      label: 'Semantics(${values.join(', ')})',
      child: Semantics(
        label: label,
        button: button,
        hint: hint,
        child: const _SaveIcon(),
      ),
    ),
  );
}

/// 包みを外す。アイコンには文字がないので、読み上げには何も出ない。
Widget _buildWithout(DemoArgs args) =>
    const DemoFit(child: SemanticsReadout(child: _SaveIcon()));

/// 文字のない、押せるアイコン（デモの部品。コードでは `const SaveIcon()`）。
class _SaveIcon extends StatelessWidget {
  const _SaveIcon();

  @override
  Widget build(BuildContext context) => Center(
    child: GestureDetector(
      onTap: () {},
      child: const Icon(Icons.save_outlined, size: 32),
    ),
  );
}

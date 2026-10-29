import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_scope.dart';
import 'package:widget_lab/catalog/demo/demo_value.dart';
import 'package:widget_lab/catalog/demo/semantics_readout.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final mergeSemanticsEntry = WidgetEntry(
  id: 'mergeSemantics',
  name: 'MergeSemantics',
  genreIds: const ['accessibility'],
  summary: '子孫の読み上げを 1 つにまとめる',
  description:
      '子孫の読み上げのノードを 1 つにまとめ、まとめて 1 回で読ませます。'
      'チェックボックスとその説明の文のように、別々に読むと意味が切れる組に使います。'
      'プレビューの下に、読み上げの木を書き出します（チェックボックスは押すと変わります）。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/MergeSemantics-class.html',
  ),
  kind: EntryKind.behavior,
  properties: const [],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'child',
      typeLabel: 'Widget',
      description:
          '読み上げを 1 つにまとめる子孫。ここではチェックボックスと説明の文の組（コードでは const CheckRow()）',
    ),
  ],
  build: _build,
  buildWithout: _buildWithout,
  codeName: 'MergeSemantics',
  codeArguments: const ['child: const CheckRow()'],
);

Widget _build(DemoArgs args) => const DemoFit(
  child: SemanticsReadout(
    label: 'MergeSemantics()',
    child: MergeSemantics(child: _CheckRow()),
  ),
);

/// 包みを外す。チェックボックスと文が、別々のノードとして読まれる。
Widget _buildWithout(DemoArgs args) =>
    const DemoFit(child: SemanticsReadout(child: _CheckRow()));

/// チェックボックスと説明の文の組（デモの部品。コードでは `const CheckRow()`）。
class _CheckRow extends StatelessWidget {
  const _CheckRow();

  @override
  Widget build(BuildContext context) => DemoValue<bool>(
    initial: true,
    builder: (context, value, onChanged) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(value: value, onChanged: (value) => onChanged(value ?? false)),
        const Text('お知らせを受け取る'),
      ],
    ),
  );
}

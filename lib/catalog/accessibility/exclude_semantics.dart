import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_scope.dart';
import 'package:widget_lab/catalog/demo/semantics_readout.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final excludeSemanticsEntry = WidgetEntry(
  id: 'excludeSemantics',
  name: 'ExcludeSemantics',
  genreIds: const ['accessibility'],
  summary: '子孫を読み上げから外す',
  description:
      '子孫を読み上げの木から外し、VoiceOver・TalkBack が読まないようにします。見た目は変わりません。'
      '飾りのアイコンや、すぐ隣の文と同じことを言う部品に使います。'
      'プレビューの下に、読み上げの木を書き出します。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/ExcludeSemantics-class.html',
  ),
  kind: EntryKind.behavior,
  properties: const [
    PropertySpec(
      name: 'excluding',
      typeLabel: 'bool',
      description: 'false にすると外さない（条件で切り替えるときに使う）',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
  ],
  build: _build,
  buildWithout: _buildWithout,
  codeName: 'ExcludeSemantics',
  codeArguments: const ['child: const Badge()'],
);

Widget _build(DemoArgs args) {
  final excluding = args.valueOf<bool>('excluding') ?? true;
  return DemoFit(
    child: SemanticsReadout(
      label: 'ExcludeSemantics(excluding: $excluding)',
      child: ExcludeSemantics(excluding: excluding, child: const _Badge()),
    ),
  );
}

/// 包みを外す。飾りのアイコンと文が、そのまま読まれる。
Widget _buildWithout(DemoArgs args) =>
    const DemoFit(child: SemanticsReadout(child: _Badge()));

/// 飾りの印（デモの部品。コードでは `const Badge()`）。
class _Badge extends StatelessWidget {
  const _Badge();

  @override
  Widget build(BuildContext context) => const Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 4,
    children: [
      Icon(Icons.star, semanticLabel: '星'),
      Text('おすすめ'),
    ],
  );
}

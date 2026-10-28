import 'dart:ui' show CheckedState, Tristate;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/catalog/demo/demo_recorder.dart';
import 'package:widget_lab/catalog/demo/demo_scope.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';

/// 読み上げ（Semantics）の Widget のデモで、[child] の読み上げの木を下に書き出す部品。
///
/// 表示している間だけ読み上げの木を作らせ（`ensureSemantics`）、木が変わるたびに
/// [child] の中のノードを 1 行ずつ「「保存」、ボタン」のように並べる。変わったらログにも出す。
/// `RenderObject.debugSemantics` は release で使えないので、[child] を `identifier` 付きの
/// ノードで包み、`SemanticsOwner` の木から引く。
///
/// [label] を渡すと、[child] を [DemoScope]（点線と札）で囲む。札は読み上げの木に入るので、
/// 書き出す範囲（[child]）の外に置く。
class SemanticsReadout extends StatefulWidget {
  const SemanticsReadout({required this.child, this.label, super.key});

  final Widget child;
  final String? label;

  @override
  State<SemanticsReadout> createState() => _SemanticsReadoutState();
}

class _SemanticsReadoutState extends State<SemanticsReadout> {
  late final String _identifier = 'semanticsReadout${identityHashCode(this)}';
  SemanticsHandle? _handle;
  SemanticsOwner? _owner;
  List<String> _lines = const [];

  @override
  void initState() {
    super.initState();
    _handle = SemanticsBinding.instance.ensureSemantics();
    WidgetsBinding.instance.addPostFrameCallback((_) => _listen());
  }

  @override
  void dispose() {
    _owner?.removeListener(_changed);
    _handle?.dispose();
    super.dispose();
  }

  /// 木を作る窓口は読み上げを有効にしたあとのフレームでできるので、そこで聞き始める。
  void _listen() {
    if (!mounted) return;
    final owner = context.findRenderObject()?.owner?.semanticsOwner;
    if (owner == null) return;
    _owner = owner..addListener(_changed);
    _read();
  }

  /// 木が送られた（フレームの途中）。組み直しはフレームの後に回す。
  void _changed() => WidgetsBinding.instance
    ..addPostFrameCallback((_) => _read())
    ..ensureVisualUpdate();

  void _read() {
    if (!mounted) return;
    final root = _owner?.rootSemanticsNode;
    final scope = root == null ? null : _find(root);
    if (scope == null) return;
    final lines = <String>[];
    scope.visitChildren((node) {
      _collect(node, lines);
      return true;
    });
    if (listEquals(lines, _lines)) return;
    setState(() => _lines = lines);
    DemoRecorder.of(context)
        .log('読み上げ: ${lines.isEmpty ? 'なし' : lines.join(' / ')}');
  }

  SemanticsNode? _find(SemanticsNode node) {
    if (node.identifier == _identifier) return node;
    SemanticsNode? found;
    node.visitChildren((child) {
      found = _find(child);
      return found == null;
    });
    return found;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScaler = DemoRecorder.textScalerOf(context);
    final spacing = NimiSpacing.of(context);
    final measured = Semantics(
      container: true,
      // 中の注釈をこのノードに吸わせず、読み上げと同じく別々のノードにする
      explicitChildNodes: true,
      identifier: _identifier,
      child: widget.child,
    );
    final label = widget.label;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label == null)
          measured
        else
          DemoScope(label: label, child: measured),
        Gap(spacing.xs),
        // 書き出した文はデモの部品なので、読み上げない（読み上げると木が変わり、書き出しが重なる）
        ExcludeSemantics(
          child: Text(
            _lines.isEmpty ? '読み上げ: なし' : '読み上げ:\n${_lines.join('\n')}',
            textScaler: textScaler,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// [node] を読み上げる順に 1 行ずつ書き出す。まとめられたノード（MergeSemantics の中）は
/// まとめた先の 1 行に入るので、子へは降りない。
void _collect(SemanticsNode node, List<String> lines) {
  final line = describeSemantics(node.getSemanticsData());
  if (line.isNotEmpty) lines.add(line);
  if (node.mergeAllDescendantsIntoThisNode) return;
  node.visitChildren((child) {
    _collect(child, lines);
    return true;
  });
}

/// 1 つのノードの読み上げの文（例: `「保存」、ボタン`）。何も読まないノードは空。
String describeSemantics(SemanticsData data) {
  final flags = data.flagsCollection;
  return [
    if (data.label.isNotEmpty) '「${data.label}」',
    if (data.value.isNotEmpty) data.value,
    if (flags.isButton) 'ボタン',
    if (flags.isHeader) '見出し',
    if (flags.isImage) '画像',
    switch (flags.isChecked) {
      CheckedState.isTrue => 'チェックあり',
      CheckedState.isFalse => 'チェックなし',
      CheckedState.mixed => 'チェック一部',
      CheckedState.none => '',
    },
    switch (flags.isToggled) {
      Tristate.isTrue => 'オン',
      Tristate.isFalse => 'オフ',
      Tristate.none => '',
    },
    if (data.hint.isNotEmpty) data.hint,
  ].where((part) => part.isNotEmpty).join('、');
}

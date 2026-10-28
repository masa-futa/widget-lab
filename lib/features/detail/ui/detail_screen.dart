import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';
import 'package:widget_lab/features/detail/ui/probe/log_sheet.dart';
import 'package:widget_lab/features/detail/ui/probe/log_strip.dart';
import 'package:widget_lab/features/detail/ui/widgets/about_sheet.dart';
import 'package:widget_lab/features/detail/ui/widgets/code_sheet.dart';
import 'package:widget_lab/features/detail/ui/widgets/code_strip.dart';
import 'package:widget_lab/features/detail/ui/widgets/detail_preview.dart';
import 'package:widget_lab/features/detail/ui/widgets/detail_sheet.dart';
import 'package:widget_lab/features/detail/ui/widgets/editor_panel.dart';
import 'package:widget_lab/features/detail/ui/widgets/property_chips.dart';
import 'package:widget_lab/features/detail/view_model/comparing.dart';
import 'package:widget_lab/features/detail/view_model/detail_notifier.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// 詳細画面（cb_dtl）。上にプレビューとコードの帯、その下にプロパティのチップの列、
/// 下半分に選んだ 1 つを触る編集パネル。説明とコードの全文はシートで開く。
class DetailScreen extends ConsumerWidget {
  const DetailScreen({required this.entryId, super.key});

  /// 収録データの `WidgetEntry.id`。
  final String entryId;

  /// タブレットでも 1 カラムのまま、本文をこの幅に収めて中央に置く。
  static const _maxBodyWidth = 640.0;

  /// 本体が低いときも、編集パネルにこれだけの高さを残す。
  static const _minPanelHeight = 96.0;

  /// コードの帯とチップの列の高さ（間の余白を除く）。文字の拡大に合わせて多めに見積もる。
  static const _stripHeight = 44.0;
  static const _chipsHeight = 48.0;

  /// プレビューの領域（テストで高さを見る）。
  static const previewAreaKey = Key('previewArea');

  /// 編集パネルの領域（テストで高さを見る）。
  static const panelAreaKey = Key('panelArea');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = detailProvider(entryId);
    final name = ref.watch(provider.select((s) => s.entry.name));
    final isModified = ref.watch(provider.select((s) => s.isModified));
    final hasProperties = ref.watch(
      provider.select((s) => s.entry.properties.isNotEmpty),
    );
    final hasLogs = ref.watch(
      provider.select((s) => s.entry.kind == EntryKind.behavior),
    );
    final spacing = NimiSpacing.of(context);
    // キーボードが出たら、入力欄が隠れないようにプレビューを縮める
    final screenHeight = MediaQuery.sizeOf(context).height;
    final keyboardShown = MediaQuery.viewInsetsOf(context).bottom > 0;
    final preferredHeight = screenHeight * (keyboardShown ? 0.2 : 0.35);
    final textScaler = MediaQuery.textScalerOf(context);
    final middleHeight =
        (hasProperties
            ? textScaler.scale(_stripHeight) +
                  textScaler.scale(_chipsHeight) +
                  spacing.xs * 3
            : spacing.xs) +
        (hasLogs ? textScaler.scale(LogStrip.height) + spacing.xs : 0);
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: [
          IconButton(
            tooltip: l10n.detailAbout,
            icon: const Icon(Icons.info_outline),
            onPressed: () =>
                showDetailSheet(context, (_) => AboutSheet(entryId: entryId)),
          ),
          IconButton(
            tooltip: l10n.detailReset,
            icon: const Icon(Icons.restart_alt),
            onPressed: isModified
                ? ref.read(provider.notifier).resetTapped
                : null,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxBodyWidth),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 横向きでキーボードが出たときなど本体が低いときは、
              // 帯・チップ・編集パネルの分を残してプレビューを縮める
              final previewHeight = min(
                preferredHeight,
                max(
                  0.0,
                  constraints.maxHeight - middleHeight - _minPanelHeight,
                ),
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: spacing.md),
                    child: SizedBox(
                      key: previewAreaKey,
                      height: previewHeight,
                      child: DetailPreview(entryId: entryId),
                    ),
                  ),
                  if (hasProperties) ...[
                    Gap(spacing.xs),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing.md),
                      child: _SelectedCodeStrip(entryId: entryId),
                    ),
                  ],
                  if (hasLogs) ...[
                    Gap(spacing.xs),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing.md),
                      child: LogStrip(
                        entryId: entryId,
                        onTap: () => showDetailSheet(
                          context,
                          (_) => LogSheet(entryId: entryId),
                        ),
                      ),
                    ),
                  ],
                  if (hasProperties) ...[
                    Gap(spacing.xs),
                    PropertyChips(entryId: entryId),
                  ],
                  Gap(spacing.xs),
                  Expanded(
                    key: panelAreaKey,
                    child: _PanelArea(entryId: entryId),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 選んでいるプロパティのコードの帯。押すと全文のシートを開く。
class _SelectedCodeStrip extends ConsumerWidget {
  const _SelectedCodeStrip({required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      detailProvider(entryId).select((s) => s.selected),
    );
    final lines = ref.watch(detailCodeProvider(entryId));
    if (selected == null) return const SizedBox.shrink();
    return CodeStrip(
      propertyName: selected,
      line: lines.where((line) => line.property == selected).firstOrNull,
      onTap: () => showDetailSheet(context, (_) => CodeSheet(entryId: entryId)),
    );
  }
}

/// 編集パネルの地（上の角丸）と中身。中身がはみ出すときはパネルの中でスクロールし、
/// プロパティを切り替えたら先頭から見せる。
class _PanelArea extends ConsumerStatefulWidget {
  const _PanelArea({required this.entryId});

  final String entryId;

  @override
  ConsumerState<_PanelArea> createState() => _PanelAreaState();
}

class _PanelAreaState extends ConsumerState<_PanelArea> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = detailProvider(widget.entryId);
    ref.listen(provider.select((s) => s.selected), (_, _) {
      if (_scroll.hasClients) _scroll.jumpTo(0);
    });
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final spacing = NimiSpacing.of(context);
    final spec = state.selectedSpec;
    final radius = Radius.circular(NimiRadius.of(context).lg);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.vertical(top: radius),
      ),
      child: spec == null
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(spacing.md),
                child: Text(
                  AppLocalizations.of(context).detailNoProperties,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : SingleChildScrollView(
              controller: _scroll,
              padding: EdgeInsets.all(spacing.md),
              child: AnimatedSwitcher(
                // 視差効果を減らす設定なら、中身の切り替えは即時
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 150),
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.topCenter,
                  children: [...previous, ?current],
                ),
                child: EditorPanel(
                  key: ValueKey(spec.name),
                  spec: spec,
                  setting: state.settings[spec.name] ?? spec.initialSetting,
                  isComparing: switch (state.comparing) {
                    ComparingProperty(:final name) => name == spec.name,
                    ComparingUse() => true,
                    null => false,
                  },
                  isDefault: state.isDefault(spec.name),
                  onToggled: (on) => notifier.propertyToggled(spec.name, on),
                  onValueChanged: (value) =>
                      notifier.propertyValueChanged(spec.name, value),
                  onCompareTapped: () => notifier.compareTapped(spec.name),
                  onDefaultTapped: () =>
                      notifier.propertyDefaultTapped(spec.name),
                ),
              ),
            ),
    );
  }
}

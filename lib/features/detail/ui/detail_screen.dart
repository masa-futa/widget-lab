import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widget_lab/features/detail/ui/widgets/code_tab.dart';
import 'package:widget_lab/features/detail/ui/widgets/description_tab.dart';
import 'package:widget_lab/features/detail/ui/widgets/detail_preview.dart';
import 'package:widget_lab/features/detail/ui/widgets/operation_tab.dart';
import 'package:widget_lab/features/detail/view_model/detail_notifier.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// 詳細画面（cb_dtl）。上にプレビューを固定し、下を「操作」「説明」「コード」のタブにする。
class DetailScreen extends ConsumerWidget {
  const DetailScreen({required this.entryId, super.key});

  /// 収録データの `WidgetEntry.id`。
  final String entryId;

  /// タブレットでも 1 カラムのまま、本文をこの幅に収めて中央に置く。
  static const _maxBodyWidth = 640.0;

  /// 本体が低いときも、操作パネルにこれだけの高さを残す。
  static const _minPanelHeight = 96.0;

  /// プレビューの領域（テストで高さを見る）。
  static const previewAreaKey = Key('previewArea');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final name = ref.watch(detailProvider(entryId).select((s) => s.entry.name));
    final isModified = ref.watch(
      detailProvider(entryId).select((s) => s.isModified),
    );
    // キーボードが出たら、入力欄が隠れないようにプレビューを縮める
    final screenHeight = MediaQuery.sizeOf(context).height;
    final keyboardShown = MediaQuery.viewInsetsOf(context).bottom > 0;
    final preferredHeight = screenHeight * (keyboardShown ? 0.25 : 0.4);
    final tabBar = TabBar(
      tabs: [
        Tab(text: l10n.detailTabOperation),
        Tab(text: l10n.detailTabDescription),
        Tab(text: l10n.detailTabCode),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: [
          IconButton(
            tooltip: l10n.detailReset,
            icon: const Icon(Icons.restart_alt),
            onPressed: isModified
                ? ref.read(detailProvider(entryId).notifier).resetTapped
                : null,
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxBodyWidth),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 横向きでキーボードが出たときなど本体が低いときは、
                // タブと操作パネルの分を残してプレビューを縮める
                final previewHeight = min(
                  preferredHeight,
                  max(
                    0.0,
                    constraints.maxHeight -
                        tabBar.preferredSize.height -
                        _minPanelHeight,
                  ),
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      key: previewAreaKey,
                      height: previewHeight,
                      child: DetailPreview(entryId: entryId),
                    ),
                    TabBar(
                      tabs: [
                        Tab(text: l10n.detailTabOperation),
                        Tab(text: l10n.detailTabDescription),
                        Tab(text: l10n.detailTabCode),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          OperationTab(entryId: entryId),
                          DescriptionTab(entryId: entryId),
                          CodeTab(entryId: entryId),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

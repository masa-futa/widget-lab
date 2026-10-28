import 'dart:math';

import 'package:flutter/material.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';

/// 詳細画面のシート（説明・コードの全文）を開く。
///
/// シートの中に ScaffoldMessenger を置き、コピーやリンクの Snackbar を
/// シートの上に出す（画面の Scaffold に出すとシートに隠れるため）。
/// Scaffold は高さを内容に合わせられないので、シートは一定の高さにする:
/// 縦は画面の 9/16、横向きなど低い画面でも 360（画面の 9 割まで）。
Future<void> showDetailSheet(BuildContext context, WidgetBuilder builder) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: _contentHeight(context),
        child: ScaffoldMessenger(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                NimiSpacing.of(context).md,
                0,
                NimiSpacing.of(context).md,
                NimiSpacing.of(context).md,
              ),
              child: Builder(builder: builder),
            ),
          ),
        ),
      ),
    );

/// ドラッグハンドルを除いた、シートの中身の高さ。
double _contentHeight(BuildContext context) {
  final height = MediaQuery.sizeOf(context).height;
  final sheet = max(height * 9 / 16, min(height * 0.9, 360.0));
  return sheet - kMinInteractiveDimension;
}

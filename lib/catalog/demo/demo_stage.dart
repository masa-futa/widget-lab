import 'package:flutter/widgets.dart';

/// 見た目を持つ Widget のうち、プレビューのカードより大きいもの（ダイアログ・ドロワーなど）を、
/// 本来の大きさ [size] で組み立ててから、カードに収まるように縮める
/// （比較中の低いカードや見本でもはみ出さない）。コードには出さない。
class DemoStage extends StatelessWidget {
  const DemoStage({required this.size, required this.child, super.key});

  final Size size;
  final Widget child;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    child: SizedBox.fromSize(size: size, child: child),
  );
}

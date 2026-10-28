import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_recorder.dart';

/// 押したときに誰が受け取るかを見せるデモの部品（AbsorbPointer・IgnorePointer）。
/// 後ろの面（押すとログに「後ろの面: onTap」）の中央に、[front] を重ねる。コードには出さない。
class DemoTapLayers extends StatelessWidget {
  const DemoTapLayers({required this.front, super.key});

  /// 手前に重ねるもの。ふつうは [DemoFrontButton] を包んだもの。
  final Widget front;

  @override
  Widget build(BuildContext context) {
    final recorder = DemoRecorder.of(context);
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 96,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () => recorder.log('後ろの面: onTap'),
            child: ColoredBox(
              color: scheme.secondaryContainer,
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    '後ろの面',
                    style: TextStyle(color: scheme.onSecondaryContainer),
                  ),
                ),
              ),
            ),
          ),
          Center(child: front),
        ],
      ),
    );
  }
}

/// 手前のボタン（デモの部品。コードでは `const FrontButton()`）。押すとログに「手前のボタン: onPressed」。
class DemoFrontButton extends StatelessWidget {
  const DemoFrontButton({super.key});

  @override
  Widget build(BuildContext context) {
    final recorder = DemoRecorder.of(context);
    return FilledButton(
      onPressed: () => recorder.log('手前のボタン: onPressed'),
      child: const Text('押す'),
    );
  }
}

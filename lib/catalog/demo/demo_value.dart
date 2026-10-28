import 'package:flutter/widgets.dart';

/// 押すと値が変わる Widget（Switch・Slider など）のデモで、値を手元に持つ部品。
///
/// 収録データの組み立ての関数は値を持てないので、ここで持ち、[builder] に今の値と
/// 値を変える関数を渡す。最初の値は [initial]（プロパティの値）で、それが変わったら
/// 持っている値も合わせる（操作パネルで値を変えると、プレビューもその値になる）。
class DemoValue<T> extends StatefulWidget {
  const DemoValue({required this.initial, required this.builder, super.key});

  final T initial;
  final Widget Function(
    BuildContext context,
    T value,
    ValueChanged<T> onChanged,
  )
  builder;

  @override
  State<DemoValue<T>> createState() => _DemoValueState<T>();
}

class _DemoValueState<T> extends State<DemoValue<T>> {
  late T _value = widget.initial;

  @override
  void didUpdateWidget(DemoValue<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initial != widget.initial) _value = widget.initial;
  }

  void _changed(T value) => setState(() => _value = value);

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _value, _changed);
}

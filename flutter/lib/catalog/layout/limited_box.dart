import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final limitedBoxEntry = WidgetEntry(
  id: 'limitedBox',
  name: 'LimitedBox',
  genreIds: const ['layout'],
  summary: '上限のない向きにだけ、大きさの上限を付ける',
  description:
      '親から上限のない制約（ListView の中の高さなど）が来たときだけ、'
      'maxWidth・maxHeight を上限にします。上限のある制約ではなにもしません。'
      'ここでは UnconstrainedBox の中に置き、上限をなくしています。'
      '色だけの Container は上限がないと大きさ 0 になります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/LimitedBox-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'maxWidth',
      group: PropertyGroup.size,
      typeLabel: 'double',
      description: '幅に上限がないときの上限。既定は無限（上限なし）',
      control: SliderControl(
        min: 0,
        max: 200,
        divisions: 10,
        initialValue: 160,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'maxHeight',
      group: PropertyGroup.size,
      typeLabel: 'double',
      description: '高さに上限がないときの上限。既定は無限（上限なし）',
      control: SliderControl(
        min: 0,
        max: 48,
        divisions: 6,
        initialValue: 40,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '上限を受ける Widget。色だけの Container は使える広さいっぱいに広がる',
      control: FixedControl(
        value: ColoredBox(color: Color(0xFF1E50A2)),
        source: 'Container(color: Color(0xFF1E50A2))',
      ),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
  ],
  build: _build,
  codeName: 'LimitedBox',
);

Widget _build(DemoArgs args) {
  final child = args.valueOf<Widget>('child');
  return UnconstrainedBox(
    child: LimitedBox(
      maxWidth: args.valueOf<double>('maxWidth') ?? double.infinity,
      maxHeight: args.valueOf<double>('maxHeight') ?? double.infinity,
      // 色だけの Container と同じく、上限があれば広がり、なければ 0 になる箱
      child: child == null ? null : _Fill(child: child),
    ),
  );
}

/// 上限があれば広がり、なければ大きさ 0 になる（色だけの Container と同じ組み方）。
class _Fill extends StatelessWidget {
  const _Fill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => LimitedBox(
    maxWidth: 0,
    maxHeight: 0,
    child: ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: child,
    ),
  );
}

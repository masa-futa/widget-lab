import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_scope.dart';
import 'package:widget_lab/catalog/demo/demo_tap_layers.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final ignorePointerEntry = WidgetEntry(
  id: 'ignorePointer',
  name: 'IgnorePointer',
  genreIds: const ['interaction'],
  summary: '子への押す・ドラッグを無視し、後ろに通す',
  description:
      'ignoring が true のあいだ、自分と子は押されなかったことになり、'
      '押した指は後ろに重なった Widget に届きます（AbsorbPointer との違い）。'
      'ここでは後ろの面の中央に重ねたボタンを包んでいます。ボタンを押して、ログを比べてください。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/IgnorePointer-class.html',
  ),
  kind: EntryKind.behavior,
  properties: const [
    PropertySpec(
      name: 'ignoring',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: '押すのを無視するか。false にすると子はふつうに押せます。既定は true',
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '包む Widget。ここでは後ろの面の中央に重ねたボタン',
      control: FixedControl(
        value: DemoFrontButton(),
        source: 'const FrontButton()',
      ),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'ignoringSemantics',
      typeLabel: 'bool?',
      description: '非推奨。代わりに ExcludeSemantics を使う',
    ),
  ],
  build: _build,
  buildWithout: _buildWithout,
  codeName: 'IgnorePointer',
);

Widget _build(DemoArgs args) {
  final ignoring = args.valueOf<bool>('ignoring') ?? true;
  return DemoScope(
    label: 'IgnorePointer(ignoring: $ignoring)',
    child: DemoTapLayers(
      front: IgnorePointer(
        ignoring: ignoring,
        child: args.valueOf<Widget>('child'),
      ),
    ),
  );
}

/// 包みを外す。ボタンはふつうに押せる。
Widget _buildWithout(DemoArgs args) =>
    const DemoFit(child: DemoTapLayers(front: DemoFrontButton()));

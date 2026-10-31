import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoPageTransitionEntry = WidgetEntry(
  id: 'cupertinoPageTransition',
  name: 'CupertinoPageTransition',
  genreIds: const ['cupertino'],
  summary: '右から滑り込む iOS の画面遷移の動き',
  description:
      'CupertinoPageRoute が使う、画面の遷移の動きです。primaryRouteAnimation が 0 なら右の外、'
      '1 なら元の位置にあり、secondaryRouteAnimation が進むと（上に次の画面が来ると）左へ少しずれます。'
      'ここでは値を止めた AlwaysStoppedAnimation を渡し、途中の姿を見ます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoPageTransition-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'primaryRouteAnimation',
      group: PropertyGroup.behavior,
      typeLabel: 'Animation<double>',
      description: 'この画面が出てくる進み具合。0 で右の外、1 で元の位置',
      required: true,
      control: _animation(0.5),
    ),
    PropertySpec(
      name: 'secondaryRouteAnimation',
      group: PropertyGroup.behavior,
      typeLabel: 'Animation<double>',
      description: '上に次の画面が来る進み具合。進むと左へ少しずれる',
      required: true,
      control: _animation(0),
    ),
    const PropertySpec(
      name: 'linearTransition',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: 'true なら進み具合をそのまま位置にする。false なら iOS の曲線で緩急をつける',
      required: true,
      control: SwitchControl(initialValue: false),
    ),
    const PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget',
      description: '動かす画面',
      required: true,
      control: FixedControl(value: _Page(), source: 'const NextPage()'),
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
  codeName: 'CupertinoPageTransition',
);

SliderControl _animation(double initialValue) => SliderControl(
  min: 0,
  max: 1,
  divisions: 10,
  initialValue: initialValue,
  resolve: AlwaysStoppedAnimation<double>.new,
  code: (v) => 'AlwaysStoppedAnimation($v)',
);

// どれも必須のプロパティなので、常に値がある
Widget _build(DemoArgs args) => SizedBox(
  width: 240,
  height: 140,
  // 枠の外へずれた分は切り、枠の中のどこにあるかを見せる
  child: ClipRect(
    child: CupertinoPageTransition(
      primaryRouteAnimation: args.valueOf<Animation<double>>(
        'primaryRouteAnimation',
      )!,
      secondaryRouteAnimation: args.valueOf<Animation<double>>(
        'secondaryRouteAnimation',
      )!,
      linearTransition: args.valueOf<bool>('linearTransition')!,
      child: args.valueOf<Widget>('child')!,
    ),
  ),
);

/// 動かす画面（デモの部品。コードでは `const NextPage()`）。
class _Page extends StatelessWidget {
  const _Page();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: Color(0xFF1E50A2),
    child: Center(
      child: Text('次の画面', style: TextStyle(color: Color(0xFFFFFFFF))),
    ),
  );
}

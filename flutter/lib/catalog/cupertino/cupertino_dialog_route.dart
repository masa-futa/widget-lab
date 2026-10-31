import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/demo/demo_navigator.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoDialogRouteEntry = WidgetEntry(
  id: 'cupertinoDialogRoute',
  name: 'CupertinoDialogRoute',
  genreIds: const ['cupertino'],
  summary: 'iOS の見た目のダイアログを出す Route',
  description:
      'Navigator.push に渡すと、後ろを暗くしてダイアログを中央に出します。'
      'showCupertinoDialog も中でこの Route を使います。'
      'プレビューの中の Navigator で開きます（ボタンを押す）。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoDialogRoute-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'barrierDismissible',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: 'ダイアログの外を押したら閉じるか',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'barrierColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'ダイアログの後ろを覆う色。指定しないと半透明の黒',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('薄い瑠璃', const Color(0x661E50A2)),
          Choice.color('濃い墨', const Color(0xCC18181B)),
        ],
      ),
    ),
    PropertySpec(
      name: 'transitionDuration',
      group: PropertyGroup.behavior,
      typeLabel: 'Duration',
      description: 'ダイアログが出る・消える動きの長さ。指定しないと 250 ミリ秒',
      initiallyOn: false,
      control: SliderControl(
        min: 100,
        max: 1500,
        divisions: 14,
        initialValue: 1000,
        resolve: (v) => Duration(milliseconds: v.round()),
        code: (v) => 'Duration(milliseconds: ${v.round()})',
      ),
    ),
    const PropertySpec(
      name: 'transitionBuilder',
      group: PropertyGroup.behavior,
      typeLabel: 'RouteTransitionsBuilder?',
      description: 'ダイアログが出る動きを作る関数。ここでは拡大しながら出す。指定しないと薄く現れながら少し縮む',
      initiallyOn: false,
      control: FixedControl(
        value: _scaleTransition,
        source:
            '(context, animation, secondaryAnimation, child) => '
            'ScaleTransition(scale: animation, child: child)',
      ),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'builder',
      typeLabel: 'WidgetBuilder',
      description: 'ダイアログの中身を作る関数',
    ),
    ReferenceArg(
      name: 'context',
      typeLabel: 'BuildContext',
      description: '既定の後ろの色と読み上げの文言を、ここの明るさと言語で決めるのに使う',
    ),
    ReferenceArg(
      name: 'barrierLabel',
      typeLabel: 'String?',
      description: 'ダイアログの後ろを読み上げるときの文言。指定しないと「閉じる」の意味の文言',
    ),
    ReferenceArg(
      name: 'settings',
      typeLabel: 'RouteSettings?',
      description: 'Route の名前と引数。Navigator の記録や遷移の判定に使う',
    ),
    ReferenceArg(
      name: 'requestFocus',
      typeLabel: 'bool?',
      description: '開いたときにダイアログにフォーカスを移すか',
    ),
    ReferenceArg(
      name: 'anchorPoint',
      typeLabel: 'Offset?',
      description: '折りたたみの画面などで、どちらの画面に出すかを決める点',
    ),
  ],
  build: _build,
  codeName: 'CupertinoDialogRoute<void>',
  codeArguments: const [
    'context: context',
    'builder: (context) => const MyDialog()',
  ],
);

Widget _build(DemoArgs args) {
  // 既定値は親の RawDialogRoute の true（showCupertinoDialog は false を渡す）
  final barrierDismissible = args.valueOf<bool>('barrierDismissible') ?? true;
  final barrierColor = args.valueOf<Color>('barrierColor');
  final transitionDuration =
      args.valueOf<Duration>('transitionDuration') ??
      const Duration(milliseconds: 250);
  final transitionBuilder = args.valueOf<RouteTransitionsBuilder>(
    'transitionBuilder',
  );
  return DemoNavigator(
    onOpen: (navigator) => navigator.push(
      CupertinoDialogRoute<void>(
        context: navigator.context,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        transitionDuration: transitionDuration,
        transitionBuilder: transitionBuilder,
        builder: (context) => const _Dialog(),
      ),
    ),
  );
}

Widget _scaleTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) => ScaleTransition(scale: animation, child: child);

/// 開くダイアログ（デモの部品。コードでは `const MyDialog()`）。
class _Dialog extends StatelessWidget {
  const _Dialog();

  @override
  Widget build(BuildContext context) => CupertinoAlertDialog(
    title: const Text('ダイアログ'),
    actions: [
      CupertinoDialogAction(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('閉じる'),
      ),
    ],
  );
}

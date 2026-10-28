import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/demo/demo_navigator.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
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
      typeLabel: 'bool',
      description: 'ダイアログの外を押したら閉じるか',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'barrierColor',
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
  return DemoNavigator(
    onOpen: (navigator) => navigator.push(
      CupertinoDialogRoute<void>(
        context: navigator.context,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        builder: (context) => const _Dialog(),
      ),
    ),
  );
}

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

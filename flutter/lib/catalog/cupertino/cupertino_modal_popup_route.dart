import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/demo/demo_navigator.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoModalPopupRouteEntry = WidgetEntry(
  id: 'cupertinoModalPopupRoute',
  name: 'CupertinoModalPopupRoute',
  genreIds: const ['cupertino'],
  summary: '下からせり上がる iOS のポップアップを出す Route',
  description:
      'Navigator.push に渡すと、後ろを暗くして下から中身をせり上げます。'
      'CupertinoActionSheet を出すときに使います（showCupertinoModalPopup も中でこの Route を使う）。'
      'プレビューの中の Navigator で開きます（ボタンを押す）。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoModalPopupRoute-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'barrierDismissible',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: '外を押したら閉じるか',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'barrierColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color',
      description: '後ろを覆う色。指定しないと kCupertinoModalBarrierColor（明るさで変わる半透明の色）',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('薄い瑠璃', const Color(0x661E50A2)),
          Choice.color('濃い墨', const Color(0xCC18181B)),
        ],
      ),
    ),
    PropertySpec(
      name: 'filter',
      group: PropertyGroup.paint,
      typeLabel: 'ImageFilter?',
      description: '後ろの画面にかける効果。ぼかしを渡すと、ポップアップの後ろがぼやける',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '弱いぼかし',
            ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            'ImageFilter.blur(sigmaX: 2, sigmaY: 2)',
          ),
          Choice(
            '強いぼかし',
            ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            'ImageFilter.blur(sigmaX: 8, sigmaY: 8)',
          ),
        ],
      ),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'builder',
      typeLabel: 'WidgetBuilder',
      description: 'せり上げる中身を作る関数。ふつうは CupertinoActionSheet を返す',
    ),
    ReferenceArg(
      name: 'barrierLabel',
      typeLabel: 'String?',
      description: '読み上げで、後ろを覆う部分に付ける名前',
    ),
    ReferenceArg(
      name: 'semanticsDismissible',
      typeLabel: 'bool',
      description: '読み上げの操作で、後ろを覆う部分から閉じられるか',
    ),
    ReferenceArg(
      name: 'settings',
      typeLabel: 'RouteSettings?',
      description: 'Route の名前と引数。Navigator の記録や復元に使う',
    ),
    ReferenceArg(
      name: 'requestFocus',
      typeLabel: 'bool?',
      description: '開いたときに、この Route にフォーカスを移すか',
    ),
    ReferenceArg(
      name: 'anchorPoint',
      typeLabel: 'Offset?',
      description: '折りたたみ端末などで画面が分かれているとき、どちらの側に出すかを決める点',
    ),
  ],
  build: _build,
  codeName: 'CupertinoModalPopupRoute<void>',
  codeArguments: const ['builder: (context) => const MySheet()'],
);

Widget _build(DemoArgs args) {
  final barrierDismissible = args.valueOf<bool>('barrierDismissible') ?? true;
  final barrierColor =
      args.valueOf<Color>('barrierColor') ?? kCupertinoModalBarrierColor;
  final filter = args.valueOf<ImageFilter>('filter');
  return DemoNavigator(
    onOpen: (navigator) => navigator.push(
      CupertinoModalPopupRoute<void>(
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        filter: filter,
        builder: (context) => const _Sheet(),
      ),
    ),
  );
}

/// 開くシート（デモの部品。コードでは `const MySheet()`）。
class _Sheet extends StatelessWidget {
  const _Sheet();

  @override
  Widget build(BuildContext context) => CupertinoActionSheet(
    title: const Text('シート'),
    actions: [
      CupertinoActionSheetAction(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('保存'),
      ),
    ],
    cancelButton: CupertinoActionSheetAction(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text('キャンセル'),
    ),
  );
}

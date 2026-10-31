import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoContextMenuEntry = WidgetEntry(
  id: 'cupertinoContextMenu',
  name: 'CupertinoContextMenu',
  genreIds: const ['cupertino'],
  summary: '長押しで、子を浮かせてメニューを出す',
  description:
      '子を長押しすると、子が浮き上がって大きくなり、その下にメニューが出ます（iOS のコンテキストメニュー）。'
      'プレビューの子を長押しすると開きます。外を押すと閉じます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoContextMenu-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'actions',
      group: PropertyGroup.content,
      typeLabel: 'List<Widget>',
      description: 'メニューの項目。ふつうは CupertinoContextMenuAction を並べる。空にはできない',
      required: true,
      control: FixedControl(
        value: _actions,
        source:
            "[CupertinoContextMenuAction(onPressed: () {}, child: Text('共有')), "
            'CupertinoContextMenuAction(isDestructiveAction: true, '
            "onPressed: () {}, child: Text('削除'))]",
      ),
    ),
    PropertySpec(
      name: 'enableHapticFeedback',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: 'true なら、開いたときに端末を軽く震わせる',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget',
      description: '長押しする Widget。開くと浮き上がる',
      required: true,
      control: FixedControl(value: _Photo(), source: 'const Photo()'),
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
  codeName: 'CupertinoContextMenu',
);

void _pressed() {}

const _actions = <Widget>[
  CupertinoContextMenuAction(onPressed: _pressed, child: Text('共有')),
  CupertinoContextMenuAction(
    isDestructiveAction: true,
    onPressed: _pressed,
    child: Text('削除'),
  ),
];

// 必須のプロパティなので、常に値がある
Widget _build(DemoArgs args) => CupertinoContextMenu(
  actions: args.valueOf<List<Widget>>('actions')!,
  enableHapticFeedback: args.valueOf<bool>('enableHapticFeedback') ?? false,
  child: args.valueOf<Widget>('child')!,
);

/// 長押しする子（デモの部品。コードでは `const Photo()`）。
class _Photo extends StatelessWidget {
  const _Photo();

  @override
  Widget build(BuildContext context) => Container(
    width: 120,
    height: 120,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: CupertinoColors.systemTeal.resolveFrom(context),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Text('長押し', style: TextStyle(color: CupertinoColors.white)),
  );
}

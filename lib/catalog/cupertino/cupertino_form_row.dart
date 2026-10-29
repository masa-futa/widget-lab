import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoFormRowEntry = WidgetEntry(
  id: 'cupertinoFormRow',
  name: 'CupertinoFormRow',
  genreIds: const ['cupertino'],
  summary: 'iOS の設定画面のような、見出しと入力の 1 行',
  description:
      '左に見出し（prefix）、右に入力の部品（child）を置く、iOS のフォームの 1 行です。'
      '下に補足（helper）とエラー（error）を出せます。ふつうは CupertinoFormSection の中に並べます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoFormRow-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'prefix',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '行の始まりに出す見出し',
      control: FixedControl(value: Text('通知'), source: "Text('通知')"),
    ),
    const PropertySpec(
      name: 'helper',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '行の下に出す補足',
      initiallyOn: false,
      control: FixedControl(
        value: Text('新しいメッセージを知らせます'),
        source: "Text('新しいメッセージを知らせます')",
      ),
    ),
    const PropertySpec(
      name: 'error',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '行の下に出すエラー。文字は赤になる',
      initiallyOn: false,
      control: FixedControl(
        value: Text('通知が許可されていません'),
        source: "Text('通知が許可されていません')",
      ),
    ),
    PropertySpec(
      name: 'padding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry?',
      description: '行の内側の余白。指定しないと左右 20・上下 6 ほど',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 32,
        divisions: 8,
        initialValue: 16,
        resolve: EdgeInsets.all,
        code: (v) => 'EdgeInsets.all($v)',
      ),
    ),
    const PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget',
      description: '行の終わりに置く入力の部品',
      required: true,
      control: FixedControl(
        value: CupertinoSwitch(value: true, onChanged: _changed),
        source: 'CupertinoSwitch(value: true, onChanged: (value) {})',
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
  codeName: 'CupertinoFormRow',
);

void _changed(bool value) {}

Widget _build(DemoArgs args) => FittedBox(
  // 比較中の低いカードでも Column がはみ出さないよう、収まらなければ縮める
  fit: BoxFit.scaleDown,
  child: SizedBox(
    width: 320,
    child: _RowSurface(
      child: CupertinoFormRow(
        prefix: args.valueOf<Widget>('prefix'),
        helper: args.valueOf<Widget>('helper'),
        error: args.valueOf<Widget>('error'),
        padding: args.valueOf<EdgeInsetsGeometry>('padding'),
        // 必須のプロパティなので、常に値がある
        child: args.valueOf<Widget>('child')!,
      ),
    ),
  ),
);

/// 行の地（デモの部品）。CupertinoFormSection の中と同じ地の色を、明るさに合わせて塗る。
class _RowSurface extends StatelessWidget {
  const _RowSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(
      context,
    ),
    child: child,
  );
}

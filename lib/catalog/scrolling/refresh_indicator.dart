import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final refreshIndicatorEntry = WidgetEntry(
  id: 'refreshIndicator',
  name: 'RefreshIndicator',
  genreIds: const ['scrolling'],
  summary: '一番上で下へ引くと、くるくるを出して読み直す（pull to refresh）',
  description:
      '子のスクロールを一番上から下へ引くと、くるくる（進み具合の印）を出して onRefresh を呼びます。'
      'onRefresh の Future が終わるまで、くるくるが回ります。'
      'ここでは 1 秒待つだけの onRefresh にしています。プレビューのリストを下へ引いてみてください。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/RefreshIndicator-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'onRefresh',
      group: PropertyGroup.behavior,
      typeLabel: 'Future<void> Function()',
      description: '引いたときに呼ぶ関数。返した Future が終わるまでくるくるが回る',
      required: true,
      control: FixedControl(
        value: _refresh,
        source: '() => Future.delayed(const Duration(seconds: 1))',
      ),
    ),
    PropertySpec(
      name: 'color',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'くるくるの色。既定はテーマの primary',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅', DemoTile.colors[3]),
          Choice.color('若竹', DemoTile.colors[2]),
        ],
      ),
    ),
    const PropertySpec(
      name: 'displacement',
      group: PropertyGroup.layout,
      typeLabel: 'double',
      description: 'くるくるを止める位置（上端からの距離）。既定は 40',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 80,
        divisions: 4,
        initialValue: 20,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    const PropertySpec(
      name: 'edgeOffset',
      group: PropertyGroup.layout,
      typeLabel: 'double',
      description: 'くるくるが出てくる上端の位置を、下へずらす幅（上に見出しが重なるときに使う）。既定は 0',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 40,
        divisions: 2,
        initialValue: 20,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'backgroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'くるくるの丸い台の色。指定しないとテーマに合わせる',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('山吹', DemoTile.colors[1]),
          Choice.color('瑠璃', DemoTile.colors[0]),
        ],
      ),
    ),
    const PropertySpec(
      name: 'strokeWidth',
      group: PropertyGroup.paint,
      typeLabel: 'double',
      description: 'くるくるの線の太さ。既定は 2.5',
      initiallyOn: false,
      control: SliderControl(
        min: 1,
        max: 6,
        divisions: 5,
        initialValue: 5,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    const PropertySpec(
      name: 'elevation',
      group: PropertyGroup.paint,
      typeLabel: 'double',
      description: 'くるくるの台を浮かせる高さ（影の濃さ）。既定は 2',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 12,
        divisions: 3,
        initialValue: 8,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'triggerMode',
      group: PropertyGroup.behavior,
      typeLabel: 'RefreshIndicatorTriggerMode',
      description: 'どこから引き始めたら出すか。anywhere だと途中から引いても、一番上に着けば出る。既定は onEdge',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final mode in RefreshIndicatorTriggerMode.values)
            Choice(mode.name, mode, 'RefreshIndicatorTriggerMode.${mode.name}'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget',
      description: '引いて読み直すスクロール',
      required: true,
      control: FixedControl(
        value: _List(),
        source: 'ListView(children: tiles)',
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
      name: 'notificationPredicate',
      typeLabel: 'ScrollNotificationPredicate',
      description: 'どのスクロールの通知で引いたとみなすか。既定は、すぐ下の子のスクロールだけ',
    ),
    ReferenceArg(
      name: 'semanticsLabel',
      typeLabel: 'String?',
      description: '読み上げ（スクリーンリーダー）で、くるくるを伝える名前',
    ),
    ReferenceArg(
      name: 'semanticsValue',
      typeLabel: 'String?',
      description: '読み上げ（スクリーンリーダー）で伝える、進み具合',
    ),
  ],
  build: _build,
  codeName: 'RefreshIndicator',
);

Future<void> _refresh() => Future.delayed(const Duration(seconds: 1));

// onRefresh・child は必須のプロパティなので、常に値がある
Widget _build(DemoArgs args) => RefreshIndicator(
  onRefresh: args.valueOf<Future<void> Function()>('onRefresh')!,
  color: args.valueOf<Color>('color'),
  displacement: args.valueOf<double>('displacement') ?? 40,
  edgeOffset: args.valueOf<double>('edgeOffset') ?? 0,
  backgroundColor: args.valueOf<Color>('backgroundColor'),
  strokeWidth:
      args.valueOf<double>('strokeWidth') ??
      RefreshProgressIndicator.defaultStrokeWidth,
  elevation: args.valueOf<double>('elevation') ?? 2,
  triggerMode:
      args.valueOf<RefreshIndicatorTriggerMode>('triggerMode') ??
      RefreshIndicatorTriggerMode.onEdge,
  child: args.valueOf<Widget>('child')!,
);

/// 引いて読み直すリスト（12 行）。
class _List extends StatelessWidget {
  const _List();

  @override
  Widget build(BuildContext context) => ListView(
    children: [for (var i = 1; i <= 12; i++) DemoTile(i, height: 32)],
  );
}

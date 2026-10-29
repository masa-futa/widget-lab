import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// ふつうは ScaffoldMessenger.of(context).showSnackBar で出すものを、
/// SnackBar そのものをカードの中に置いて見せる。
final snackBarEntry = WidgetEntry(
  id: 'snackBar',
  name: 'SnackBar',
  genreIds: const ['material'],
  summary: '画面の下に短い知らせを出し、少しして消える',
  description:
      '操作の結果などの短い知らせを画面の下に出し、数秒で消える帯です。'
      'ScaffoldMessenger.of(context).showSnackBar(SnackBar(…)) で出します。'
      'ここでは SnackBar そのものをカードの中に置いて見ます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/SnackBar-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'content',
      group: PropertyGroup.content,
      typeLabel: 'Widget',
      description: '知らせの中身。ふつうは Text',
      required: true,
      control: FixedControl(value: Text('保存しました'), source: "Text('保存しました')"),
    ),
    const PropertySpec(
      name: 'action',
      group: PropertyGroup.content,
      typeLabel: 'SnackBarAction?',
      description: '右に置く操作（「元に戻す」など）。1 つまで',
      control: FixedControl(
        value: SnackBarAction(label: '元に戻す', onPressed: _noop),
        source: "SnackBarAction(label: '元に戻す', onPressed: () {})",
      ),
    ),
    const PropertySpec(
      name: 'showCloseIcon',
      group: PropertyGroup.content,
      typeLabel: 'bool?',
      description: '右端に閉じるボタン（×）を出すか',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'behavior',
      group: PropertyGroup.layout,
      typeLabel: 'SnackBarBehavior?',
      description: 'fixed は画面の下にくっつけ、floating は浮かせて角を丸める',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final value in SnackBarBehavior.values)
            Choice(value.name, value, 'SnackBarBehavior.${value.name}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'actionOverflowThreshold',
      group: PropertyGroup.layout,
      requires: 'action',
      typeLabel: 'double?',
      description: 'action の幅が帯の幅のこの割合を超えると、action を中身の下の行に回す。大きくすると 1 行に収めやすい。指定しないと 0.25',
      initiallyOn: false,
      // 下の行に回すと、画面の幅の 4 割の空きを中身の横に取る。カードは画面より狭く、
      // 小さい値ではみ出すので、1 行に収める側（0.5 以上）だけを見せる
      control: SliderControl(
        min: 0.5,
        max: 1,
        divisions: 2,
        initialValue: 1,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'width',
      group: PropertyGroup.size,
      requires: 'behavior',
      excludes: const ['margin'],
      omitIf: (settings) =>
          !_isFloating(settings) || (settings['margin']?.on ?? false),
      typeLabel: 'double?',
      description:
          '帯の幅。指定すると真ん中に寄せる。behavior が floating のときだけ使え、margin と同時には使えない',
      initiallyOn: false,
      control: SliderControl(
        min: 160,
        max: 320,
        divisions: 8,
        initialValue: 240,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'margin',
      group: PropertyGroup.spacing,
      requires: 'behavior',
      excludes: const ['width'],
      omitIf: (settings) => !_isFloating(settings),
      typeLabel: 'EdgeInsetsGeometry?',
      description: '帯のまわりの余白。behavior が floating のときだけ使え、width と同時には使えない。指定しないと左右 15・上 5・下 10',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 6,
        initialValue: 24,
        resolve: EdgeInsets.all,
        code: (v) => 'EdgeInsets.all($v)',
      ),
    ),
    PropertySpec(
      name: 'padding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry?',
      description: '帯の内側、中身と action のまわりの余白。指定しないと上下 14・左 24（floating なら 16）',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 6,
        initialValue: 4,
        resolve: EdgeInsets.all,
        code: (v) => 'EdgeInsets.all($v)',
      ),
    ),
    PropertySpec(
      name: 'backgroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '帯の地の色。指定しないとテーマの inverseSurface',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('紅', const Color(0xFFD7003A)),
        ],
      ),
    ),
    PropertySpec(
      name: 'closeIconColor',
      group: PropertyGroup.paint,
      requires: 'showCloseIcon',
      typeLabel: 'Color?',
      description:
          '閉じるボタン（×）の色。showCloseIcon が true のときに使う。指定しないとテーマの onInverseSurface',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('山吹', const Color(0xFFF8B500)),
          Choice.color('紅', const Color(0xFFD7003A)),
        ],
      ),
    ),
    PropertySpec(
      name: 'elevation',
      group: PropertyGroup.paint,
      typeLabel: 'double?',
      description: '帯の浮き上がりの高さ。影の濃さが変わる。指定しないと 6',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 12,
        divisions: 6,
        initialValue: 0,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    const PropertySpec(
      name: 'shape',
      group: PropertyGroup.paint,
      typeLabel: 'ShapeBorder?',
      description: '帯の形。指定しないと、fixed は四角、floating は角の丸み 4 の四角',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('StadiumBorder', StadiumBorder(), 'StadiumBorder()'),
          Choice(
            '角の丸み 16',
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            'RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)))',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'clipBehavior',
      group: PropertyGroup.transform,
      typeLabel: 'Clip',
      description: '帯の形で中身を切り抜くか。指定しないと hardEdge',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final clip in const [
            Clip.none,
            Clip.antiAlias,
            Clip.antiAliasWithSaveLayer,
          ])
            Choice(clip.name, clip, 'Clip.${clip.name}'),
        ],
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
      name: 'duration',
      typeLabel: 'Duration',
      description: 'showSnackBar で出したとき、消えるまでの時間。指定しないと 4 秒',
    ),
    ReferenceArg(
      name: 'persist',
      typeLabel: 'bool?',
      description: 'duration を過ぎても消さずに残すか。指定しないと、action があれば残す',
    ),
    ReferenceArg(
      name: 'animation',
      typeLabel: 'Animation<double>?',
      description: '出入りのアニメーション。ふつうは showSnackBar が渡すので自分では渡さない',
    ),
    ReferenceArg(
      name: 'onVisible',
      typeLabel: 'VoidCallback?',
      description: 'showSnackBar で出して、初めて画面に見えたときに呼ばれる',
    ),
    ReferenceArg(
      name: 'dismissDirection',
      typeLabel: 'DismissDirection?',
      description:
          'どの向きに払うと消せるか。消すのは ScaffoldMessenger なので、'
          'showSnackBar で出したときに使う。指定しないと down',
    ),
    ReferenceArg(
      name: 'hitTestBehavior',
      typeLabel: 'HitTestBehavior?',
      description: 'margin を含む帯の範囲で、触れたことをどう受け取るか。指定しないと、margin があれば中身だけで受け取る',
    ),
  ],
  build: _build,
  codeName: 'SnackBar',
);

void _noop() {}

/// behavior が ON で floating か（margin・width は floating のときだけ渡せる。assert）。
bool _isFloating(Map<String, PropertySetting> settings) {
  final behavior = settings['behavior'];
  if (behavior == null || !behavior.on) return false;
  final value = behavior.value;
  return value is ChoiceValue &&
      SnackBarBehavior.values[value.index] == SnackBarBehavior.floating;
}

Widget _build(DemoArgs args) {
  final behavior = args.valueOf<SnackBarBehavior>('behavior');
  final floating = behavior == SnackBarBehavior.floating;
  final margin = floating ? args.valueOf<EdgeInsetsGeometry>('margin') : null;
  return SnackBar(
    // showSnackBar を通さないと出入りの Animation が渡らないので、出きった状態で止めて渡す
    animation: const AlwaysStoppedAnimation(1),
    content: args.valueOf<Widget>('content') ?? const SizedBox.shrink(),
    action: args.valueOf<SnackBarAction>('action'),
    actionOverflowThreshold: args.valueOf<double>('actionOverflowThreshold'),
    showCloseIcon: args.valueOf<bool>('showCloseIcon'),
    behavior: behavior,
    // margin・width は floating のときだけ、同時には渡さない（assert）
    width: floating && margin == null ? args.valueOf<double>('width') : null,
    margin: margin,
    padding: args.valueOf<EdgeInsetsGeometry>('padding'),
    backgroundColor: args.valueOf<Color>('backgroundColor'),
    closeIconColor: args.valueOf<Color>('closeIconColor'),
    elevation: args.valueOf<double>('elevation'),
    shape: args.valueOf<ShapeBorder>('shape'),
    // Flutter の既定値（Clip.hardEdge）。OFF のときも省いたコードと同じ挙動にそろえる。
    clipBehavior: args.valueOf<Clip>('clipBehavior') ?? Clip.hardEdge,
  );
}

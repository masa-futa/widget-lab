import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
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
      typeLabel: 'Widget',
      description: '知らせの中身。ふつうは Text',
      required: true,
      control: FixedControl(value: Text('保存しました'), source: "Text('保存しました')"),
    ),
    const PropertySpec(
      name: 'action',
      typeLabel: 'SnackBarAction?',
      description: '右に置く操作（「元に戻す」など）。1 つまで',
      control: FixedControl(
        value: SnackBarAction(label: '元に戻す', onPressed: _noop),
        source: "SnackBarAction(label: '元に戻す', onPressed: () {})",
      ),
    ),
    const PropertySpec(
      name: 'showCloseIcon',
      typeLabel: 'bool?',
      description: '右端に閉じるボタン（×）を出すか',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'behavior',
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
      name: 'backgroundColor',
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
  ],
  build: _build,
  codeName: 'SnackBar',
);

void _noop() {}

Widget _build(DemoArgs args) => SnackBar(
  // showSnackBar を通さないと出入りの Animation が渡らないので、出きった状態で止めて渡す
  animation: const AlwaysStoppedAnimation(1),
  content: args.valueOf<Widget>('content') ?? const SizedBox.shrink(),
  action: args.valueOf<SnackBarAction>('action'),
  showCloseIcon: args.valueOf<bool>('showCloseIcon'),
  behavior: args.valueOf<SnackBarBehavior>('behavior'),
  backgroundColor: args.valueOf<Color>('backgroundColor'),
);

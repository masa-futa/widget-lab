import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// 公式カタログの「Bottom sheet」のカード。クラス名ではないので、
/// showModalBottomSheet が出す中身の BottomSheet をカードの中に置いて見せる。
final bottomSheetEntry = WidgetEntry(
  id: 'bottomSheet',
  name: 'Bottom sheet',
  genreIds: const ['material'],
  summary: '画面の下からせり上がる、補助の面',
  description:
      '画面の下からせり上がり、補助の内容や操作を出す面です。'
      'ふつうは showModalBottomSheet(context: context, builder: …) で出し、'
      '中で BottomSheet が使われます。ここでは BottomSheet そのものをカードの中に置いて見ます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/BottomSheet-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'onClosing',
      typeLabel: 'VoidCallback',
      description: '下へ引いて閉じようとしたときに呼ばれる。閉じる処理はここで書く',
      required: true,
      control: FixedControl(value: _noop, source: '() {}'),
    ),
    const PropertySpec(
      name: 'builder',
      typeLabel: 'WidgetBuilder',
      description: '面の中身を作る関数',
      required: true,
      control: FixedControl(
        value: _content,
        source:
            '(context) => const ListTile(leading: Icon(Icons.share), '
            "title: Text('共有'))",
      ),
    ),
    const PropertySpec(
      name: 'showDragHandle',
      typeLabel: 'bool?',
      description: '上の真ん中に、引ける印（ドラッグハンドル）を出すか',
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'enableDrag',
      typeLabel: 'bool',
      description: '下へ引いて閉じられるか。指定しないと true',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'backgroundColor',
      typeLabel: 'Color?',
      description: '面の地の色。指定しないとテーマの surfaceContainerLow',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('生成', const Color(0xFFFBFAF5)),
          Choice.color('桜', const Color(0xFFFEF4F4)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
        ],
      ),
    ),
    PropertySpec(
      name: 'elevation',
      typeLabel: 'double?',
      description: '面の浮き上がりの高さ。影の濃さが変わる',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 12,
        divisions: 6,
        initialValue: 6,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
  ],
  build: _build,
  codeName: 'BottomSheet',
);

void _noop() {}

Widget _content(BuildContext context) =>
    const ListTile(leading: Icon(Icons.share), title: Text('共有'));

/// 面は幅いっぱいに広がるので、プレビューでは見やすい幅に決める（コードには出さない）。
Widget _build(DemoArgs args) => SizedBox(
  width: 280,
  child: BottomSheet(
    onClosing: args.valueOf<VoidCallback>('onClosing') ?? _noop,
    builder: args.valueOf<WidgetBuilder>('builder') ?? _content,
    showDragHandle: args.valueOf<bool>('showDragHandle'),
    enableDrag: args.valueOf<bool>('enableDrag') ?? true,
    backgroundColor: args.valueOf<Color>('backgroundColor'),
    elevation: args.valueOf<double>('elevation'),
  ),
);

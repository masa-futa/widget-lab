import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
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
      group: PropertyGroup.behavior,
      typeLabel: 'VoidCallback',
      description: '下へ引いて閉じようとしたときに呼ばれる。閉じる処理はここで書く',
      required: true,
      control: FixedControl(value: _noop, source: '() {}'),
    ),
    const PropertySpec(
      name: 'builder',
      group: PropertyGroup.content,
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
      group: PropertyGroup.content,
      typeLabel: 'bool?',
      description: '上の真ん中に、引ける印（ドラッグハンドル）を出すか',
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'enableDrag',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: '下へ引いて閉じられるか。指定しないと true',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    const PropertySpec(
      name: 'constraints',
      group: PropertyGroup.size,
      typeLabel: 'BoxConstraints?',
      description: '面の大きさの上限と下限。指定すると面は下の真ん中に寄る。指定しないと幅 640 まで',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            'maxWidth 200',
            BoxConstraints(maxWidth: 200),
            'BoxConstraints(maxWidth: 200)',
          ),
          Choice(
            'minHeight 120',
            BoxConstraints(minHeight: 120),
            'BoxConstraints(minHeight: 120)',
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'dragHandleSize',
      group: PropertyGroup.size,
      requires: 'showDragHandle',
      typeLabel: 'Size?',
      description: '引ける印の大きさ。指定しないと 32×4',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('64×6', Size(64, 6), 'Size(64, 6)'),
          Choice('16×4', Size(16, 4), 'Size(16, 4)'),
        ],
      ),
    ),
    PropertySpec(
      name: 'backgroundColor',
      group: PropertyGroup.paint,
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
      name: 'dragHandleColor',
      group: PropertyGroup.paint,
      requires: 'showDragHandle',
      typeLabel: 'Color?',
      description: '引ける印の色。指定しないとテーマの onSurfaceVariant',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅', const Color(0xFFD7003A)),
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
        ],
      ),
    ),
    PropertySpec(
      name: 'elevation',
      group: PropertyGroup.paint,
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
    PropertySpec(
      name: 'shadowColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '面の下の影の色。指定しないと Material 3 では透明（影が出ない）',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('墨', const Color(0xFF18181B)),
          Choice.color('紅', const Color(0xFFD7003A)),
        ],
      ),
    ),
    const PropertySpec(
      name: 'shape',
      group: PropertyGroup.paint,
      typeLabel: 'ShapeBorder?',
      description: '面の形。指定しないと上の角だけ丸み 28 の角丸',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('四角', RoundedRectangleBorder(), 'RoundedRectangleBorder()'),
          Choice(
            '上の小さい角丸',
            RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            'RoundedRectangleBorder(borderRadius: '
                'BorderRadius.vertical(top: Radius.circular(8)))',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'clipBehavior',
      group: PropertyGroup.transform,
      typeLabel: 'Clip?',
      description: '面の中身を shape の形で切り抜くか。指定しないと切り抜かない',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final clip in Clip.values)
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
      name: 'animationController',
      typeLabel: 'AnimationController?',
      description: '面がせり上がる・下がるアニメーションを動かすもの。ふつうは showModalBottomSheet が用意する',
    ),
    ReferenceArg(
      name: 'onDragStart',
      typeLabel: 'BottomSheetDragStartHandler?',
      description: '面を縦に引き始めたときに呼ばれる。enableDrag が true のときだけ',
    ),
    ReferenceArg(
      name: 'onDragEnd',
      typeLabel: 'BottomSheetDragEndHandler?',
      description: '面を引き終えたときに呼ばれる。enableDrag が true のときだけ',
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
    dragHandleColor: args.valueOf<Color>('dragHandleColor'),
    dragHandleSize: args.valueOf<Size>('dragHandleSize'),
    enableDrag: args.valueOf<bool>('enableDrag') ?? true,
    backgroundColor: args.valueOf<Color>('backgroundColor'),
    shadowColor: args.valueOf<Color>('shadowColor'),
    elevation: args.valueOf<double>('elevation'),
    shape: args.valueOf<ShapeBorder>('shape'),
    clipBehavior: args.valueOf<Clip>('clipBehavior'),
    constraints: args.valueOf<BoxConstraints>('constraints'),
  ),
);

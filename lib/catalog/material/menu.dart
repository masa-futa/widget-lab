import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/dart_code.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// 公式カタログの「Menu」のカード。クラス名ではないので、ボタンなどに付けて
/// メニューを開く MenuAnchor で見せる。
final menuEntry = WidgetEntry(
  id: 'menu',
  name: 'Menu',
  genreIds: const ['material'],
  summary: 'ボタンを押すと、選べる項目の一覧が一時的に開く',
  description:
      'ボタンなどを押すと、選べる項目の一覧を一時的な面に開きます。ここでは、好きな Widget に'
      'メニューを付ける MenuAnchor で見ます（右上のボタンを押すと開きます）。'
      '開き閉じは builder に渡される MenuController で行い、項目には MenuItemButton を並べます。'
      '画面の上に帯で並べるなら MenuBar、入力欄から選ぶなら DropdownMenu を使います。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/MenuAnchor-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'menuChildren',
      group: PropertyGroup.content,
      typeLabel: 'List<Widget>',
      description: '開いたときに並べる項目。ふつうは MenuItemButton',
      required: true,
      control: FixedControl(
        value: <Widget>[
          MenuItemButton(
            onPressed: _noop,
            leadingIcon: Icon(Icons.edit),
            child: Text('編集'),
          ),
          MenuItemButton(
            onPressed: _noop,
            leadingIcon: Icon(Icons.share),
            child: Text('共有'),
          ),
          MenuItemButton(
            onPressed: _noop,
            leadingIcon: Icon(Icons.delete),
            child: Text('削除'),
          ),
        ],
        source:
            "[MenuItemButton(onPressed: () {}, leadingIcon: Icon(Icons.edit), child: Text('編集')), "
            "MenuItemButton(onPressed: () {}, leadingIcon: Icon(Icons.share), child: Text('共有')), "
            "MenuItemButton(onPressed: () {}, leadingIcon: Icon(Icons.delete), child: Text('削除'))]",
      ),
    ),
    const PropertySpec(
      name: 'builder',
      group: PropertyGroup.content,
      typeLabel: 'MenuAnchorChildBuilder?',
      description: 'メニューを付ける Widget を作る。渡された controller の open・close で開き閉じする',
      required: true,
      control: FixedControl(
        value: _anchor,
        source:
            '(context, controller, child) => IconButton(onPressed: () => '
            'controller.isOpen ? controller.close() : controller.open(), '
            'icon: Icon(Icons.more_vert))',
      ),
    ),
    PropertySpec(
      name: 'style',
      group: PropertyGroup.paint,
      typeLabel: 'MenuStyle?',
      description: '開いた面の見た目。ここでは地の色だけを変える',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final (name, color) in const [
            ('山吹', Color(0xFFF8B500)),
            ('若竹', Color(0xFF68BE8D)),
            ('白', Color(0xFFFFFFFF)),
          ])
            Choice(
              name,
              MenuStyle(backgroundColor: WidgetStatePropertyAll(color)),
              'MenuStyle(backgroundColor: '
              'WidgetStatePropertyAll(${colorCode(color)}))',
            ),
        ],
      ),
    ),
    PropertySpec(
      name: 'alignmentOffset',
      group: PropertyGroup.layout,
      typeLabel: 'Offset?',
      description: '開く面の位置をずらす量。ここでは横にずらす',
      initiallyOn: false,
      control: SliderControl(
        min: -48,
        max: 48,
        divisions: 4,
        initialValue: -24,
        resolve: (v) => Offset(v, 0),
        code: (v) => 'Offset($v, 0)',
      ),
    ),
    PropertySpec(
      name: 'clipBehavior',
      group: PropertyGroup.transform,
      typeLabel: 'Clip',
      description: '開いた面の形で中身を切り抜くか。指定しないと hardEdge',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final clip in Clip.values)
            Choice(clip.name, clip, 'Clip.${clip.name}'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'consumeOutsideTap',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: '開いた面の外を押して閉じるとき、その押した操作を下の Widget に届けないか。指定しないと届ける',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'crossAxisUnconstrained',
      group: PropertyGroup.size,
      typeLabel: 'bool',
      description: '開いた面を、横幅の制約に縛られない本来の大きさで描くか。指定しないと true',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    const PropertySpec(
      name: 'animated',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: '開き閉じに動きを付けるか。指定しないとすぐ開き、すぐ閉じる',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'controller',
      typeLabel: 'MenuController?',
      description: 'ほかの Widget からメニューを開き閉じするための操作役。指定しないと中で作り、builder に渡す',
    ),
    ReferenceArg(
      name: 'childFocusNode',
      typeLabel: 'FocusNode?',
      description: 'メニューを開く Widget のフォーカス。キーボードの矢印でメニューから戻るときに使う',
    ),
    ReferenceArg(
      name: 'reservedPadding',
      typeLabel: 'EdgeInsetsGeometry?',
      description: '画面の安全な領域の端と、開いた面との間に空ける余白。指定しないと 8。画面の端に近いときだけ効く',
    ),
    ReferenceArg(
      name: 'layerLink',
      typeLabel: 'LayerLink?',
      description: 'キーボードが出るなどで付け先が動いたとき、開いた面を付いて行かせるためのつなぎ',
    ),
    ReferenceArg(
      name: 'anchorTapClosesMenu',
      typeLabel: 'bool',
      description: '非推奨。consumeOutsideTap を使う。付け先を押したときにメニューを閉じるか',
    ),
    ReferenceArg(
      name: 'onOpen',
      typeLabel: 'VoidCallback?',
      description: 'メニューが開き始めたときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onClose',
      typeLabel: 'VoidCallback?',
      description: 'メニューが閉じ終わったときに呼ばれる',
    ),
    ReferenceArg(
      name: 'useRootOverlay',
      typeLabel: 'bool',
      description: '開いた面を、いちばん外側の Overlay に描くか。指定しないと近くの Overlay に描く',
    ),
    ReferenceArg(
      name: 'onAnimationStatusChanged',
      typeLabel: 'ValueChanged<AnimationStatus>?',
      description: '開き閉じの動きの段階（開いている途中・閉じている途中など）が変わったときに呼ばれる',
    ),
    ReferenceArg(
      name: 'child',
      typeLabel: 'Widget?',
      description: 'builder に渡す Widget。開き閉じで変わらない部分をここに置くと作り直さずに済む',
    ),
  ],
  build: _build,
  codeName: 'MenuAnchor',
);

void _noop() {}

Widget _anchor(
  BuildContext context,
  MenuController controller,
  Widget? child,
) => IconButton(
  onPressed: () => controller.isOpen ? controller.close() : controller.open(),
  icon: const Icon(Icons.more_vert),
);

Widget _build(DemoArgs args) => MenuAnchor(
  menuChildren: args.valueOf<List<Widget>>('menuChildren') ?? const [],
  builder: args.valueOf<MenuAnchorChildBuilder>('builder'),
  style: args.valueOf<MenuStyle>('style'),
  alignmentOffset: args.valueOf<Offset>('alignmentOffset') ?? Offset.zero,
  clipBehavior: args.valueOf<Clip>('clipBehavior') ?? Clip.hardEdge,
  consumeOutsideTap: args.valueOf<bool>('consumeOutsideTap') ?? false,
  crossAxisUnconstrained: args.valueOf<bool>('crossAxisUnconstrained') ?? true,
  animated: args.valueOf<bool>('animated') ?? false,
);

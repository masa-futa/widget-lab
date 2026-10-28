import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/dart_code.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
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
);

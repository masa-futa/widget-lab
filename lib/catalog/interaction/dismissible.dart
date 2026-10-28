import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/demo/demo_value.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final dismissibleEntry = WidgetEntry(
  id: 'dismissible',
  name: 'Dismissible',
  genreIds: const ['interaction'],
  summary: '横にスワイプして、項目を消す',
  description:
      '子を横（direction の向き）にスワイプすると、滑らせて消し、onDismissed を呼びます。'
      'onDismissed で自分のリストからその項目を除いて組み直します（除かないとエラー）。'
      'スワイプ中に後ろに見えるのが background です。プレビューの項目をスワイプしてみてください。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/Dismissible-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'direction',
      typeLabel: 'DismissDirection',
      description: 'スワイプできる向き。既定は horizontal（左右どちらも）',
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice(
            'horizontal',
            DismissDirection.horizontal,
            'DismissDirection.horizontal',
          ),
          Choice(
            'endToStart',
            DismissDirection.endToStart,
            'DismissDirection.endToStart',
          ),
          Choice(
            'startToEnd',
            DismissDirection.startToEnd,
            'DismissDirection.startToEnd',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'background',
      typeLabel: 'Widget?',
      description: 'スワイプ中に後ろに見えるもの',
      control: FixedControl(
        value: _Background(),
        source:
            'Container(color: Colors.red, alignment: Alignment.centerRight, '
            'child: Icon(Icons.delete))',
      ),
    ),
    PropertySpec(
      name: 'onDismissed',
      typeLabel: 'DismissDirectionCallback?',
      description: '消し終わったときに呼ばれる。ここで自分のリストから除く',
      required: true,
      control: FixedControl(
        value: _onDismissed,
        source: '(direction) => setState(() => items.remove(item))',
      ),
    ),
  ],
  build: _build,
  codeName: 'Dismissible',
  codeArguments: const ['key: ValueKey(item)', 'child: Tile(item)'],
);

/// 消す関数の印（除くのはデモの部品が持つリストで行う）。
void _onDismissed(DismissDirection direction) {}

const _items = [1, 2, 3];

Widget _build(DemoArgs args) {
  final direction =
      args.valueOf<DismissDirection>('direction') ??
      DismissDirection.horizontal;
  final background = args.valueOf<Widget>('background');
  return DemoValue<List<int>>(
    initial: _items,
    builder: (context, items, onChanged) => items.isEmpty
        ? TextButton(
            onPressed: () => onChanged(_items),
            child: const Text('元に戻す'),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final n in items)
                Dismissible(
                  key: ValueKey(n),
                  direction: direction,
                  background: background,
                  onDismissed: (_) => onChanged([...items]..remove(n)),
                  child: DemoTile(n, height: 20),
                ),
            ],
          ),
  );
}

/// スワイプ中に後ろに見える、紅の地にごみ箱のアイコン。
class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: DemoTile.colors[3],
    child: const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.delete, color: Colors.white, size: 16),
          Icon(Icons.delete, color: Colors.white, size: 16),
        ],
      ),
    ),
  );
}

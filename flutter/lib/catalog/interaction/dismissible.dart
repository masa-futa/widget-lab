import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/demo/demo_value.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
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
  properties: [
    const PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget',
      description: 'スワイプして消す項目',
      required: true,
      control: FixedControl(value: true, source: 'Tile(item)'),
    ),
    const PropertySpec(
      name: 'direction',
      group: PropertyGroup.behavior,
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
    const PropertySpec(
      name: 'background',
      group: PropertyGroup.paint,
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
      name: 'secondaryBackground',
      group: PropertyGroup.paint,
      requires: 'background',
      omitIf: (settings) => !(settings['background']?.on ?? false),
      typeLabel: 'Widget?',
      description: '右から左（endToStart）へスワイプしている間に後ろに見えるもの。background と一緒に使う',
      initiallyOn: false,
      control: const FixedControl(
        value: _SecondaryBackground(),
        source:
            'Container(color: Colors.blue, alignment: Alignment.centerRight, '
            'child: Icon(Icons.archive))',
      ),
    ),
    const PropertySpec(
      name: 'confirmDismiss',
      group: PropertyGroup.behavior,
      typeLabel: 'ConfirmDismissCallback?',
      description: '消す前に、本当に消すかを決める。false を返すと項目は元の位置に戻る',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('消さずに戻す', _neverDismiss, '(direction) async => false'),
          Choice(
            'endToStart だけ消す',
            _endToStartOnly,
            '(direction) async => direction == DismissDirection.endToStart',
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'resizeDuration',
      group: PropertyGroup.behavior,
      typeLabel: 'Duration?',
      description: '消えたあと、残りの項目が詰まるまでの時間。既定は 300 ミリ秒',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('1 秒', Duration(seconds: 1), 'Duration(seconds: 1)'),
          Choice(
            '50 ミリ秒',
            Duration(milliseconds: 50),
            'Duration(milliseconds: 50)',
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'dismissThresholds',
      group: PropertyGroup.behavior,
      typeLabel: 'Map<DismissDirection, double>',
      description: 'どこまでスワイプしたら消すか（幅に対する割合）。既定は 0.4',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '0.8（深く送る）',
            {
              DismissDirection.endToStart: 0.8,
              DismissDirection.startToEnd: 0.8,
            },
            '{DismissDirection.endToStart: 0.8, DismissDirection.startToEnd: 0.8}',
          ),
          Choice(
            '0.1（少しで消える）',
            {
              DismissDirection.endToStart: 0.1,
              DismissDirection.startToEnd: 0.1,
            },
            '{DismissDirection.endToStart: 0.1, DismissDirection.startToEnd: 0.1}',
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'movementDuration',
      group: PropertyGroup.behavior,
      typeLabel: 'Duration',
      description: '指を離したあと、項目が滑って消える（または戻る）までの時間。既定は 200 ミリ秒',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [Choice('1 秒', Duration(seconds: 1), 'Duration(seconds: 1)')],
      ),
    ),
    const PropertySpec(
      name: 'crossAxisEndOffset',
      group: PropertyGroup.behavior,
      typeLabel: 'double',
      description: '消えるときに、縦にもずらす量（項目の高さに対する割合）。斜めに滑って消える。既定は 0',
      initiallyOn: false,
      control: SliderControl(
        min: -1,
        max: 1,
        divisions: 4,
        initialValue: 0.5,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    const PropertySpec(
      name: 'onDismissed',
      group: PropertyGroup.behavior,
      typeLabel: 'DismissDirectionCallback?',
      description: '消し終わったときに呼ばれる。ここで自分のリストから除く',
      required: true,
      control: FixedControl(
        value: _onDismissed,
        source: '(direction) => setState(() => items.remove(item))',
      ),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'onResize',
      typeLabel: 'VoidCallback?',
      description: '消えたあと、残りの項目が詰まっていく間に呼ばれる',
    ),
    ReferenceArg(
      name: 'onUpdate',
      typeLabel: 'DismissUpdateCallback?',
      description: 'スワイプして項目が動くたびに呼ばれる',
    ),
    ReferenceArg(
      name: 'dragStartBehavior',
      typeLabel: 'DragStartBehavior',
      description: 'スワイプの始まりを、指が触れた所にするか、動き出した所にするか',
    ),
    ReferenceArg(
      name: 'behavior',
      typeLabel: 'HitTestBehavior',
      description: 'スワイプを受ける当たり判定のしかた。見本の項目は全面を塗っているので違いは出ない',
    ),
  ],
  build: _build,
  codeName: 'Dismissible',
  codeArguments: const ['key: ValueKey(item)'],
);

Future<bool?> _neverDismiss(DismissDirection direction) async => false;

Future<bool?> _endToStartOnly(DismissDirection direction) async =>
    direction == DismissDirection.endToStart;

/// 消す関数の印（除くのはデモの部品が持つリストで行う）。
void _onDismissed(DismissDirection direction) {}

const _items = [1, 2, 3];

Widget _build(DemoArgs args) {
  final direction =
      args.valueOf<DismissDirection>('direction') ??
      DismissDirection.horizontal;
  final background = args.valueOf<Widget>('background');
  // background がないと secondaryBackground は渡せない（assert）
  final secondaryBackground = background == null
      ? null
      : args.valueOf<Widget>('secondaryBackground');
  final confirmDismiss = args.valueOf<ConfirmDismissCallback>('confirmDismiss');
  final resizeDuration =
      args.valueOf<Duration>('resizeDuration') ??
      const Duration(milliseconds: 300);
  final dismissThresholds =
      args.valueOf<Map<DismissDirection, double>>('dismissThresholds') ??
      const <DismissDirection, double>{};
  final movementDuration =
      args.valueOf<Duration>('movementDuration') ??
      const Duration(milliseconds: 200);
  final crossAxisEndOffset = args.valueOf<double>('crossAxisEndOffset') ?? 0;
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
                  secondaryBackground: secondaryBackground,
                  confirmDismiss: confirmDismiss,
                  resizeDuration: resizeDuration,
                  dismissThresholds: dismissThresholds,
                  movementDuration: movementDuration,
                  crossAxisEndOffset: crossAxisEndOffset,
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

/// endToStart のスワイプ中に後ろに見える、瑠璃の地にしまうアイコン。
class _SecondaryBackground extends StatelessWidget {
  const _SecondaryBackground();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: DemoTile.colors[0],
    child: const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Icon(Icons.archive, color: Colors.white, size: 16),
      ),
    ),
  );
}

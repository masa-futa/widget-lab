import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_recorder.dart';
import 'package:widget_lab/catalog/demo/demo_scope.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/demo/rebuild_counter.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final layoutBuilderEntry = WidgetEntry(
  id: 'layoutBuilder',
  name: 'LayoutBuilder',
  genreIds: const ['layout'],
  summary: '親から渡された大きさの制約を見て、子を組み分ける',
  description:
      '組むときに親から来た制約（使える幅・高さ）を builder に渡します。'
      '画面の幅（MediaQuery）ではなく、置かれた場所の広さで組み分けられます。'
      '制約が変わるたびに builder が呼び直されます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/LayoutBuilder-class.html',
  ),
  kind: EntryKind.behavior,
  properties: const [
    PropertySpec(
      name: 'builder',
      typeLabel: 'Widget Function(BuildContext, BoxConstraints)',
      description:
          '制約を受けて子を返す関数。ここでは使える幅がしきい値より狭ければ縦に、'
          '広ければ横に並べます。比べると、カードが狭くなった側だけ縦になります。',
      required: true,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice('幅 160 未満で縦', 160.0, _builderCode160),
          Choice('幅 240 未満で縦', 240.0, _builderCode240),
          Choice('幅 320 未満で縦', 320.0, _builderCode320),
        ],
      ),
    ),
  ],
  build: _build,
  buildWithout: _buildWithout,
  codeName: 'LayoutBuilder',
  codeWithout: _codeWithout,
);

const _builderCode160 =
    '(context, constraints) =>\n'
    '      constraints.maxWidth < 160 ? const Narrow() : const Wide()';
const _builderCode240 =
    '(context, constraints) =>\n'
    '      constraints.maxWidth < 240 ? const Narrow() : const Wide()';
const _builderCode320 =
    '(context, constraints) =>\n'
    '      constraints.maxWidth < 320 ? const Narrow() : const Wide()';

/// 使わない場合のよくある書き方。画面の幅で組み分ける（置かれた場所の広さは分からない）。
const _codeWithout = '''
Builder(
  builder: (context) => MediaQuery.sizeOf(context).width < 240
      ? const Narrow()
      : const Wide(),
)''';

Widget _build(DemoArgs args) {
  // 必須のプロパティなので、常に値がある
  final threshold = args.valueOf<double>('builder')!;
  return DemoScope(
    label: 'LayoutBuilder(maxWidth < ${threshold.round()} で縦)',
    child: LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        DemoRecorder.of(context).log('builder: maxWidth ${width.round()}');
        return _Tiles(wide: width >= threshold);
      },
    ),
  );
}

/// 使わない側。画面の幅で組み分けるので、カードが狭くなっても横のまま。
Widget _buildWithout(DemoArgs args) {
  final threshold = args.valueOf<double>('builder')!;
  return DemoFit(
    child: Builder(
      builder: (context) {
        final width = MediaQuery.sizeOf(context).width;
        DemoRecorder.of(context).log('画面の幅 ${width.round()}');
        return _Tiles(wide: width >= threshold);
      },
    ),
  );
}

/// 広ければ横、狭ければ縦に 2 つの子を並べる。
class _Tiles extends StatelessWidget {
  const _Tiles({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) => RebuildCounter(
    label: wide ? '横に並べる子' : '縦に並べる子',
    builder: (context) => Align(
      alignment: AlignmentDirectional.centerStart,
      child: Flex(
        direction: wide ? Axis.horizontal : Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: const [
          DemoTile(1, width: 32, height: 24),
          DemoTile(2, width: 32, height: 24),
        ],
      ),
    ),
  );
}

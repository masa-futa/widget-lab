import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final sliverPersistentHeaderEntry = WidgetEntry(
  id: 'sliverPersistentHeader',
  name: 'SliverPersistentHeader',
  genreIds: const ['layout', 'scrolling'],
  summary: 'スクロールで縮み、上に残せる見出しの sliver',
  description:
      'delegate の maxExtent から minExtent まで、スクロールに合わせて縮む見出し。'
      'build には縮んだ量（shrinkOffset）が渡ります。SliverAppBar の中身です。'
      'ここでは下に 12 行の SliverList をつないでいます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/SliverPersistentHeader-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'delegate',
      typeLabel: 'SliverPersistentHeaderDelegate',
      description: '見出しの高さの範囲と中身',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice(
            '64 から 24 に縮む',
            _Header(minExtent: 24, maxExtent: 64),
            'const Header(minExtent: 24, maxExtent: 64)',
          ),
          Choice(
            '32 のまま',
            _Header(minExtent: 32, maxExtent: 32),
            'const Header(minExtent: 32, maxExtent: 32)',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'pinned',
      typeLabel: 'bool',
      description: 'スクロールしても、minExtent の高さで上に残すか。既定は false',
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'floating',
      typeLabel: 'bool',
      description: '上へ戻し始めたらすぐ現れるか。既定は false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
  ],
  build: _build,
  codeName: 'SliverPersistentHeader',
);

Widget _build(DemoArgs args) => CustomScrollView(
  slivers: [
    SliverPersistentHeader(
      // 必須のプロパティなので、常に値がある
      delegate: args.valueOf<SliverPersistentHeaderDelegate>('delegate')!,
      pinned: args.valueOf<bool>('pinned') ?? false,
      floating: args.valueOf<bool>('floating') ?? false,
    ),
    SliverList.list(
      children: [for (var i = 2; i <= 13; i++) DemoTile(i, height: 24)],
    ),
  ],
);

/// 瑠璃の地に、縮んだ量を出す見出し。
class _Header extends SliverPersistentHeaderDelegate {
  const _Header({required this.minExtent, required this.maxExtent});

  @override
  final double minExtent;

  @override
  final double maxExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => ColoredBox(
    color: DemoTile.colors.first,
    child: Center(
      child: Text(
        'shrinkOffset ${shrinkOffset.round()}',
        style: const TextStyle(color: Color(0xFFFFFFFF)),
      ),
    ),
  );

  @override
  bool shouldRebuild(_Header oldDelegate) =>
      oldDelegate.minExtent != minExtent || oldDelegate.maxExtent != maxExtent;
}

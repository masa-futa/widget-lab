import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoPageScaffoldEntry = WidgetEntry(
  id: 'cupertinoPageScaffold',
  name: 'CupertinoPageScaffold',
  genreIds: const ['cupertino'],
  summary: '上にナビゲーションバーを置く、iOS の 1 画面の骨組み',
  description:
      '上のナビゲーションバーと、その下の中身を組む 1 画面の骨組みです。'
      '地はテーマの scaffoldBackgroundColor で塗ります。'
      'バーが半透明なら中身はバーの下まで広がり、MediaQuery の padding でバーの高さを知らせます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoPageScaffold-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'navigationBar',
      group: PropertyGroup.content,
      typeLabel: 'ObstructingPreferredSizeWidget?',
      description: '上に置くバー。ふつうは CupertinoNavigationBar',
      control: FixedControl(
        value: _bar,
        source: "CupertinoNavigationBar(middle: Text('ホーム'))",
      ),
    ),
    PropertySpec(
      name: 'backgroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '画面の地の色。指定しないとテーマの scaffoldBackgroundColor',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          const Choice(
            'systemGroupedBackground',
            CupertinoColors.systemGroupedBackground,
            'CupertinoColors.systemGroupedBackground',
          ),
          Choice.color('山吹', const Color(0xFFF8B500)),
        ],
      ),
    ),
    const PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget',
      description: '画面の中身',
      required: true,
      control: FixedControl(
        value: Center(child: Text('中身')),
        source: "Center(child: Text('中身'))",
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
      name: 'resizeToAvoidBottomInset',
      typeLabel: 'bool',
      description: 'キーボードが出たとき、中身をその分だけ縮めて隠れないようにするか',
    ),
  ],
  build: _build,
  codeName: 'CupertinoPageScaffold',
);

// デモは一覧の見本や比較で同じ Route に何枚も並ぶので、Hero で飛ばさない
const _bar = CupertinoNavigationBar(
  transitionBetweenRoutes: false,
  middle: Text('ホーム'),
);

Widget _build(DemoArgs args) => SizedBox(
  width: 300,
  height: 200,
  // 詳細画面の上の余白（ステータスバーの分）を、小さな画面に持ち込まない
  child: Builder(
    builder: (context) => MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      child: CupertinoPageScaffold(
        navigationBar: args.valueOf<ObstructingPreferredSizeWidget>(
          'navigationBar',
        ),
        backgroundColor: args.valueOf<Color>('backgroundColor'),
        // 必須のプロパティなので、常に値がある
        child: args.valueOf<Widget>('child')!,
      ),
    ),
  ),
);

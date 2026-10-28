import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoListTileChevronEntry = WidgetEntry(
  id: 'cupertinoListTileChevron',
  name: 'CupertinoListTileChevron',
  genreIds: const ['cupertino'],
  summary: 'リストの行の終わりに置く、次へ進む印（›）',
  description:
      'CupertinoListTile の trailing に置く、灰色の「›」の印です。押すと次の画面へ進む行であることを示します。'
      '引数はなく、色と大きさは決まっています。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoListTileChevron-class.html',
  ),
  properties: const [],
  build: _build,
  codeName: 'CupertinoListTileChevron',
);

Widget _build(DemoArgs args) => const CupertinoListTileChevron();

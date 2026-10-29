import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoListTileChevronEntry = WidgetEntry(
  id: 'cupertinoListTileChevron',
  name: 'CupertinoListTileChevron',
  genreIds: const ['cupertino'],
  summary: 'リストの行の終わりに置く、次へ進む印（›）',
  description:
      'CupertinoListTile の trailing に置く、灰色の「›」の印です。押すと次の画面へ進む行であることを示します。'
      'key のほかに引数はなく、色と大きさは決まっています。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoListTileChevron-class.html',
  ),
  properties: const [],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
  ],
  build: _build,
  codeName: 'CupertinoListTileChevron',
);

Widget _build(DemoArgs args) => const CupertinoListTileChevron();

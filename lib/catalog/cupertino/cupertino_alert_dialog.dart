import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoAlertDialogEntry = WidgetEntry(
  id: 'cupertinoAlertDialog',
  name: 'CupertinoAlertDialog',
  genreIds: const ['cupertino'],
  summary: '題・説明・ボタンを並べた iOS の警告ダイアログ',
  description:
      '題と説明の下に、ボタンを横（多いときは縦）に並べる、iOS の警告ダイアログです。'
      'ふつうは showCupertinoDialog で画面の中央に出します。'
      'プレビューではダイアログそのものを置いています。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoAlertDialog-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'title',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '上に太字で出す題',
      control: FixedControl(value: Text('削除しますか？'), source: "Text('削除しますか？')"),
    ),
    PropertySpec(
      name: 'content',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '題の下に出す説明',
      control: FixedControl(
        value: Text('この操作は取り消せません。'),
        source: "Text('この操作は取り消せません。')",
      ),
    ),
    PropertySpec(
      name: 'actions',
      group: PropertyGroup.content,
      typeLabel: 'List<Widget>',
      description: '下に並べるボタン。ふつうは CupertinoDialogAction を並べる',
      control: FixedControl(
        value: _actions,
        source:
            "[CupertinoDialogAction(onPressed: () {}, child: Text('キャンセル')), "
            'CupertinoDialogAction(isDestructiveAction: true, '
            "onPressed: () {}, child: Text('削除'))]",
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
      name: 'scrollController',
      typeLabel: 'ScrollController?',
      description: 'content の部分のスクロールを外から動かす・読むときに渡す。渡さないと中で作る',
    ),
    ReferenceArg(
      name: 'actionScrollController',
      typeLabel: 'ScrollController?',
      description: 'actions の部分のスクロールを外から動かす・読むときに渡す。渡さないと中で作る',
    ),
    ReferenceArg(
      name: 'insetAnimationDuration',
      typeLabel: 'Duration',
      description: 'キーボードが出たときに、ダイアログが動く時間（プレビューでは見えない）',
    ),
    ReferenceArg(
      name: 'insetAnimationCurve',
      typeLabel: 'Curve',
      description: 'キーボードが出たときに、ダイアログが動く速さの変わり方（プレビューでは見えない）',
    ),
  ],
  build: _build,
  codeName: 'CupertinoAlertDialog',
);

void _pressed() {}

const _actions = <Widget>[
  CupertinoDialogAction(onPressed: _pressed, child: Text('キャンセル')),
  CupertinoDialogAction(
    isDestructiveAction: true,
    onPressed: _pressed,
    child: Text('削除'),
  ),
];

Widget _build(DemoArgs args) => CupertinoAlertDialog(
  title: args.valueOf<Widget>('title'),
  content: args.valueOf<Widget>('content'),
  actions: args.valueOf<List<Widget>>('actions') ?? const [],
);

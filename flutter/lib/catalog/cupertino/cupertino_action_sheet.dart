import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/demo/demo_scope.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoActionSheetEntry = WidgetEntry(
  id: 'cupertinoActionSheet',
  name: 'CupertinoActionSheet',
  genreIds: const ['cupertino'],
  summary: '画面の下から出る、iOS の選択肢の一覧',
  description:
      '題と説明の下に選択肢のボタンを並べ、離して取り消しのボタンを置く、iOS のアクションシートです。'
      'ふつうは showCupertinoModalPopup で下から出します。'
      'プレビューではシートそのものを置いています。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoActionSheet-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'title',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '上に出す題',
      control: FixedControl(value: Text('写真'), source: "Text('写真')"),
    ),
    PropertySpec(
      name: 'message',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '題の下に出す説明',
      initiallyOn: false,
      control: FixedControl(
        value: Text('この写真をどうしますか？'),
        source: "Text('この写真をどうしますか？')",
      ),
    ),
    PropertySpec(
      name: 'actions',
      group: PropertyGroup.content,
      typeLabel: 'List<Widget>?',
      description: '選択肢のボタン。ふつうは CupertinoActionSheetAction を並べる',
      required: true,
      control: FixedControl(
        value: _actions,
        source:
            '[CupertinoActionSheetAction('
            "onPressed: () {}, child: Text('保存')), "
            'CupertinoActionSheetAction(isDestructiveAction: true, '
            "onPressed: () {}, child: Text('削除'))]",
      ),
    ),
    PropertySpec(
      name: 'cancelButton',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '選択肢と離して下に置く、取り消しのボタン',
      control: FixedControl(
        value: _cancel,
        source: "CupertinoActionSheetAction(onPressed: () {}, child: Text('キャンセル'))",
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
      name: 'messageScrollController',
      typeLabel: 'ScrollController?',
      description: 'message の部分のスクロールを外から動かす・読むときに渡す。渡さないと中で作る',
    ),
    ReferenceArg(
      name: 'actionScrollController',
      typeLabel: 'ScrollController?',
      description: 'actions の部分のスクロールを外から動かす・読むときに渡す。渡さないと中で作る',
    ),
  ],
  build: _build,
  codeName: 'CupertinoActionSheet',
);

void _pressed() {}

const _actions = <Widget>[
  CupertinoActionSheetAction(onPressed: _pressed, child: Text('保存')),
  CupertinoActionSheetAction(
    isDestructiveAction: true,
    onPressed: _pressed,
    child: Text('削除'),
  ),
];

const Widget _cancel = CupertinoActionSheetAction(
  onPressed: _pressed,
  child: Text('キャンセル'),
);

/// シートは高さがあるので、比較中の低いカードでははみ出さないように縮める。
Widget _build(DemoArgs args) => DemoFit(
  child: CupertinoActionSheet(
    title: args.valueOf<Widget>('title'),
    message: args.valueOf<Widget>('message'),
    actions: args.valueOf<List<Widget>>('actions'),
    cancelButton: args.valueOf<Widget>('cancelButton'),
  ),
);

import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/demo/demo_navigator.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoPageRouteEntry = WidgetEntry(
  id: 'cupertinoPageRoute',
  name: 'CupertinoPageRoute',
  genreIds: const ['cupertino'],
  summary: '右から滑り込む iOS の画面遷移',
  description:
      'Navigator.push に渡す Route です。次の画面が右から滑り込み、左端から右へ引くと戻れます。'
      'fullscreenDialog を true にすると下からせり上がります。'
      'プレビューの中の Navigator で開きます（ボタンを押す）。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoPageRoute-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'title',
      group: PropertyGroup.content,
      typeLabel: 'String?',
      description: '次の画面の題。CupertinoNavigationBar の真ん中と、戻るボタンの文字に使われる',
      control: TextControl(initialValue: '設定'),
    ),
    PropertySpec(
      name: 'fullscreenDialog',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: 'true なら下からせり上がり、戻るボタンの代わりに閉じるボタンが出る',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'builder',
      typeLabel: 'WidgetBuilder',
      description: '次の画面を作る関数。ここでは NextPage を返す',
    ),
    ReferenceArg(
      name: 'settings',
      typeLabel: 'RouteSettings?',
      description: 'Route の名前と引数。Navigator の記録や復元に使う',
    ),
    ReferenceArg(
      name: 'requestFocus',
      typeLabel: 'bool?',
      description: '開いたときに、この Route にフォーカスを移すか',
    ),
    ReferenceArg(
      name: 'maintainState',
      typeLabel: 'bool',
      description: '上に別の画面が来て隠れている間も、この画面の状態を残しておくか',
    ),
    ReferenceArg(
      name: 'allowSnapshotting',
      typeLabel: 'bool',
      description: '遷移の動きの間、画面を画像に写して軽く動かしてよいか',
    ),
    ReferenceArg(
      name: 'barrierDismissible',
      typeLabel: 'bool',
      description: '後ろを押したら閉じるか。画面全体を覆う Route なので、ふつうは押せる後ろがない',
    ),
  ],
  build: _build,
  codeName: 'CupertinoPageRoute<void>',
  codeArguments: const ['builder: (context) => const NextPage()'],
);

Widget _build(DemoArgs args) {
  final title = args.valueOf<String>('title');
  final fullscreenDialog = args.valueOf<bool>('fullscreenDialog') ?? false;
  return DemoNavigator(
    onOpen: (navigator) => navigator.push(
      CupertinoPageRoute<void>(
        title: title,
        fullscreenDialog: fullscreenDialog,
        builder: (context) => const DemoNextPage(),
      ),
    ),
  );
}

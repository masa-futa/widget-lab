import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final listTileEntry = WidgetEntry(
  id: 'listTile',
  name: 'ListTile',
  genreIds: const ['material'],
  summary: '一覧の 1 行。左のアイコン・題・説明・右の印を並べる',
  description:
      '一覧の 1 行の決まった形です。左に leading、中に title と subtitle、右に trailing を並べます。'
      'onTap を渡すと押せる行になり、押したときに波紋が出ます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/ListTile-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'leading',
      typeLabel: 'Widget?',
      description: '題の左に置く Widget。ふつうは Icon か CircleAvatar',
      control: FixedControl(
        value: Icon(Icons.person),
        source: 'Icon(Icons.person)',
      ),
    ),
    PropertySpec(
      name: 'title',
      typeLabel: 'Widget?',
      description: '行の題',
      control: FixedControl(value: Text('山田 花子'), source: "Text('山田 花子')"),
    ),
    PropertySpec(
      name: 'subtitle',
      typeLabel: 'Widget?',
      description: '題の下の説明',
      initiallyOn: false,
      control: FixedControl(
        value: Text('明日の打ち合わせについて'),
        source: "Text('明日の打ち合わせについて')",
      ),
    ),
    PropertySpec(
      name: 'trailing',
      typeLabel: 'Widget?',
      description: '題の右に置く Widget',
      initiallyOn: false,
      control: FixedControl(
        value: Icon(Icons.chevron_right),
        source: 'Icon(Icons.chevron_right)',
      ),
    ),
    PropertySpec(
      name: 'onTap',
      typeLabel: 'GestureTapCallback?',
      description: '行を押したときに呼ばれる。指定すると押したときに波紋が出る',
      control: FixedControl(value: _noop, source: '() {}'),
    ),
    PropertySpec(
      name: 'selected',
      typeLabel: 'bool',
      description: '選んでいる行か。true だとアイコンと文字がテーマの primary の色になる。指定しないと false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
  ],
  build: _build,
  codeName: 'ListTile',
);

void _noop() {}

/// 行は幅いっぱいに広がるので、プレビューでは見やすい幅に決める。
/// 一覧の見本では地の色の箱の上に置かれるので、透明な Material で包んで
/// 波紋の描き先を ListTile のすぐ上にする（どちらもコードには出さない）。
Widget _build(DemoArgs args) => SizedBox(
  width: 280,
  child: Material(
    type: MaterialType.transparency,
    child: ListTile(
      leading: args.valueOf<Widget>('leading'),
      title: args.valueOf<Widget>('title'),
      subtitle: args.valueOf<Widget>('subtitle'),
      trailing: args.valueOf<Widget>('trailing'),
      onTap: args.valueOf<GestureTapCallback>('onTap'),
      selected: args.valueOf<bool>('selected') ?? false,
    ),
  ),
);

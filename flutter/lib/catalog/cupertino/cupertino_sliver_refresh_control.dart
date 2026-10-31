import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoSliverRefreshControlEntry = WidgetEntry(
  id: 'cupertinoSliverRefreshControl',
  name: 'CupertinoSliverRefreshControl',
  genreIds: const ['cupertino', 'layout', 'scrolling'],
  summary: '上の端を越えて引くと読み込み直す、iOS の引っぱって更新',
  description:
      'CustomScrollView の最初に置き、上の端を越えて引くとくるくる回る印を出して onRefresh を呼びます。'
      'onRefresh の Future が終わると印が消えます。端を越えて引けるよう、'
      'スクロールは BouncingScrollPhysics にします。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoSliverRefreshControl-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'refreshTriggerPullDistance',
      group: PropertyGroup.behavior,
      typeLabel: 'double',
      description: 'どれだけ引くと読み込みを始めるか。指定しないと 100',
      initiallyOn: false,
      control: SliderControl(
        min: 80,
        max: 160,
        divisions: 4,
        initialValue: 140,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'refreshIndicatorExtent',
      group: PropertyGroup.size,
      typeLabel: 'double',
      description: '読み込みの間、印のために空けておく高さ。指定しないと 60',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 80,
        divisions: 4,
        initialValue: 80,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    const PropertySpec(
      name: 'builder',
      group: PropertyGroup.content,
      typeLabel: 'RefreshControlIndicatorBuilder?',
      description: '引いている間に出す印を組み立てる。指定しないと、くるくる回る印',
      initiallyOn: false,
      control: FixedControl(
        value: _indicator,
        source:
            '(context, mode, pulledExtent, triggerDistance, indicatorExtent) => '
            'Center(child: Text(mode.name))',
      ),
    ),
    const PropertySpec(
      name: 'onRefresh',
      group: PropertyGroup.behavior,
      typeLabel: 'Future<void> Function()?',
      description: '引ききったときに呼ばれる。返した Future が終わるまで印が回る。null なら引いても読み込まない',
      control: FixedControl(
        value: _refresh,
        source: '() => Future.delayed(const Duration(seconds: 2))',
      ),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
  ],
  build: _build,
  codeName: 'CupertinoSliverRefreshControl',
);

Widget _indicator(
  BuildContext context,
  RefreshIndicatorMode mode,
  double pulledExtent,
  double triggerDistance,
  double indicatorExtent,
) => Center(child: Text(mode.name));

Future<void> _refresh() => Future.delayed(const Duration(seconds: 2));

Widget _build(DemoArgs args) => SizedBox(
  width: 320,
  height: 220,
  child: CustomScrollView(
    // Android でも端を越えて引けるようにする
    physics: const AlwaysScrollableScrollPhysics(
      parent: BouncingScrollPhysics(),
    ),
    slivers: [
      CupertinoSliverRefreshControl(
        refreshTriggerPullDistance:
            args.valueOf<double>('refreshTriggerPullDistance') ?? 100,
        refreshIndicatorExtent:
            args.valueOf<double>('refreshIndicatorExtent') ?? 60,
        onRefresh: args.valueOf<Future<void> Function()>('onRefresh'),
        builder:
            args.valueOf<RefreshControlIndicatorBuilder>('builder') ??
            CupertinoSliverRefreshControl.buildRefreshIndicator,
      ),
      SliverList.builder(
        itemCount: 20,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('${index + 1} 行目'),
        ),
      ),
    ],
  ),
);

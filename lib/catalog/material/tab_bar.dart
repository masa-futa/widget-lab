import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final tabBarEntry = WidgetEntry(
  id: 'tabBar',
  name: 'TabBar',
  genreIds: const ['material'],
  summary: 'タブを横に並べ、選んでいるものに下線を引く',
  description:
      'タブを横に並べ、選んでいるタブに下線（indicator）を引きます。'
      'TabController で TabBarView と選択をそろえます。ふつうは DefaultTabController で包み、'
      'AppBar の bottom に置きます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/TabBar-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'tabs',
      typeLabel: 'List<Widget>',
      description: 'タブ。ふつうは Tab。数は TabController の length と同じにする',
      required: true,
      control: FixedControl(
        value: <Widget>[
          Tab(text: 'おすすめ'),
          Tab(text: '新着'),
          Tab(text: 'フォロー中'),
        ],
        source: "[Tab(text: 'おすすめ'), Tab(text: '新着'), Tab(text: 'フォロー中')]",
      ),
    ),
    const PropertySpec(
      name: 'isScrollable',
      typeLabel: 'bool',
      description: '横にスクロールできるようにするか。true だと各タブは中身の幅になり、左に寄る',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'indicatorSize',
      typeLabel: 'TabBarIndicatorSize?',
      description: '下線の幅。tab はタブの幅いっぱい、label は文字の幅',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final value in TabBarIndicatorSize.values)
            Choice(value.name, value, 'TabBarIndicatorSize.${value.name}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'indicatorColor',
      typeLabel: 'Color?',
      description: '下線の色。指定しないとテーマの primary',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅', const Color(0xFFD7003A)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('山吹', const Color(0xFFF8B500)),
        ],
      ),
    ),
    PropertySpec(
      name: 'labelColor',
      typeLabel: 'Color?',
      description: '選んでいるタブの文字の色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅', const Color(0xFFD7003A)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('墨', const Color(0xFF18181B)),
        ],
      ),
    ),
  ],
  build: _build,
  codeName: 'TabBar',
);

/// TabBar は TabController が要るので、デモの部品の DefaultTabController で包む
/// （コードには出さない）。
Widget _build(DemoArgs args) => DefaultTabController(
  length: 3,
  child: TabBar(
    tabs: args.valueOf<List<Widget>>('tabs') ?? const [],
    isScrollable: args.valueOf<bool>('isScrollable') ?? false,
    indicatorSize: args.valueOf<TabBarIndicatorSize>('indicatorSize'),
    indicatorColor: args.valueOf<Color>('indicatorColor'),
    labelColor: args.valueOf<Color>('labelColor'),
  ),
);

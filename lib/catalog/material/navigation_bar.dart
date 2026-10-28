import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final navigationBarEntry = WidgetEntry(
  id: 'navigationBar',
  name: 'NavigationBar',
  genreIds: const ['material'],
  summary: '画面の下に、行き先を 3〜5 個並べる帯',
  description:
      '画面の下に置き、アプリの主な行き先を 3〜5 個並べます。選んでいる行き先には、'
      'アイコンの後ろに indicator（丸い地）が付きます。ふつうは Scaffold の bottomNavigationBar に渡します。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/NavigationBar-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'destinations',
      typeLabel: 'List<Widget>',
      description: '行き先。ふつうは NavigationDestination を 3〜5 個',
      required: true,
      control: FixedControl(
        value: <Widget>[
          NavigationDestination(icon: Icon(Icons.home), label: 'ホーム'),
          NavigationDestination(icon: Icon(Icons.search), label: '検索'),
          NavigationDestination(icon: Icon(Icons.person), label: '自分'),
        ],
        source:
            "[NavigationDestination(icon: Icon(Icons.home), label: 'ホーム'), "
            "NavigationDestination(icon: Icon(Icons.search), label: '検索'), "
            "NavigationDestination(icon: Icon(Icons.person), label: '自分')]",
      ),
    ),
    PropertySpec(
      name: 'selectedIndex',
      typeLabel: 'int',
      description: '選んでいる行き先の番号（0 から）',
      control: SliderControl(
        min: 0,
        max: 2,
        divisions: 2,
        initialValue: 0,
        resolve: (v) => v.round(),
        code: (v) => '${v.round()}',
      ),
    ),
    PropertySpec(
      name: 'labelBehavior',
      typeLabel: 'NavigationDestinationLabelBehavior?',
      description: '行き先の名前を出すか。onlyShowSelected は選んでいるものだけ',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final value in NavigationDestinationLabelBehavior.values)
            Choice(
              value.name,
              value,
              'NavigationDestinationLabelBehavior.${value.name}',
            ),
        ],
      ),
    ),
    PropertySpec(
      name: 'indicatorColor',
      typeLabel: 'Color?',
      description: '選んでいる行き先のアイコンの後ろの地の色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('山吹', const Color(0xFFF8B500)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('紅', const Color(0xFFD7003A)),
        ],
      ),
    ),
    PropertySpec(
      name: 'height',
      typeLabel: 'double?',
      description: '帯の高さ。指定しないと 80',
      initiallyOn: false,
      control: SliderControl(
        min: 56,
        max: 96,
        divisions: 4,
        initialValue: 64,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
  ],
  build: _build,
  codeName: 'NavigationBar',
);

Widget _build(DemoArgs args) => NavigationBar(
  destinations: args.valueOf<List<Widget>>('destinations') ?? const [],
  selectedIndex: args.valueOf<int>('selectedIndex') ?? 0,
  labelBehavior: args.valueOf<NavigationDestinationLabelBehavior>(
    'labelBehavior',
  ),
  indicatorColor: args.valueOf<Color>('indicatorColor'),
  height: args.valueOf<double>('height'),
);

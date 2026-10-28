import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_stage.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// 公式カタログの「Navigation rail」のカード。クラスの NavigationRail で見せる。
final navigationRailEntry = WidgetEntry(
  id: 'navigationRail',
  name: 'Navigation rail',
  genreIds: const ['material'],
  summary: '画面の横に、行き先を縦に並べる細い帯',
  description:
      '画面の左（か右）に置き、主な行き先を 3〜7 個縦に並べます。タブレットなど幅の広い画面で、'
      'NavigationBar の代わりに使います。extended にすると幅が広がり、名前がアイコンの横に出ます'
      '（extended の間は labelType を none か指定なしにする決まりなので、ここでは labelType を渡しません）。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/NavigationRail-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'destinations',
      typeLabel: 'List<NavigationRailDestination>',
      description: '行き先。2 個以上',
      required: true,
      control: FixedControl(
        value: <NavigationRailDestination>[
          NavigationRailDestination(icon: Icon(Icons.home), label: Text('ホーム')),
          NavigationRailDestination(
            icon: Icon(Icons.bookmark),
            label: Text('保存'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.settings),
            label: Text('設定'),
          ),
        ],
        source:
            "[NavigationRailDestination(icon: Icon(Icons.home), label: Text('ホーム')), "
            "NavigationRailDestination(icon: Icon(Icons.bookmark), label: Text('保存')), "
            "NavigationRailDestination(icon: Icon(Icons.settings), label: Text('設定'))]",
      ),
    ),
    PropertySpec(
      name: 'selectedIndex',
      typeLabel: 'int?',
      description: '選んでいる行き先の番号（0 から）。null（指定なし）だとどれも選ばない',
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
      name: 'labelType',
      typeLabel: 'NavigationRailLabelType?',
      description: '行き先の名前を出すか。selected は選んでいるものだけ、all は全部',
      control: ChoiceControl(
        initialIndex: 2,
        choices: [
          for (final value in NavigationRailLabelType.values)
            Choice(value.name, value, 'NavigationRailLabelType.${value.name}'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'extended',
      typeLabel: 'bool',
      description: '幅を広げ、名前をアイコンの横に出すか',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'backgroundColor',
      typeLabel: 'Color?',
      description: '帯の地の色。指定しないとテーマの surface',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('白', const Color(0xFFFFFFFF)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('山吹', const Color(0xFFF8B500)),
        ],
      ),
    ),
  ],
  build: _build,
  codeName: 'NavigationRail',
);

Widget _build(DemoArgs args) {
  final extended = args.valueOf<bool>('extended') ?? false;
  return DemoStage(
    size: const Size(280, 320),
    child: Align(
      alignment: AlignmentDirectional.centerStart,
      child: NavigationRail(
        destinations:
            args.valueOf<List<NavigationRailDestination>>('destinations') ??
            const [],
        selectedIndex: args.valueOf<int>('selectedIndex'),
        // extended の間は labelType を none 以外にできない（assert）ので渡さない
        labelType: extended
            ? null
            : args.valueOf<NavigationRailLabelType>('labelType'),
        extended: extended,
        backgroundColor: args.valueOf<Color>('backgroundColor'),
      ),
    ),
  );
}

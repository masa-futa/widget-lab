import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

PropertySpec _spec(String name, {PropertyGroup? group}) => PropertySpec(
  name: name,
  typeLabel: 'bool',
  description: '',
  group: group,
  control: const SwitchControl(initialValue: true),
);

WidgetEntry _entry(List<PropertySpec> properties) => WidgetEntry(
  id: 'e',
  name: 'E',
  genreIds: const ['basics'],
  summary: '',
  description: '',
  docUrl: Uri.parse('https://api.flutter.dev/'),
  properties: properties,
  build: (args) => const SizedBox(),
  codeName: 'E',
  references: const [
    ReferenceArg(name: 'key', typeLabel: 'Key?', description: '印'),
  ],
);

void main() {
  test('関係は既定で空', () {
    final spec = _spec('a');
    expect(spec.group, isNull);
    expect(spec.pairsWith, isEmpty);
    expect(spec.requires, isNull);
    expect(spec.excludes, isEmpty);
  });

  test('groups は仲間を語彙の順に重ねずに並べる', () {
    final entry = _entry([
      _spec('c', group: PropertyGroup.content),
      _spec('w', group: PropertyGroup.size),
      _spec('h', group: PropertyGroup.size),
      _spec('p', group: PropertyGroup.spacing),
    ]);
    expect(entry.groups, [
      PropertyGroup.size,
      PropertyGroup.spacing,
      PropertyGroup.content,
    ]);
  });

  test('仲間のないプロパティは null の仲間 1 つ', () {
    expect(_entry([_spec('a'), _spec('b')]).groups, [null]);
  });

  test('references を持てる', () {
    expect(_entry(const []).references.single.name, 'key');
  });
}

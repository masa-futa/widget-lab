import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/basics/container.dart';
import 'package:widget_lab/catalog/basics/row.dart';
import 'package:widget_lab/catalog/basics/text.dart';
import 'package:widget_lab/catalog/layout/padding.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';
import 'package:widget_lab/features/detail/view_model/code_generator.dart';

/// [entry] の全プロパティを OFF にした設定。
Map<String, PropertySetting> _allOff(WidgetEntry entry) => {
  for (final spec in entry.properties)
    spec.name: PropertySetting(on: false, value: spec.control.initial),
};

void main() {
  const generator = CodeGenerator();

  test('TC-38: ON のプロパティを、字下げ 2 文字の名前つきの引数で 1 行ずつ書く', () {
    final settings = {
      ..._allOff(paddingEntry),
      'padding': const PropertySetting(on: true, value: SliderValue(16)),
      'child': const PropertySetting(on: true, value: FixedValue()),
    };

    expect(
      generator.generate(paddingEntry, settings),
      'Padding(\n'
      '  padding: EdgeInsets.all(16.0),\n'
      '  child: FlutterLogo(),\n'
      ')',
    );
  });

  test('TC-38: OFF のプロパティは書かない', () {
    final settings = {
      ..._allOff(paddingEntry),
      'child': const PropertySetting(on: true, value: FixedValue()),
    };

    expect(
      generator.generate(paddingEntry, settings),
      'Padding(\n'
      '  child: FlutterLogo(),\n'
      ')',
    );
  });

  test('TC-39: 位置で渡す引数は、収録データの順にかかわらず名前つきの引数より前に書く', () {
    final entry = WidgetEntry(
      id: 'sample',
      name: 'Sample',
      genreIds: const ['text'],
      summary: '',
      description: '',
      docUrl: Uri.parse('https://api.flutter.dev/'),
      properties: const [
        PropertySpec(
          name: 'softWrap',
          typeLabel: 'bool',
          description: '',
          control: SwitchControl(initialValue: false),
        ),
        PropertySpec(
          name: 'data',
          typeLabel: 'String',
          description: '',
          required: true,
          arg: PropertyArg.positional,
          control: TextControl(initialValue: 'こんにちは'),
        ),
      ],
      build: (args) => const SizedBox(),
      codeName: 'Text',
    );

    expect(
      generator.generate(entry, entry.initialSettings()),
      'Text(\n'
      "  'こんにちは',\n"
      '  softWrap: false,\n'
      ')',
    );
  });

  test('TC-39: Text の文字は最初の引数になる', () {
    final settings = {
      ..._allOff(textEntry),
      'data': const PropertySetting(on: true, value: TextValue('こんにちは')),
    };

    expect(generator.generate(textEntry, settings), "Text(\n  'こんにちは',\n)");
  });

  test('TC-39: 必須のプロパティは設定が OFF でも書く', () {
    expect(
      generator.generate(textEntry, _allOff(textEntry)),
      "Text(\n  'こんにちは',\n)",
    );
  });

  test('TC-40: プロパティが全部 OFF なら 1 行になる', () {
    expect(
      generator.generate(paddingEntry, _allOff(paddingEntry)),
      'Padding()',
    );
  });

  group('TC-41: 値はそのまま貼れる式で書く', () {
    test('enum', () {
      final index = rowEntry.properties
          .firstWhere((p) => p.name == 'mainAxisAlignment')
          .control;
      final center = (index as ChoiceControl).choices.indexWhere(
        (c) => c.value == MainAxisAlignment.center,
      );
      final settings = {
        ..._allOff(rowEntry),
        'mainAxisAlignment': PropertySetting(
          on: true,
          value: ChoiceValue(center),
        ),
      };

      expect(
        generator.generate(rowEntry, settings),
        'Row(\n  mainAxisAlignment: MainAxisAlignment.center,\n)',
      );
    });

    test('色', () {
      final control = containerEntry.properties
          .firstWhere((p) => p.name == 'color')
          .control;
      final ruri = (control as ColorControl).palette.indexWhere(
        (c) => c.value == const Color(0xFF1E50A2),
      );
      final settings = {
        ..._allOff(containerEntry),
        'color': PropertySetting(on: true, value: ChoiceValue(ruri)),
      };

      expect(
        generator.generate(containerEntry, settings),
        'Container(\n  color: Color(0xFF1E50A2),\n)',
      );
    });

    test('引用符を含む文字', () {
      final settings = {
        ..._allOff(textEntry),
        'data': const PropertySetting(on: true, value: TextValue("It's")),
      };

      expect(generator.generate(textEntry, settings), "Text(\n  'It\\'s',\n)");
    });
  });
}

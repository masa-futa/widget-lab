import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/basics/container.dart';
import 'package:widget_lab/catalog/basics/row.dart';
import 'package:widget_lab/catalog/basics/text.dart';
import 'package:widget_lab/catalog/layout/padding.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/code_nest.dart';
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

/// 値を `MediaQuery.of(context).copyWith(…)` の中に書く Widget。
final _nestEntry = WidgetEntry(
  id: 'mediaQuery',
  name: 'MediaQuery',
  genreIds: const ['styling'],
  summary: '',
  description: '',
  docUrl: Uri.parse('https://api.flutter.dev/'),
  kind: EntryKind.behavior,
  properties: [
    PropertySpec(
      name: 'textScaler',
      typeLabel: 'TextScaler',
      description: '',
      arg: PropertyArg.nested,
      control: SliderControl(
        min: 1,
        max: 2,
        divisions: 10,
        initialValue: 1,
        resolve: TextScaler.linear,
        code: (v) => 'TextScaler.linear($v)',
      ),
    ),
    const PropertySpec(
      name: 'platformBrightness',
      typeLabel: 'Brightness',
      description: '',
      arg: PropertyArg.nested,
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('light', Brightness.light, 'Brightness.light'),
          Choice('dark', Brightness.dark, 'Brightness.dark'),
        ],
      ),
    ),
  ],
  build: (args) => const SizedBox(),
  buildWithout: (args) => const SizedBox(),
  codeName: 'MediaQuery',
  codeNest: const CodeNest(name: 'data', receiver: 'MediaQuery.of(context)'),
  codeArguments: const ['child: const Readers()'],
);

/// 受ける型を型引数に書く Widget。
final _typeEntry = WidgetEntry(
  id: 'notificationListener',
  name: 'NotificationListener',
  genreIds: const ['scrolling'],
  summary: '',
  description: '',
  docUrl: Uri.parse('https://api.flutter.dev/'),
  kind: EntryKind.behavior,
  properties: const [
    PropertySpec(
      name: 'type',
      typeLabel: 'Type',
      description: '',
      required: true,
      arg: PropertyArg.typeArgument,
      control: ChoiceControl(
        choices: [
          Choice(
            'ScrollNotification',
            ScrollNotification,
            'ScrollNotification',
          ),
          Choice(
            'ScrollUpdateNotification',
            ScrollUpdateNotification,
            'ScrollUpdateNotification',
          ),
        ],
      ),
    ),
  ],
  build: (args) => const SizedBox(),
  buildWithout: (args) => const SizedBox(),
  codeName: 'NotificationListener',
  codeArguments: const ['child: const Rows()'],
);

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

  group('行ごと', () {
    test('TC-38: 行の文字をつなぐと generate と同じで、行にプロパティ名が付く', () {
      final settings = paddingEntry.initialSettings();

      final lines = generator.lines(paddingEntry, settings);

      expect(
        lines.map((l) => l.text).join('\n'),
        generator.generate(paddingEntry, settings),
      );
      expect(lines.map((l) => l.property), [null, 'padding', 'child', null]);
    });

    test('TC-40: プロパティが全部 OFF なら 1 行で、プロパティ名なし', () {
      final lines = generator.lines(paddingEntry, _allOff(paddingEntry));

      expect(lines, [const CodeLine(text: 'Padding()')]);
    });

    test('TC-64: 値を変えた行と、最初は OFF で書かれていなかった行が「変えた」', () {
      final settings = {
        ...containerEntry.initialSettings(),
        'padding': const PropertySetting(on: true, value: SliderValue(24)),
        'width': const PropertySetting(on: true, value: SliderValue(200)),
      };

      final changed = {
        for (final line in generator.lines(containerEntry, settings))
          ?line.property: line.changed,
      };

      expect(changed, {
        'padding': true,
        'color': false,
        'width': true,
        'child': false,
      });
    });

    test('TC-64: 開いたときの設定では、どの行も「変えていない」', () {
      final lines = generator.lines(
        containerEntry,
        containerEntry.initialSettings(),
      );

      expect(lines.where((l) => l.changed), isEmpty);
    });
  });

  group('TC-79: 入れ子の式（MediaQuery の copyWith）', () {
    test('ON のプロパティだけを copyWith の中に 1 行ずつ書き、固定の引数を最後に書く', () {
      final settings = {
        ..._nestEntry.initialSettings(),
        'textScaler': const PropertySetting(on: true, value: SliderValue(1.5)),
      };

      final lines = generator.lines(_nestEntry, settings);

      expect(lines, const [
        CodeLine(text: 'MediaQuery('),
        CodeLine(text: '  data: MediaQuery.of(context).copyWith('),
        CodeLine(
          text: '    textScaler: TextScaler.linear(1.5),',
          property: 'textScaler',
          changed: true,
        ),
        CodeLine(text: '  ),'),
        CodeLine(text: '  child: const Readers(),'),
        CodeLine(text: ')'),
      ]);
    });

    test('最初は OFF のプロパティを ON にすると、その行が「変えた」', () {
      final settings = {
        ..._nestEntry.initialSettings(),
        'platformBrightness': const PropertySetting(
          on: true,
          value: ChoiceValue(1),
        ),
      };

      final changed = {
        for (final line in generator.lines(_nestEntry, settings))
          ?line.property: line.changed,
      };

      expect(changed, {'textScaler': false, 'platformBrightness': true});
    });

    test('入れ子の中が全部 OFF なら、もとの式だけを 1 行で書く', () {
      final lines = generator.lines(_nestEntry, _allOff(_nestEntry));

      expect(lines.map((l) => l.text), [
        'MediaQuery(',
        '  data: MediaQuery.of(context),',
        '  child: const Readers(),',
        ')',
      ]);
    });
  });

  group('TC-79: 型引数（NotificationListener<T>）', () {
    test('型引数の行が、型のプロパティの行になる', () {
      final lines = generator.lines(_typeEntry, _typeEntry.initialSettings());

      expect(lines, const [
        CodeLine(
          text: 'NotificationListener<ScrollNotification>(',
          property: 'type',
        ),
        CodeLine(text: '  child: const Rows(),'),
        CodeLine(text: ')'),
      ]);
    });

    test('型を変えると、型引数の行が「変えた」', () {
      final settings = {
        'type': const PropertySetting(on: true, value: ChoiceValue(1)),
      };

      final head = generator.lines(_typeEntry, settings).first;

      expect(
        head,
        const CodeLine(
          text: 'NotificationListener<ScrollUpdateNotification>(',
          property: 'type',
          changed: true,
        ),
      );
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

WidgetEntry _entry() => WidgetEntry(
  id: 'sample',
  name: 'Sample',
  genreIds: const ['layout'],
  summary: '',
  description: '',
  docUrl: Uri.parse('https://api.flutter.dev/'),
  properties: [
    PropertySpec(
      name: 'padding',
      typeLabel: 'EdgeInsetsGeometry',
      description: '',
      control: SliderControl(
        min: 0,
        max: 48,
        divisions: 12,
        initialValue: 16,
        resolve: EdgeInsets.all,
        code: (v) => 'EdgeInsets.all($v)',
      ),
    ),
    const PropertySpec(
      name: 'data',
      typeLabel: 'String',
      description: '',
      required: true,
      initiallyOn: false,
      arg: PropertyArg.positional,
      control: TextControl(initialValue: 'こんにちは'),
    ),
  ],
  build: (args) => const SizedBox(),
  codeName: 'Sample',
);

void main() {
  group('TC-18: OFF のプロパティは「指定なし」として組み立ての関数に渡る', () {
    test('開いたときの設定は initiallyOn と最初の値。必須は ON', () {
      final settings = _entry().initialSettings();

      expect(
        settings['padding'],
        const PropertySetting(on: true, value: SliderValue(16)),
      );
      expect(
        settings['data'],
        const PropertySetting(on: true, value: TextValue('こんにちは')),
      );
    });

    test('ON のプロパティは Widget に渡す値になる', () {
      final entry = _entry();
      final args = DemoArgs(entry, entry.initialSettings());

      expect(args.valueOf<EdgeInsets>('padding'), const EdgeInsets.all(16));
    });

    test('OFF のプロパティは null になる', () {
      final entry = _entry();
      final args = DemoArgs(entry, {
        ...entry.initialSettings(),
        'padding': const PropertySetting(on: false, value: SliderValue(32)),
      });

      expect(args.valueOf<EdgeInsets>('padding'), isNull);
    });

    test('必須のプロパティは設定が OFF でも値になる', () {
      final entry = _entry();
      final args = DemoArgs(entry, {
        'data': const PropertySetting(on: false, value: TextValue('やあ')),
      });

      expect(args.valueOf<String>('data'), 'やあ');
    });

    test('設定がないプロパティは OFF、必須なら最初の値で ON', () {
      final args = DemoArgs(_entry(), const {});

      expect(args.valueOf<EdgeInsets>('padding'), isNull);
      expect(args.valueOf<String>('data'), 'こんにちは');
    });

    test('収録データにない名前と、合わない型は収録データの不備として知らせる', () {
      final entry = _entry();
      final args = DemoArgs(entry, entry.initialSettings());

      expect(() => args.valueOf<EdgeInsets>('margin'), throwsArgumentError);
      expect(() => args.valueOf<String>('padding'), throwsStateError);
    });
  });
}

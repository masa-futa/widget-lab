import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/dart_code.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';

void main() {
  group('TC-41: 値の式が、そのまま貼れる Dart の式になる', () {
    test('数値はスライダーの写し方で式になる', () {
      final control = SliderControl(
        min: 0,
        max: 48,
        divisions: 12,
        initialValue: 16,
        resolve: EdgeInsets.all,
        code: (v) => 'EdgeInsets.all($v)',
      );

      expect(control.initial, const SliderValue(16));
      expect(control.resolve(const SliderValue(16)), const EdgeInsets.all(16));
      expect(control.code(const SliderValue(16)), 'EdgeInsets.all(16.0)');
    });

    test('enum は選んだ選択肢の式になる', () {
      const control = ChoiceControl(
        choices: [
          Choice('start', MainAxisAlignment.start, 'MainAxisAlignment.start'),
          Choice(
            'center',
            MainAxisAlignment.center,
            'MainAxisAlignment.center',
          ),
        ],
      );

      expect(control.initial, const ChoiceValue(0));
      expect(control.resolve(const ChoiceValue(1)), MainAxisAlignment.center);
      expect(control.code(const ChoiceValue(1)), 'MainAxisAlignment.center');
    });

    test('色は Color(0xAARRGGBB) の式になる', () {
      final control = ColorControl(
        palette: [Choice.color('瑠璃', const Color(0xFF1E50A2))],
      );

      expect(control.resolve(const ChoiceValue(0)), const Color(0xFF1E50A2));
      expect(control.code(const ChoiceValue(0)), 'Color(0xFF1E50A2)');
    });

    test('文字は引用符と特殊な文字を逃がした文字列の式になる', () {
      const control = TextControl(initialValue: 'こんにちは');

      expect(control.initial, const TextValue('こんにちは'));
      expect(control.resolve(const TextValue("It's")), "It's");
      expect(control.code(const TextValue("It's")), r"'It\'s'");
    });

    test('真偽は true / false の式になる', () {
      const control = SwitchControl(initialValue: true);

      expect(control.initial, const SwitchValue(true));
      expect(control.resolve(const SwitchValue(false)), false);
      expect(control.code(const SwitchValue(false)), 'false');
    });

    test('固定の値は決めた式になる', () {
      const control = FixedControl(
        value: FlutterLogo(),
        source: 'FlutterLogo()',
      );

      expect(control.initial, const FixedValue());
      expect(control.resolve(const FixedValue()), isA<FlutterLogo>());
      expect(control.code(const FixedValue()), 'FlutterLogo()');
    });

    test('操作部品と合わない種類の値は受け付けない', () {
      const control = SwitchControl(initialValue: true);

      expect(() => control.resolve(const SliderValue(1)), throwsArgumentError);
      expect(() => control.code(const TextValue('a')), throwsArgumentError);
    });

    test('範囲の外の選択肢は受け付けない', () {
      const control = ChoiceControl(choices: [Choice('a', 1, '1')]);

      expect(() => control.resolve(const ChoiceValue(1)), throwsArgumentError);
      expect(() => control.code(const ChoiceValue(-1)), throwsArgumentError);
    });

    test('スライダーの段の値は、浮動小数の誤差を丸めて写す', () {
      final control = SliderControl(
        min: 0,
        max: 300,
        divisions: 30,
        initialValue: 200,
        resolve: (v) => v,
        code: (v) => '$v',
      );
      // Slider が 11 段目で返す値（min + (max - min) * 11 / 30）
      const step = SliderValue(109.99999999999999);

      expect(control.resolve(step), 110.0);
      expect(control.code(step), '110.0');
    });
  });

  group('dartString', () {
    test('逆スラッシュ・ドル記号・改行も逃がす', () {
      expect(dartString(r'a\b'), r"'a\\b'");
      expect(dartString(r'$x'), r"'\$x'");
      expect(dartString('1\n2\t3'), r"'1\n2\t3'");
    });
  });

  group('NestedControl', () {
    final control = NestedControl(
      typeName: 'BoxDecoration',
      children: const [
        PropertySpec(
          name: 'color',
          typeLabel: 'Color?',
          description: '',
          control: ColorControl(
            palette: [Choice('若竹', Color(0xFF68BE8D), 'Color(0xFF68BE8D)')],
          ),
        ),
        PropertySpec(
          name: 'shape',
          typeLabel: 'BoxShape',
          description: '',
          initiallyOn: false,
          control: ChoiceControl(
            choices: [Choice('circle', BoxShape.circle, 'BoxShape.circle')],
          ),
        ),
      ],
      build: (values) => BoxDecoration(
        color: values['color'] as Color?,
        shape: values['shape'] as BoxShape? ?? BoxShape.rectangle,
      ),
    );

    test('最初の値は子の最初の設定', () {
      final initial = control.initial;
      expect(initial.settings['color']!.on, isTrue);
      expect(initial.settings['shape']!.on, isFalse);
    });

    test('ON の子の値だけで組み立てる', () {
      expect(
        control.resolve(control.initial),
        const BoxDecoration(color: Color(0xFF68BE8D)),
      );
    });

    test('ON の子を 1 行に書く', () {
      expect(
        control.code(control.initial),
        'BoxDecoration(color: Color(0xFF68BE8D))',
      );
    });

    test('ON の子がなければ const の空の式', () {
      final off = control.initial.copyWithChild(
        'color',
        control.initial.settings['color']!.copyWith(on: false),
      );
      expect(control.code(off), 'const BoxDecoration()');
    });

    test('NestedValue は中身で比べる', () {
      expect(
        control.initial,
        control.initial.copyWithChild(
          'color',
          control.initial.settings['color']!,
        ),
      );
    });
  });
}

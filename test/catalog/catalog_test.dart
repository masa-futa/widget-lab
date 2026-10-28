import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/catalog.dart';
import 'package:widget_lab/catalog/genres.dart';
import 'package:widget_lab/catalog/manifest.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';
import 'package:widget_lab/core/theme/app_theme.dart';
import 'package:widget_lab/features/detail/ui/widgets/preview_card.dart';

/// プレビューのカードの大きさ。小さいスマートフォン（360×640）で、
/// 1 枚のとき（プレビューは画面の高さの約 4 割＝256 から上下の余白 8 を引く。
/// 幅は左右の余白 16 を引く）と、比較中の 2 枚の 1 枚（見出しとラベルを引いた残りの半分）。
/// DetailScreen の高さの割合や DetailPreview の余白を変えたら、ここも合わせる。
const _cardSizes = [Size(328, 240), Size(328, 64)];

/// 実物のプレビューのカードに入れて組み立て、例外が出ないことを確かめる。
Future<void> _expectBuilds(
  WidgetTester tester,
  WidgetEntry entry,
  Map<String, PropertySetting> settings,
) async {
  for (final size in _cardSizes) {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: SizedBox.fromSize(
              size: size,
              child: PreviewCard(child: entry.build(DemoArgs(entry, settings))),
            ),
          ),
        ),
      ),
    );
    expect(
      tester.takeException(),
      isNull,
      reason: '${entry.id} ($size): $settings',
    );
  }
}

/// [entry] の全プロパティを [on] にした設定（値は最初の値）。
Map<String, PropertySetting> _all(WidgetEntry entry, {required bool on}) => {
  for (final spec in entry.properties)
    spec.name: PropertySetting(on: on, value: spec.control.initial),
};

/// 全部 ON のうえで、1つのプロパティだけ値を変えた設定の一覧。
/// 選択肢・色見本は全部、スライダーは最小と最大、スイッチは両方。
List<Map<String, PropertySetting>> _variations(WidgetEntry entry) {
  final base = _all(entry, on: true);
  return [
    for (final spec in entry.properties)
      for (final value in switch (spec.control) {
        ChoiceControl(:final choices) => [
          for (var i = 0; i < choices.length; i++) ChoiceValue(i),
        ],
        ColorControl(:final palette) => [
          for (var i = 0; i < palette.length; i++) ChoiceValue(i),
        ],
        SliderControl(:final min, :final max) => [
          SliderValue(min),
          SliderValue(max),
        ],
        SwitchControl() => const [SwitchValue(true), SwitchValue(false)],
        TextControl() => const [TextValue(''), TextValue("It's")],
        FixedControl() => const [FixedValue()],
      })
        {...base, spec.name: PropertySetting(on: true, value: value)},
  ];
}

void main() {
  group('TC-03: 収録データの ID とジャンル', () {
    test('ID が重ならない', () {
      final ids = allEntries.map((e) => e.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
    });

    test('全件が 1 つ以上のジャンルに入り、そのジャンルが定義されている', () {
      final genreIds = allGenres.map((g) => g.id).toSet();
      for (final entry in allEntries) {
        expect(entry.genreIds, isNotEmpty, reason: entry.id);
        expect(genreIds, containsAll(entry.genreIds), reason: entry.id);
      }
    });

    test('ジャンルの ID が重ならない', () {
      final ids = allGenres.map((g) => g.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
    });

    test('1 つの Widget の中でプロパティの名前が重ならない', () {
      for (final entry in allEntries) {
        final names = entry.properties.map((p) => p.name).toList();
        expect(names.toSet(), hasLength(names.length), reason: entry.id);
      }
    });

    test('操作部品の最初の値が範囲の中にある', () {
      for (final entry in allEntries) {
        for (final spec in entry.properties) {
          final reason = '${entry.id}.${spec.name}';
          switch (spec.control) {
            case SliderControl(:final min, :final max, :final initialValue):
              expect(initialValue, inInclusiveRange(min, max), reason: reason);
            case ChoiceControl(:final choices, :final initialIndex):
              expect(initialIndex, inInclusiveRange(0, choices.length - 1));
            case ColorControl(:final palette, :final initialIndex):
              expect(initialIndex, inInclusiveRange(0, palette.length - 1));
            case TextControl(:final initialValue, :final maxLength):
              expect(initialValue.length, lessThanOrEqualTo(maxLength));
            case SwitchControl() || FixedControl():
              break;
          }
        }
      }
    });
  });

  group('TC-03: 収録データの値の書き方', () {
    test('公式ドキュメントの URL は api.flutter.dev の https', () {
      for (final entry in allEntries) {
        expect(entry.docUrl.scheme, 'https', reason: entry.id);
        expect(entry.docUrl.host, 'api.flutter.dev', reason: entry.id);
      }
    });

    test('スライダーのどの段でも、コードに浮動小数の誤差が出ない', () {
      final longDecimal = RegExp(r'\d\.\d{4,}');
      for (final entry in allEntries) {
        for (final spec in entry.properties) {
          if (spec.control case SliderControl(
            :final min,
            :final max,
            :final divisions,
          )) {
            for (var i = 0; i <= divisions; i++) {
              // Slider が i 段目で返す値と同じ計算
              final value = SliderValue(min + (max - min) * (i / divisions));
              final code = spec.control.code(value);
              expect(
                longDecimal.hasMatch(code),
                isFalse,
                reason: '${entry.id}.${spec.name}: $code',
              );
            }
          }
        }
      }
    });
  });

  group('TC-04: 公式カタログの一覧との突き合わせ', () {
    test('manifest のジャンルが genres.dart と同じ並び', () {
      expect(manifest.keys, allGenres.map((g) => g.id));
    });

    test('一覧にない Widget を収録していない（入っているジャンルも一覧どおり）', () {
      for (final entry in allEntries) {
        for (final genreId in entry.genreIds) {
          expect(
            manifest[genreId],
            contains(entry.name),
            reason: '${entry.name} は公式カタログの $genreId にない',
          );
        }
      }
    });

    test('公式カタログで載っているジャンルには全部入れる', () {
      for (final entry in allEntries) {
        final listed = [
          for (final MapEntry(:key, :value) in manifest.entries)
            if (value.contains(entry.name)) key,
        ];
        expect(entry.genreIds.toSet(), listed.toSet(), reason: entry.name);
      }
    });

    final collected = allEntries.map((e) => e.name).toSet();
    final missing = manifest.values
        .expand((names) => names)
        .toSet()
        .difference(collected);
    test(
      '公式カタログの Widget が全部収録されている',
      () => expect(missing, isEmpty),
      skip: missing.isEmpty ? false : '収録の抜け: ${missing.length} 件（全部揃うまで数だけ出す）',
    );
  });

  group('TC-05: 全件を全プロパティ OFF（必須は ON）で組み立てられる', () {
    for (final entry in allEntries) {
      testWidgets(entry.id, (tester) async {
        await _expectBuilds(tester, entry, _all(entry, on: false));
      });
    }
  });

  group('TC-06: 全件を全プロパティ ON・各選択肢の値で組み立てられる', () {
    for (final entry in allEntries) {
      testWidgets(entry.id, (tester) async {
        await _expectBuilds(tester, entry, _all(entry, on: true));
        for (final settings in _variations(entry)) {
          await _expectBuilds(tester, entry, settings);
        }
      });
    }
  });
}

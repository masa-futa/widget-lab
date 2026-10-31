import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/catalog.dart';
import 'package:widget_lab/catalog/genres.dart';
import 'package:widget_lab/catalog/manifest.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/genre.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';
import 'package:widget_lab/core/theme/app_theme.dart';
import 'package:widget_lab/features/catalog/ui/widgets/entry_sample.dart';
import 'package:widget_lab/features/detail/view_model/detail_state.dart';
import 'package:widget_lab/features/detail/view_model/picker_item.dart';
import 'package:widget_lab/features/detail/ui/widgets/preview_card.dart';

/// プレビューのカードの大きさ。小さいスマートフォン（360×640）で、
/// 1 枚のとき（プレビューは画面の高さの約 4 割＝256 から上下の余白 8 を引く。
/// 幅は左右の余白 16 を引く）と、比較中の 2 枚の 1 枚（見出しとラベルを引いた残りの半分）。
/// DetailScreen の高さの割合や DetailPreview の余白を変えたら、ここも合わせる。
const _cardSizes = [Size(328, 240), Size(328, 64)];

/// 実物のプレビューのカードに入れて組み立て、例外が出ないことを確かめる。
/// [build] を渡せば、`entry.build` の代わりにそれで組み立てる（使わない側）。
Future<void> _expectBuilds(
  WidgetTester tester,
  WidgetEntry entry,
  Map<String, PropertySetting> settings, {
  DemoBuilder? build,
}) async {
  final builder = build ?? entry.build;
  for (final size in _cardSizes) {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: SizedBox.fromSize(
              size: size,
              child: PreviewCard(child: builder(DemoArgs(entry, settings))),
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

/// [control] の試す値。選択肢・色見本は全部、スライダーは最小と最大、スイッチは両方。
/// 入れ子は、子を全部 ON にしたうえで 1 つの子だけ値を変えたものと、子を全部 OFF にしたもの。
List<ControlValue> _values(PropertyControl control) => switch (control) {
  ChoiceControl(:final choices) => [
    for (var i = 0; i < choices.length; i++) ChoiceValue(i),
  ],
  ColorControl(:final palette) => [
    for (var i = 0; i < palette.length; i++) ChoiceValue(i),
  ],
  SliderControl(:final min, :final max) => [SliderValue(min), SliderValue(max)],
  SwitchControl() => const [SwitchValue(true), SwitchValue(false)],
  TextControl() => const [TextValue(''), TextValue("It's")],
  FixedControl() => const [FixedValue()],
  NestedControl(:final children) => [
    for (final child in children)
      for (final value in _values(child.control))
        NestedValue({
          for (final c in children)
            c.name: PropertySetting(on: true, value: c.control.initial),
          child.name: PropertySetting(on: true, value: value),
        }),
    NestedValue({
      for (final c in children)
        c.name: PropertySetting(on: false, value: c.control.initial),
    }),
  ],
};

/// 全部 ON のうえで、1つのプロパティだけ値を変えた設定の一覧。
List<Map<String, PropertySetting>> _variations(WidgetEntry entry) {
  final base = _all(entry, on: true);
  return [
    for (final spec in entry.properties)
      for (final value in _values(spec.control))
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

    test('型引数のプロパティは必須で 1 つまで、入れ子のプロパティは入れ子の式がある Widget だけ', () {
      for (final entry in allEntries) {
        final typeArguments = entry.properties.where(
          (spec) => spec.arg == PropertyArg.typeArgument,
        );
        expect(typeArguments.length, lessThanOrEqualTo(1), reason: entry.id);
        expect(typeArguments.every((spec) => spec.required), isTrue);
        if (entry.codeNest == null) {
          expect(
            entry.properties.where((spec) => spec.arg == PropertyArg.nested),
            isEmpty,
            reason: entry.id,
          );
        }
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
            case SwitchControl() || FixedControl() || NestedControl():
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

  group('TC-92: 全件で、選ぶ欄の送る順番がプロパティを 1 回ずつ通り、最後が補足', () {
    for (final entry in allEntries) {
      test(entry.id, () {
        final items = DetailState.initial(entry, const <Genre>[]).pickerItems;
        expect(
          [
            for (final item in items)
              if (item case PickerProperty(:final spec)) spec.name,
          ]..sort(),
          [for (final spec in entry.properties) spec.name]..sort(),
        );
        expect(
          items.whereType<PickerReferences>().length,
          entry.references.isEmpty ? 0 : 1,
        );
        if (entry.references.isNotEmpty) {
          expect(items.last, const PickerReferences());
        }
      });
    }
  });

  group('ジャンルの定義', () {
    test('Cupertino と Material design はデザインシステムの段、残りは基本の段', () {
      for (final genre in allGenres) {
        expect(
          genre.group,
          ['cupertino', 'material'].contains(genre.id)
              ? GenreGroupKind.designSystem
              : GenreGroupKind.base,
          reason: genre.id,
        );
      }
    });

    test('全ジャンルに一言の説明がある', () {
      for (final genre in allGenres) {
        expect(genre.description, isNotEmpty, reason: genre.id);
      }
    });
  });

  testWidgets('TC-69: 全件の見本が、最初の値で例外を出さずに組み立つ', (tester) async {
    for (final entry in allEntries) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Center(child: EntrySample(entry: entry)),
          ),
        ),
      );
      expect(tester.takeException(), isNull, reason: entry.id);
    }
  });

  group('TC-78: 見た目を持たない Widget の使わない側', () {
    test(
      'behavior は buildWithout を持ち、visual は buildWithout も codeWithout も持たない',
      () {
        for (final entry in allEntries) {
          switch (entry.kind) {
            case EntryKind.behavior:
              expect(entry.buildWithout, isNotNull, reason: entry.id);
            case EntryKind.visual:
              expect(entry.buildWithout, isNull, reason: entry.id);
              expect(entry.codeWithout, isNull, reason: entry.id);
          }
        }
      },
    );

    for (final entry in allEntries) {
      final buildWithout = entry.buildWithout;
      if (buildWithout == null) continue;
      testWidgets('${entry.id} の使わない側を、全部 OFF・全部 ON・各選択肢の値で組み立てられる', (
        tester,
      ) async {
        await _expectBuilds(
          tester,
          entry,
          _all(entry, on: false),
          build: buildWithout,
        );
        for (final settings in [_all(entry, on: true), ..._variations(entry)]) {
          await _expectBuilds(tester, entry, settings, build: buildWithout);
        }
      });
    }
  });

  group('TC-87: 関係と仲間の決まり', () {
    for (final entry in allEntries) {
      final names = {for (final spec in entry.properties) spec.name};
      test('${entry.name}: 関係の相手が実在し、自分を指さない', () {
        for (final spec in entry.properties) {
          for (final other in [
            ...spec.pairsWith,
            ...spec.excludes,
            ?spec.requires,
          ]) {
            expect(names, contains(other), reason: '${spec.name} → $other');
            expect(other, isNot(spec.name), reason: spec.name);
          }
        }
      });
      test('${entry.name}: excludes は両方向に書く', () {
        final byName = {for (final s in entry.properties) s.name: s};
        for (final spec in entry.properties) {
          for (final other in spec.excludes) {
            expect(
              byName[other]!.excludes,
              contains(spec.name),
              reason: '${spec.name} ✕ $other',
            );
          }
        }
      });
      test('${entry.name}: 仲間は全部に付けるか、全部に付けない', () {
        final grouped = entry.properties.where((s) => s.group != null).length;
        expect(grouped == 0 || grouped == entry.properties.length, isTrue);
      });
      test('${entry.name}: 補足とプロパティの名前が重ならない', () {
        for (final reference in entry.references) {
          expect(names, isNot(contains(reference.name)));
        }
      });
    }
  });
}

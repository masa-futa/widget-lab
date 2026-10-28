import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/genres.dart';
import 'package:widget_lab/catalog/layout/padding.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/features/detail/view_model/comparing.dart';
import 'package:widget_lab/features/detail/view_model/detail_state.dart';

void main() {
  final initial = DetailState.initial(paddingEntry, allGenres.take(1).toList());

  test('同じ中身なら、settings の並びが違っても等しく、hashCode も同じ', () {
    final a = initial.copyWith(
      settings: {
        'padding': const PropertySetting(on: true, value: SliderValue(16)),
        'child': const PropertySetting(on: true, value: FixedValue()),
      },
    );
    final b = initial.copyWith(
      settings: {
        'child': const PropertySetting(on: true, value: FixedValue()),
        'padding': const PropertySetting(on: true, value: SliderValue(16)),
      },
    );

    expect(a, b);
    expect(a.hashCode, b.hashCode);
  });

  test('値・選択・比較が違えば等しくない', () {
    expect(
      initial.copyWith(
        settings: {
          ...initial.settings,
          'padding': const PropertySetting(on: true, value: SliderValue(8)),
        },
      ),
      isNot(initial),
    );
    expect(
      initial.copyWith(comparing: () => const ComparingProperty('padding')),
      isNot(initial),
    );
    expect(initial.copyWith(selected: 'child'), isNot(initial));
  });

  test('比べているプロパティの定義を返し、比較していなければ null', () {
    expect(initial.comparingSpec, isNull);
    expect(
      initial
          .copyWith(comparing: () => const ComparingProperty('padding'))
          .comparingSpec
          ?.name,
      'padding',
    );
  });
}

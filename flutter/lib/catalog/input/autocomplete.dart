import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// デモの候補。
const _fruits = [
  'apple',
  'apricot',
  'banana',
  'blueberry',
  'cherry',
  'grape',
  'lemon',
  'melon',
];

typedef _OptionsBuilder = Iterable<String> Function(TextEditingValue value);

final autocompleteEntry = WidgetEntry(
  id: 'autocomplete',
  name: 'Autocomplete',
  genreIds: const ['input'],
  summary: '入力に合わせて候補を出し、選ぶと欄に入れる',
  description:
      '入力欄に文字を入れると、optionsBuilder が返した候補を欄の下（または上）に重ねて出します。'
      '候補を押すと欄に入ります。ここでは果物の英語名から探します（例: 「ap」）。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/Autocomplete-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'optionsBuilder',
      group: PropertyGroup.behavior,
      typeLabel: 'AutocompleteOptionsBuilder<T>',
      description: '入力から候補を作る。空の入力では候補を出さないのがふつう',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice(
            '前方一致',
            _startsWith,
            '(value) => fruits.where((f) => f.startsWith(value.text))',
          ),
          Choice(
            '部分一致',
            _contains,
            '(value) => fruits.where((f) => f.contains(value.text))',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'optionsMaxHeight',
      group: PropertyGroup.size,
      typeLabel: 'double',
      description: '候補の一覧の高さの上限。超えるとスクロールする',
      initiallyOn: false,
      control: SliderControl(
        min: 48,
        max: 240,
        divisions: 4,
        initialValue: 96,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'optionsViewOpenDirection',
      group: PropertyGroup.layout,
      typeLabel: 'OptionsViewOpenDirection',
      description: '候補を欄の下に出すか（down）、上に出すか（up）。mostSpace は広い方',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          for (final value in OptionsViewOpenDirection.values)
            Choice(value.name, value, 'OptionsViewOpenDirection.${value.name}'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'initialValue',
      group: PropertyGroup.content,
      typeLabel: 'TextEditingValue?',
      description: '最初に欄に入れておく文字',
      initiallyOn: false,
      control: FixedControl(
        value: TextEditingValue(text: 'ap'),
        source: "TextEditingValue(text: 'ap')",
      ),
    ),
    const PropertySpec(
      name: 'displayStringForOption',
      group: PropertyGroup.text,
      typeLabel: 'AutocompleteOptionToString<T>',
      description: '候補を文字にする関数。候補の一覧と、選んだときに欄に入る文字が変わる。既定は toString()',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('大文字', _upperCase, '(option) => option.toUpperCase()'),
          Choice('頭に「果物:」', _withLabel, "(option) => '果物: \$option'"),
        ],
      ),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'fieldViewBuilder',
      typeLabel: 'AutocompleteFieldViewBuilder',
      description: '入力欄を組み立てる関数。指定しないと Material の TextField を使う',
    ),
    ReferenceArg(
      name: 'optionsViewBuilder',
      typeLabel: 'AutocompleteOptionsViewBuilder<T>?',
      description: '候補の一覧を組み立てる関数。指定しないと Material の一覧を使う',
    ),
    ReferenceArg(
      name: 'onSelected',
      typeLabel: 'AutocompleteOnSelected<T>?',
      description: '候補を選んだときに呼ばれる',
    ),
    ReferenceArg(
      name: 'focusNode',
      typeLabel: 'FocusNode?',
      description: '入力欄のフォーカス。外から欄にフォーカスを移すときに使う。textEditingController と一緒に渡す',
    ),
    ReferenceArg(
      name: 'textEditingController',
      typeLabel: 'TextEditingController?',
      description: '入力欄の文字を外から読み書きするときに使う。focusNode と一緒に渡す',
    ),
  ],
  build: _build,
  codeName: 'Autocomplete<String>',
);

Iterable<String> _startsWith(TextEditingValue value) => value.text.isEmpty
    ? const []
    : _fruits.where((fruit) => fruit.startsWith(value.text));

Iterable<String> _contains(TextEditingValue value) => value.text.isEmpty
    ? const []
    : _fruits.where((fruit) => fruit.contains(value.text));

typedef _OptionToString = String Function(String option);

String _upperCase(String option) => option.toUpperCase();

String _withLabel(String option) => '果物: $option';

Widget _build(DemoArgs args) => SizedBox(
  // 入力欄は幅いっぱいに広がるので、カードの中で幅を決めておく
  width: 240,
  child: Autocomplete<String>(
    optionsBuilder:
        args.valueOf<_OptionsBuilder>('optionsBuilder') ?? _startsWith,
    displayStringForOption:
        args.valueOf<_OptionToString>('displayStringForOption') ??
        RawAutocomplete.defaultStringForOption,
    optionsMaxHeight: args.valueOf<double>('optionsMaxHeight') ?? 200,
    optionsViewOpenDirection:
        args.valueOf<OptionsViewOpenDirection>('optionsViewOpenDirection') ??
        OptionsViewOpenDirection.down,
    initialValue: args.valueOf<TextEditingValue>('initialValue'),
  ),
);

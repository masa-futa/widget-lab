import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

typedef _Validator = String? Function(int? value);

final formFieldEntry = WidgetEntry(
  id: 'formField',
  name: 'FormField',
  genreIds: const ['input'],
  summary: '自前の入力部品を、Form の検証・保存・リセットに参加させる',
  description:
      '値とエラーを持ち、builder に渡す FormFieldState から読み書きします。'
      'Form の下に置くと、Form の validate・save・reset で一緒に扱われます。'
      'ここでは星の数を選ぶ部品を FormField<int> で作ります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/FormField-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'initialValue',
      typeLabel: 'T?',
      description: '最初の値（星の数）',
      control: SliderControl(
        min: 0,
        max: 5,
        divisions: 5,
        initialValue: 3,
        resolve: (v) => v.round(),
        code: (v) => '${v.round()}',
      ),
    ),
    const PropertySpec(
      name: 'validator',
      typeLabel: 'FormFieldValidator<T>?',
      description: '値を調べ、エラーの文を返す（問題なければ null）。ここでは星が 0 ならエラー',
      control: FixedControl(
        value: _atLeastOne,
        source: "(value) => (value ?? 0) == 0 ? '星を 1 つ以上' : null",
      ),
    ),
    PropertySpec(
      name: 'autovalidateMode',
      typeLabel: 'AutovalidateMode?',
      description: 'いつ検証するか。always なら最初からエラーが出る。既定は disabled',
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          for (final value in AutovalidateMode.values)
            Choice(value.name, value, 'AutovalidateMode.${value.name}'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'enabled',
      typeLabel: 'bool',
      description: 'false にすると押せず、検証もしない',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
  ],
  build: _build,
  codeName: 'FormField<int>',
  codeArguments: const ['builder: (field) => Stars(field)'],
);

String? _atLeastOne(int? value) => (value ?? 0) == 0 ? '星を 1 つ以上' : null;

Widget _build(DemoArgs args) {
  final initialValue = args.valueOf<int>('initialValue');
  return FormField<int>(
    // FormField は最初の値を State に写して持つので、最初の値を変えたら作り直す
    key: ValueKey(initialValue),
    initialValue: initialValue,
    validator: args.valueOf<_Validator>('validator'),
    autovalidateMode: args.valueOf<AutovalidateMode>('autovalidateMode'),
    enabled: args.valueOf<bool>('enabled') ?? true,
    builder: (field) => _Stars(field: field),
  );
}

/// 星を 5 つ並べ、押した数を FormFieldState に入れる。エラーは下に出す。
class _Stars extends StatelessWidget {
  const _Stars({required this.field});

  final FormFieldState<int> field;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = field.value ?? 0;
    final enabled = field.widget.enabled;
    final errorText = field.errorText;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 1; i <= 5; i++)
              IconButton(
                onPressed: enabled ? () => field.didChange(i) : null,
                icon: Icon(i <= value ? Icons.star : Icons.star_border),
                color: Colors.amber.shade700,
              ),
          ],
        ),
        if (errorText != null)
          Text(
            errorText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
      ],
    );
  }
}

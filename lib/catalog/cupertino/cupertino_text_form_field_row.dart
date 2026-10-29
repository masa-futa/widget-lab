import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_text_field.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoTextFormFieldRowEntry = WidgetEntry(
  id: 'cupertinoTextFormFieldRow',
  name: 'CupertinoTextFormFieldRow',
  genreIds: const ['cupertino'],
  summary: 'フォームの 1 行に置く、見出しつきの入力欄',
  description:
      '左に見出し（prefix）、右に枠のない入力欄を並べた、iOS の設定画面のような 1 行です。'
      'FormField なので、Form の中に置くと validator でまとめて確かめられ、'
      '誤りがあれば行の下に出します。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoTextFormFieldRow-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'prefix',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '行の左に置く見出し',
      control: FixedControl(value: Text('名前'), source: "Text('名前')"),
    ),
    const PropertySpec(
      name: 'placeholder',
      group: PropertyGroup.content,
      typeLabel: 'String?',
      description: '中が空の間に薄く出す文字',
      control: TextControl(initialValue: '必須'),
    ),
    const PropertySpec(
      name: 'initialValue',
      group: PropertyGroup.content,
      typeLabel: 'String?',
      description: '最初に入っている文字',
      initiallyOn: false,
      control: TextControl(initialValue: '山田'),
    ),
    const PropertySpec(
      name: 'validator',
      group: PropertyGroup.behavior,
      typeLabel: 'FormFieldValidator<String>?',
      description: '入れた文字を確かめる。誤りの文を返すと、行の下に出す',
      control: FixedControl(
        value: _validate,
        source: "(value) => value == null || value.isEmpty ? '入力してください' : null",
      ),
    ),
    PropertySpec(
      name: 'autovalidateMode',
      group: PropertyGroup.behavior,
      typeLabel: 'AutovalidateMode',
      description:
          'いつ validator で確かめるか。既定の disabled は Form の validate を呼んだときだけ',
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          for (final mode in const [
            AutovalidateMode.disabled,
            AutovalidateMode.always,
            AutovalidateMode.onUserInteraction,
          ])
            Choice(mode.name, mode, 'AutovalidateMode.${mode.name}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'padding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry?',
      description: '行の内側の余白',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 32,
        divisions: 8,
        initialValue: 16,
        resolve: EdgeInsets.all,
        code: (v) => 'EdgeInsets.all($v)',
      ),
    ),
    textFieldTextStyleSpec(
      name: 'placeholderStyle',
      description: 'placeholder の文字の見た目。指定しないと薄い灰色',
    ),
    textFieldTextStyleSpec(
      name: 'style',
      description: '入れた文字の見た目。指定しないとテーマの文字の見た目',
    ),
    textFieldTextAlignSpec(),
    textFieldTextAlignVerticalSpec(),
    textFieldStrutStyleSpec(),
    textFieldTextDirectionSpec(),
    textFieldDecorationSpec(
      description: '入力欄の地に描く飾り。指定しないと枠も地の色もない。中の値を組み合わせて BoxDecoration を作る',
    ),
    textFieldObscureTextSpec(),
    textFieldObscuringCharacterSpec(),
    textFieldMaxLinesSpec(),
    textFieldMinLinesSpec(),
    textFieldMaxLengthSpec(),
    const PropertySpec(
      name: 'enabled',
      group: PropertyGroup.behavior,
      typeLabel: 'bool?',
      description: 'false なら入力できない',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    textFieldReadOnlySpec(),
    textFieldShowCursorSpec(),
    textFieldEnableInteractiveSelectionSpec(typeLabel: 'bool'),
    textFieldCursorColorSpec(),
    textFieldCursorWidthSpec(),
    textFieldCursorHeightSpec(),
  ],
  references: [
    ...textFieldReferences(const [
      'key',
      'controller',
      'focusNode',
      'keyboardType',
      'textCapitalization',
      'textInputAction',
      'autofocus',
      'toolbarOptions',
      'autocorrect',
      'smartDashesType',
      'smartQuotesType',
      'enableSuggestions',
    ]),
    const ReferenceArg(
      name: 'expands',
      typeLabel: 'bool',
      description: 'true なら親の高さいっぱいに広がる。フォームの行は高さが決まらないので、見本では使わない',
    ),
    ...textFieldReferences(const ['onChanged', 'onTap', 'onEditingComplete']),
    const ReferenceArg(
      name: 'onFieldSubmitted',
      typeLabel: 'ValueChanged<String>?',
      description: 'キーボードの確定キーを押したときに、入れた文字を渡して呼ばれる',
    ),
    const ReferenceArg(
      name: 'onSaved',
      typeLabel: 'FormFieldSetter<String>?',
      description: 'Form の save を呼んだときに、入れた文字を渡して呼ばれる',
    ),
    ...textFieldReferences(const [
      'inputFormatters',
      'keyboardAppearance',
      'scrollPadding',
      'selectionControls',
      'scrollPhysics',
      'autofillHints',
      'contextMenuBuilder',
      'spellCheckConfiguration',
      'selectionHeightStyle',
      'selectionWidthStyle',
      'restorationId',
    ]),
  ],
  build: _build,
  codeName: 'CupertinoTextFormFieldRow',
);

String? _validate(String? value) =>
    value == null || value.isEmpty ? '入力してください' : null;

Widget _build(DemoArgs args) {
  final initialValue = args.valueOf<String>('initialValue');
  final lines = TextFieldLines.of(args);
  return FittedBox(
    // 比較中の低いカードでもはみ出さないよう、高さが足りなければ縮める
    fit: BoxFit.scaleDown,
    child: SizedBox(
      width: 300,
      child: CupertinoTextFormFieldRow(
        // 最初の文字は FormField の State が作られたときだけ読まれるので、変えたら作り直す
        key: ValueKey(initialValue),
        prefix: args.valueOf<Widget>('prefix'),
        placeholder: args.valueOf<String>('placeholder'),
        initialValue: initialValue,
        validator: args.valueOf<FormFieldValidator<String>>('validator'),
        autovalidateMode:
            args.valueOf<AutovalidateMode>('autovalidateMode') ??
            AutovalidateMode.disabled,
        padding: args.valueOf<EdgeInsetsGeometry>('padding'),
        placeholderStyle:
            args.valueOf<TextStyle>('placeholderStyle') ??
            // CupertinoTextFormFieldRow の既定値
            const TextStyle(
              fontWeight: FontWeight.w400,
              color: CupertinoColors.placeholderText,
            ),
        style: args.valueOf<TextStyle>('style'),
        textAlign: args.valueOf<TextAlign>('textAlign') ?? TextAlign.start,
        textAlignVertical: args.valueOf<TextAlignVertical>('textAlignVertical'),
        strutStyle: args.valueOf<StrutStyle>('strutStyle'),
        textDirection: args.valueOf<TextDirection>('textDirection'),
        decoration: args.valueOf<BoxDecoration>('decoration'),
        obscureText: lines.obscureText,
        obscuringCharacter: args.valueOf<String>('obscuringCharacter') ?? '•',
        maxLines: lines.maxLines,
        minLines: lines.minLines,
        maxLength: args.valueOf<int>('maxLength'),
        enabled: args.valueOf<bool>('enabled'),
        readOnly: args.valueOf<bool>('readOnly') ?? false,
        showCursor: args.valueOf<bool>('showCursor'),
        enableInteractiveSelection:
            args.valueOf<bool>('enableInteractiveSelection') ?? true,
        cursorColor: args.valueOf<Color>('cursorColor'),
        cursorWidth: args.valueOf<double>('cursorWidth') ?? 2,
        cursorHeight: args.valueOf<double>('cursorHeight'),
      ),
    ),
  );
}

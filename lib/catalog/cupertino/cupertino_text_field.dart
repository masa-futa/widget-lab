import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// 既定値を読むための入力欄（private な既定の decoration などを直書きしないため）。
const _defaults = CupertinoTextField();

final cupertinoTextFieldEntry = WidgetEntry(
  id: 'cupertinoTextField',
  name: 'CupertinoTextField',
  genreIds: const ['cupertino'],
  summary: 'iOS の見た目の 1 行の文字の入力欄',
  description:
      '角の丸い枠のついた、iOS の見た目の入力欄です。中が空の間は placeholder を薄く出します。'
      '入れた文字を読むときは TextEditingController を controller に渡します。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoTextField-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'placeholder',
      group: PropertyGroup.content,
      typeLabel: 'String?',
      description: '中が空の間に薄く出す文字',
      control: TextControl(initialValue: 'メールアドレス'),
    ),
    textFieldTextStyleSpec(
      name: 'placeholderStyle',
      description: 'placeholder の文字の見た目。指定しないと薄い灰色',
    ),
    const PropertySpec(
      name: 'prefix',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '入力欄の左に置く Widget',
      initiallyOn: false,
      control: FixedControl(
        value: Padding(
          padding: EdgeInsetsDirectional.only(start: 8),
          child: Icon(CupertinoIcons.mail),
        ),
        source: 'Padding(padding: EdgeInsetsDirectional.only(start: 8), child: Icon(CupertinoIcons.mail))',
      ),
    ),
    PropertySpec(
      name: 'prefixMode',
      group: PropertyGroup.behavior,
      requires: 'prefix',
      typeLabel: 'OverlayVisibilityMode',
      description: 'prefix を、いつ出すか',
      initiallyOn: false,
      control: _visibilityControl(initialIndex: 1),
    ),
    const PropertySpec(
      name: 'suffix',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '入力欄の右に置く Widget',
      initiallyOn: false,
      control: FixedControl(
        value: Padding(
          padding: EdgeInsetsDirectional.only(end: 8),
          child: Icon(CupertinoIcons.check_mark_circled),
        ),
        source: 'Padding(padding: EdgeInsetsDirectional.only(end: 8), child: Icon(CupertinoIcons.check_mark_circled))',
      ),
    ),
    PropertySpec(
      name: 'suffixMode',
      group: PropertyGroup.behavior,
      requires: 'suffix',
      typeLabel: 'OverlayVisibilityMode',
      description: 'suffix を、いつ出すか',
      initiallyOn: false,
      control: _visibilityControl(initialIndex: 1),
    ),
    PropertySpec(
      name: 'clearButtonMode',
      group: PropertyGroup.behavior,
      typeLabel: 'OverlayVisibilityMode',
      description: '右に出す消すボタンを、いつ出すか。中が空のときは出ない',
      initiallyOn: false,
      control: _visibilityControl(initialIndex: 2),
    ),
    PropertySpec(
      name: 'crossAxisAlignment',
      group: PropertyGroup.layout,
      typeLabel: 'CrossAxisAlignment',
      description: 'prefix・suffix と文字の、縦の揃え方',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final alignment in const [
            CrossAxisAlignment.start,
            CrossAxisAlignment.center,
            CrossAxisAlignment.end,
          ])
            Choice(
              alignment.name,
              alignment,
              'CrossAxisAlignment.${alignment.name}',
            ),
        ],
      ),
    ),
    textFieldTextDirectionSpec(),
    textFieldObscureTextSpec(),
    textFieldObscuringCharacterSpec(),
    textFieldTextAlignSpec(),
    textFieldTextAlignVerticalSpec(),
    textFieldTextStyleSpec(
      name: 'style',
      description: '入れた文字の見た目。指定しないとテーマの文字の見た目',
    ),
    textFieldStrutStyleSpec(),
    PropertySpec(
      name: 'padding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry',
      description: '枠の内側の余白',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 6,
        initialValue: 12,
        resolve: EdgeInsets.all,
        code: (v) => 'EdgeInsets.all($v)',
      ),
    ),
    textFieldDecorationSpec(
      description: '入力欄の地に描く飾り。指定しないと角の丸い枠。中の値を組み合わせて BoxDecoration を作る',
    ),
    textFieldMaxLinesSpec(),
    textFieldMinLinesSpec(),
    const PropertySpec(
      name: 'expands',
      group: PropertyGroup.size,
      requires: 'maxLines',
      omitIf: _omitExpands,
      typeLabel: 'bool',
      description:
          'true なら親の高さいっぱいに広がる。maxLines を null にし、minLines を渡さないときだけ効く',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    textFieldMaxLengthSpec(),
    const PropertySpec(
      name: 'enabled',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: 'false なら入力できず、地が灰色になる',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    textFieldReadOnlySpec(),
    textFieldShowCursorSpec(),
    textFieldEnableInteractiveSelectionSpec(typeLabel: 'bool?'),
    textFieldCursorColorSpec(),
    textFieldCursorWidthSpec(),
    textFieldCursorHeightSpec(),
    textFieldCursorRadiusSpec(),
  ],
  references: textFieldReferences(const [
    'key',
    'groupId',
    'controller',
    'focusNode',
    'undoController',
    'clearButtonSemanticLabel',
    'keyboardType',
    'textInputAction',
    'textCapitalization',
    'toolbarOptions',
    'autofocus',
    'autocorrect',
    'smartDashesType',
    'smartQuotesType',
    'enableSuggestions',
    'maxLengthEnforcement',
    'onChanged',
    'onEditingComplete',
    'onSubmitted',
    'onTapOutside',
    'onTapUpOutside',
    'inputFormatters',
    'cursorOpacityAnimates',
    'selectionHeightStyle',
    'selectionWidthStyle',
    'keyboardAppearance',
    'scrollPadding',
    'dragStartBehavior',
    'selectAllOnFocus',
    'selectionControls',
    'onTap',
    'scrollController',
    'scrollPhysics',
    'autofillHints',
    'contentInsertionConfiguration',
    'clipBehavior',
    'restorationId',
    'scribbleEnabled',
    'stylusHandwritingEnabled',
    'enableIMEPersonalizedLearning',
    'enableInlinePrediction',
    'contextMenuBuilder',
    'spellCheckConfiguration',
    'magnifierConfiguration',
  ]),
  build: _build,
  codeName: 'CupertinoTextField',
);

ChoiceControl _visibilityControl({required int initialIndex}) => ChoiceControl(
  initialIndex: initialIndex,
  choices: [
    for (final mode in OverlayVisibilityMode.values)
      Choice(mode.name, mode, 'OverlayVisibilityMode.${mode.name}'),
  ],
);

/// expands は maxLines が null（制限なし）で、minLines を渡さないときだけ渡せる（SDK の assert）。
bool _omitExpands(Map<String, PropertySetting> settings) =>
    textFieldMaxLinesIn(settings) != null ||
    textFieldMinLinesWrittenIn(settings);

Widget _build(DemoArgs args) {
  final lines = TextFieldLines.of(args);
  final expands =
      lines.maxLines == null &&
      lines.minLines == null &&
      (args.valueOf<bool>('expands') ?? false);
  return SizedBox(
    width: 280,
    child: CupertinoTextField(
      placeholder: args.valueOf<String>('placeholder'),
      placeholderStyle:
          args.valueOf<TextStyle>('placeholderStyle') ??
          _defaults.placeholderStyle,
      prefix: args.valueOf<Widget>('prefix'),
      prefixMode:
          args.valueOf<OverlayVisibilityMode>('prefixMode') ??
          OverlayVisibilityMode.always,
      suffix: args.valueOf<Widget>('suffix'),
      suffixMode:
          args.valueOf<OverlayVisibilityMode>('suffixMode') ??
          OverlayVisibilityMode.always,
      clearButtonMode:
          args.valueOf<OverlayVisibilityMode>('clearButtonMode') ??
          OverlayVisibilityMode.never,
      crossAxisAlignment:
          args.valueOf<CrossAxisAlignment>('crossAxisAlignment') ??
          CrossAxisAlignment.center,
      textDirection: args.valueOf<TextDirection>('textDirection'),
      obscureText: lines.obscureText,
      obscuringCharacter: args.valueOf<String>('obscuringCharacter') ?? '•',
      textAlign: args.valueOf<TextAlign>('textAlign') ?? TextAlign.start,
      textAlignVertical: args.valueOf<TextAlignVertical>('textAlignVertical'),
      style: args.valueOf<TextStyle>('style'),
      strutStyle: args.valueOf<StrutStyle>('strutStyle'),
      padding:
          args.valueOf<EdgeInsetsGeometry>('padding') ??
          const EdgeInsets.all(7),
      decoration:
          args.valueOf<BoxDecoration>('decoration') ?? _defaults.decoration,
      maxLines: lines.maxLines,
      minLines: lines.minLines,
      expands: expands,
      maxLength: args.valueOf<int>('maxLength'),
      enabled: args.valueOf<bool>('enabled') ?? true,
      readOnly: args.valueOf<bool>('readOnly') ?? false,
      showCursor: args.valueOf<bool>('showCursor'),
      enableInteractiveSelection: args.valueOf<bool>(
        'enableInteractiveSelection',
      ),
      cursorColor: args.valueOf<Color>('cursorColor'),
      cursorWidth: args.valueOf<double>('cursorWidth') ?? 2,
      cursorHeight: args.valueOf<double>('cursorHeight'),
      cursorRadius:
          args.valueOf<Radius>('cursorRadius') ?? const Radius.circular(2),
    ),
  );
}

// ---------------------------------------------------------------------------
// 入力欄の収録（CupertinoTextField・CupertinoTextFormFieldRow・
// CupertinoSearchTextField・選ぶときのつまみの 2 件）でそろえるプロパティと補足。

const _textColors = [
  Choice(
    'activeBlue',
    CupertinoColors.activeBlue,
    'CupertinoColors.activeBlue',
  ),
  Choice('systemRed', CupertinoColors.systemRed, 'CupertinoColors.systemRed'),
  Choice(
    'systemGreen',
    CupertinoColors.systemGreen,
    'CupertinoColors.systemGreen',
  ),
];

/// 文字の見た目（style・placeholderStyle）。中の値を組み合わせて TextStyle を作る。
PropertySpec textFieldTextStyleSpec({
  required String name,
  required String description,
}) => PropertySpec(
  name: name,
  group: PropertyGroup.text,
  typeLabel: 'TextStyle?',
  description: '$description。中の値を組み合わせて TextStyle を作る',
  initiallyOn: false,
  control: NestedControl(
    typeName: 'TextStyle',
    children: [
      const PropertySpec(
        name: 'color',
        typeLabel: 'Color?',
        description: '文字の色',
        control: ColorControl(palette: _textColors),
      ),
      PropertySpec(
        name: 'fontSize',
        typeLabel: 'double?',
        description: '文字の大きさ',
        initiallyOn: false,
        control: SliderControl(
          min: 12,
          max: 28,
          divisions: 8,
          initialValue: 20,
          resolve: (v) => v,
          code: (v) => '$v',
        ),
      ),
      PropertySpec(
        name: 'fontWeight',
        typeLabel: 'FontWeight?',
        description: '文字の太さ',
        initiallyOn: false,
        control: ChoiceControl(
          initialIndex: 1,
          choices: [
            for (final (name, weight) in const [
              ('w300', FontWeight.w300),
              ('w700', FontWeight.w700),
            ])
              Choice(name, weight, 'FontWeight.$name'),
          ],
        ),
      ),
    ],
    build: (values) => TextStyle(
      color: values['color'] as Color?,
      fontSize: values['fontSize'] as double?,
      fontWeight: values['fontWeight'] as FontWeight?,
    ),
  ),
);

/// 入力欄の地の飾り。中の値を組み合わせて BoxDecoration を作る。
PropertySpec textFieldDecorationSpec({
  required String description,
  List<String> excludes = const [],
}) => PropertySpec(
  name: 'decoration',
  group: PropertyGroup.paint,
  excludes: excludes,
  typeLabel: 'BoxDecoration?',
  description: description,
  initiallyOn: false,
  control: NestedControl(
    typeName: 'BoxDecoration',
    children: [
      const PropertySpec(
        name: 'color',
        typeLabel: 'Color?',
        description: '飾りの地の色',
        control: ColorControl(
          palette: [
            Choice(
              'systemYellow',
              CupertinoColors.systemYellow,
              'CupertinoColors.systemYellow',
            ),
            Choice(
              'extraLightBackgroundGray',
              CupertinoColors.extraLightBackgroundGray,
              'CupertinoColors.extraLightBackgroundGray',
            ),
          ],
        ),
      ),
      PropertySpec(
        name: 'border',
        typeLabel: 'BoxBorder?',
        description: '入力欄のふちの線',
        initiallyOn: false,
        control: ChoiceControl(
          choices: [
            Choice(
              'まわり',
              Border.all(color: CupertinoColors.systemBlue, width: 2),
              'Border.all(color: CupertinoColors.systemBlue, width: 2)',
            ),
            const Choice(
              '下だけ',
              Border(bottom: BorderSide(color: CupertinoColors.systemGrey)),
              'Border(bottom: BorderSide(color: CupertinoColors.systemGrey))',
            ),
          ],
        ),
      ),
      PropertySpec(
        name: 'borderRadius',
        typeLabel: 'BorderRadiusGeometry?',
        description: '角の丸み',
        initiallyOn: false,
        control: SliderControl(
          min: 0,
          max: 20,
          divisions: 5,
          initialValue: 12,
          resolve: BorderRadius.circular,
          code: (v) => 'BorderRadius.circular($v)',
        ),
      ),
    ],
    build: (values) => BoxDecoration(
      color: values['color'] as Color?,
      border: values['border'] as BoxBorder?,
      borderRadius: values['borderRadius'] as BorderRadiusGeometry?,
    ),
  ),
);

PropertySpec textFieldTextDirectionSpec() => PropertySpec(
  name: 'textDirection',
  group: PropertyGroup.layout,
  typeLabel: 'TextDirection?',
  description: '文字を書く向き。rtl にすると右から並ぶ',
  initiallyOn: false,
  control: ChoiceControl(
    initialIndex: 1,
    choices: [
      for (final direction in TextDirection.values)
        Choice(direction.name, direction, 'TextDirection.${direction.name}'),
    ],
  ),
);

PropertySpec textFieldTextAlignSpec() => PropertySpec(
  name: 'textAlign',
  group: PropertyGroup.text,
  typeLabel: 'TextAlign',
  description: '入れた文字の横の寄せ方',
  initiallyOn: false,
  control: ChoiceControl(
    initialIndex: 1,
    choices: [
      for (final align in const [
        TextAlign.start,
        TextAlign.center,
        TextAlign.end,
      ])
        Choice(align.name, align, 'TextAlign.${align.name}'),
    ],
  ),
);

PropertySpec textFieldTextAlignVerticalSpec() => const PropertySpec(
  name: 'textAlignVertical',
  group: PropertyGroup.text,
  typeLabel: 'TextAlignVertical?',
  description: '入力欄が文字より高いときの、文字の縦の寄せ方',
  initiallyOn: false,
  control: ChoiceControl(
    initialIndex: 2,
    choices: [
      Choice('top', TextAlignVertical.top, 'TextAlignVertical.top'),
      Choice('center', TextAlignVertical.center, 'TextAlignVertical.center'),
      Choice('bottom', TextAlignVertical.bottom, 'TextAlignVertical.bottom'),
    ],
  ),
);

PropertySpec textFieldStrutStyleSpec() => const PropertySpec(
  name: 'strutStyle',
  group: PropertyGroup.text,
  typeLabel: 'StrutStyle?',
  description: '行の高さの下限。文字が小さくても行の高さをそろえる',
  initiallyOn: false,
  control: ChoiceControl(
    choices: [
      Choice(
        '行の高さ 2 倍',
        StrutStyle(height: 2, forceStrutHeight: true),
        'StrutStyle(height: 2, forceStrutHeight: true)',
      ),
    ],
  ),
);

PropertySpec textFieldObscureTextSpec() => const PropertySpec(
  name: 'obscureText',
  group: PropertyGroup.behavior,
  omitIf: _omitObscureText,
  typeLabel: 'bool',
  description: 'true なら入れた文字を • で隠す（パスワード向け）。maxLines が 1 のときだけ使える',
  initiallyOn: false,
  control: SwitchControl(initialValue: true),
);

/// obscureText を true にできるのは maxLines が 1 のときだけ（SDK の assert）。
bool _omitObscureText(Map<String, PropertySetting> settings) =>
    textFieldMaxLinesIn(settings) != 1;

PropertySpec textFieldObscuringCharacterSpec() => const PropertySpec(
  name: 'obscuringCharacter',
  group: PropertyGroup.text,
  requires: 'obscureText',
  typeLabel: 'String',
  description: '文字を隠すときに代わりに出す 1 文字',
  initiallyOn: false,
  control: ChoiceControl(
    choices: [Choice('*', '*', "'*'"), Choice('●', '●', "'●'")],
  ),
);

/// maxLines の選択肢。null（制限なし）は値を false にして、組み立てで null に読み替える。
const _maxLinesChoices = [
  Choice('1', 1, '1'),
  Choice('3', 3, '3'),
  Choice('null', false, 'null'),
];

PropertySpec textFieldMaxLinesSpec() => const PropertySpec(
  name: 'maxLines',
  group: PropertyGroup.size,
  pairsWith: ['minLines'],
  typeLabel: 'int?',
  description: '行の数の上限。null なら文字に合わせて高くなる',
  initiallyOn: false,
  control: ChoiceControl(initialIndex: 1, choices: _maxLinesChoices),
);

PropertySpec textFieldMinLinesSpec() => const PropertySpec(
  name: 'minLines',
  group: PropertyGroup.size,
  pairsWith: ['maxLines'],
  requires: 'maxLines',
  omitIf: _omitMinLines,
  typeLabel: 'int?',
  description: '空でも確保する行の数。maxLines より大きくはできない',
  initiallyOn: false,
  control: ChoiceControl(choices: _minLinesChoices),
);

const _minLinesChoices = [Choice('2', 2, '2'), Choice('3', 3, '3')];

/// minLines は maxLines を ON にし、その値以下のときだけ渡す（SDK の assert）。
bool _omitMinLines(Map<String, PropertySetting> settings) =>
    !textFieldMinLinesWrittenIn(settings);

/// [settings] での maxLines の値。OFF なら既定の 1、null（制限なし）なら `null`。
int? textFieldMaxLinesIn(Map<String, PropertySetting> settings) {
  final setting = settings['maxLines'];
  if (setting == null || !setting.on) return 1;
  final value = setting.value;
  if (value is! ChoiceValue) return 1;
  final choice = _maxLinesChoices[value.index].value;
  return choice is int ? choice : null;
}

/// [settings] で minLines を渡すか。
bool textFieldMinLinesWrittenIn(Map<String, PropertySetting> settings) {
  final setting = settings['minLines'];
  final maxLinesOn = settings['maxLines']?.on ?? false;
  if (setting == null || !setting.on || !maxLinesOn) return false;
  final value = setting.value;
  if (value is! ChoiceValue) return false;
  final minLines = _minLinesChoices[value.index].value as int;
  final maxLines = textFieldMaxLinesIn(settings);
  return maxLines == null || minLines <= maxLines;
}

/// maxLines・minLines・obscureText を、SDK の assert を守る組み合わせにした値。
/// omitIf（[textFieldMaxLinesIn]・[textFieldMinLinesWrittenIn]）と同じ条件を、組み立てで守る。
final class TextFieldLines {
  const TextFieldLines._({
    required this.maxLines,
    required this.minLines,
    required this.obscureText,
  });

  factory TextFieldLines.of(DemoArgs args) {
    final maxLinesValue = args.valueOf<Object>('maxLines');
    final maxLines = switch (maxLinesValue) {
      null => 1,
      final int lines => lines,
      _ => null,
    };
    final minLinesValue = maxLinesValue == null
        ? null
        : args.valueOf<int>('minLines');
    final minLines =
        minLinesValue != null && (maxLines == null || minLinesValue <= maxLines)
        ? minLinesValue
        : null;
    return TextFieldLines._(
      maxLines: maxLines,
      minLines: minLines,
      obscureText:
          maxLines == 1 && (args.valueOf<bool>('obscureText') ?? false),
    );
  }

  final int? maxLines;
  final int? minLines;
  final bool obscureText;
}

PropertySpec textFieldMaxLengthSpec() => PropertySpec(
  name: 'maxLength',
  group: PropertyGroup.behavior,
  typeLabel: 'int?',
  description: '入れられる文字の数の上限',
  initiallyOn: false,
  control: SliderControl(
    min: 1,
    max: 20,
    divisions: 19,
    initialValue: 5,
    resolve: (v) => v.toInt(),
    code: (v) => '${v.toInt()}',
  ),
);

PropertySpec textFieldReadOnlySpec() => const PropertySpec(
  name: 'readOnly',
  group: PropertyGroup.behavior,
  pairsWith: ['showCursor'],
  typeLabel: 'bool',
  description: 'true なら文字を選べるが書き換えられない。カーソルも出なくなる',
  initiallyOn: false,
  control: SwitchControl(initialValue: true),
);

PropertySpec textFieldShowCursorSpec() => const PropertySpec(
  name: 'showCursor',
  group: PropertyGroup.behavior,
  pairsWith: ['readOnly'],
  typeLabel: 'bool?',
  description: 'カーソルを出すか。指定しないと readOnly のときだけ出さない',
  initiallyOn: false,
  control: SwitchControl(initialValue: false),
);

PropertySpec textFieldEnableInteractiveSelectionSpec({
  required String typeLabel,
}) => PropertySpec(
  name: 'enableInteractiveSelection',
  group: PropertyGroup.behavior,
  typeLabel: typeLabel,
  description: 'false なら長押しやダブルタップで文字を選べず、メニューも出ない',
  initiallyOn: false,
  control: const SwitchControl(initialValue: false),
);

PropertySpec textFieldCursorColorSpec() => const PropertySpec(
  name: 'cursorColor',
  group: PropertyGroup.paint,
  typeLabel: 'Color?',
  description: 'カーソルの色。指定しないとテーマの primaryColor',
  initiallyOn: false,
  control: ColorControl(palette: _textColors, initialIndex: 1),
);

PropertySpec textFieldCursorWidthSpec() => PropertySpec(
  name: 'cursorWidth',
  group: PropertyGroup.paint,
  typeLabel: 'double',
  description: 'カーソルの幅',
  initiallyOn: false,
  control: SliderControl(
    min: 1,
    max: 8,
    divisions: 7,
    initialValue: 4,
    resolve: (v) => v,
    code: (v) => '$v',
  ),
);

PropertySpec textFieldCursorHeightSpec() => PropertySpec(
  name: 'cursorHeight',
  group: PropertyGroup.paint,
  typeLabel: 'double?',
  description: 'カーソルの高さ。指定しないと文字の高さ',
  initiallyOn: false,
  control: SliderControl(
    min: 8,
    max: 32,
    divisions: 6,
    initialValue: 28,
    resolve: (v) => v,
    code: (v) => '$v',
  ),
);

PropertySpec textFieldCursorRadiusSpec() => PropertySpec(
  name: 'cursorRadius',
  group: PropertyGroup.paint,
  typeLabel: 'Radius',
  description: 'カーソルの角の丸み',
  initiallyOn: false,
  control: SliderControl(
    min: 0,
    max: 4,
    divisions: 4,
    initialValue: 0,
    resolve: Radius.circular,
    code: (v) => 'Radius.circular($v)',
  ),
);

/// 入力欄の収録でそろえる補足の説明（名前で引く）。
const _textFieldReferenceArgs = [
  ReferenceArg(
    name: 'key',
    typeLabel: 'Key?',
    description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
  ),
  ReferenceArg(
    name: 'groupId',
    typeLabel: 'Object',
    description: '外をタップしたときに、同じ組の入力欄の上ならフォーカスを外さないための組の印',
  ),
  ReferenceArg(
    name: 'controller',
    typeLabel: 'TextEditingController?',
    description: '入れた文字を読み書きするもの。最初の文字もこれで入れる',
  ),
  ReferenceArg(
    name: 'focusNode',
    typeLabel: 'FocusNode?',
    description: 'フォーカスを外から動かしたり、フォーカスの有無を知ったりするためのもの',
  ),
  ReferenceArg(
    name: 'undoController',
    typeLabel: 'UndoHistoryController?',
    description: '取り消し・やり直しの履歴を外から操作するもの',
  ),
  ReferenceArg(
    name: 'clearButtonSemanticLabel',
    typeLabel: 'String?',
    description: '消すボタンを読み上げるときの名前',
  ),
  ReferenceArg(
    name: 'keyboardType',
    typeLabel: 'TextInputType?',
    description: '出すキーボードの種類（数字・メールアドレスなど）',
  ),
  ReferenceArg(
    name: 'textInputAction',
    typeLabel: 'TextInputAction?',
    description: 'キーボードの確定キーの種類（完了・次へ・検索など）',
  ),
  ReferenceArg(
    name: 'textCapitalization',
    typeLabel: 'TextCapitalization',
    description: '英字を打つときに、キーボードが大文字にする範囲（文の頭・語の頭など）',
  ),
  ReferenceArg(
    name: 'toolbarOptions',
    typeLabel: 'ToolbarOptions?',
    description: '文字を選んだときのメニューに出す項目（非推奨。contextMenuBuilder を使う）',
  ),
  ReferenceArg(
    name: 'autofocus',
    typeLabel: 'bool',
    description: 'true なら画面を開いたときにフォーカスを当て、キーボードを出す',
  ),
  ReferenceArg(
    name: 'autocorrect',
    typeLabel: 'bool',
    description: 'キーボードの自動修正を使うか',
  ),
  ReferenceArg(
    name: 'smartDashesType',
    typeLabel: 'SmartDashesType?',
    description: 'キーボードが - を続けて打ったときにダッシュに変えるか',
  ),
  ReferenceArg(
    name: 'smartQuotesType',
    typeLabel: 'SmartQuotesType?',
    description: 'キーボードが引用符を向きのある引用符に変えるか',
  ),
  ReferenceArg(
    name: 'enableSuggestions',
    typeLabel: 'bool',
    description: 'キーボードに入力の候補を出すか',
  ),
  ReferenceArg(
    name: 'maxLengthEnforcement',
    typeLabel: 'MaxLengthEnforcement?',
    description: 'maxLength を超える入力を、変換中の文字も含めてどう止めるか',
  ),
  ReferenceArg(
    name: 'onChanged',
    typeLabel: 'ValueChanged<String>?',
    description: '文字が変わるたびに呼ばれる',
  ),
  ReferenceArg(
    name: 'onEditingComplete',
    typeLabel: 'VoidCallback?',
    description: 'キーボードの確定キーを押して、入力を終えたときに呼ばれる',
  ),
  ReferenceArg(
    name: 'onSubmitted',
    typeLabel: 'ValueChanged<String>?',
    description: 'キーボードの確定キーを押したときに、入れた文字を渡して呼ばれる',
  ),
  ReferenceArg(
    name: 'onTapOutside',
    typeLabel: 'TapRegionCallback?',
    description: '入力欄の外を押したときに呼ばれる。指定しないとフォーカスを外す',
  ),
  ReferenceArg(
    name: 'onTapUpOutside',
    typeLabel: 'TapRegionUpCallback?',
    description: '入力欄の外で指を離したときに呼ばれる',
  ),
  ReferenceArg(
    name: 'inputFormatters',
    typeLabel: 'List<TextInputFormatter>?',
    description: '入れた文字を確定する前に整えるもの（数字だけにする、など）',
  ),
  ReferenceArg(
    name: 'cursorOpacityAnimates',
    typeLabel: 'bool',
    description: 'カーソルの点滅を、ふわっと消えるアニメーションにするか',
  ),
  ReferenceArg(
    name: 'selectionHeightStyle',
    typeLabel: 'BoxHeightStyle?',
    description: '文字を選んだときに塗る範囲の高さの決め方',
  ),
  ReferenceArg(
    name: 'selectionWidthStyle',
    typeLabel: 'BoxWidthStyle?',
    description: '文字を選んだときに塗る範囲の幅の決め方',
  ),
  ReferenceArg(
    name: 'keyboardAppearance',
    typeLabel: 'Brightness?',
    description: 'iOS のキーボードを明るい色と暗い色のどちらで出すか',
  ),
  ReferenceArg(
    name: 'scrollPadding',
    typeLabel: 'EdgeInsets',
    description: 'フォーカスを当てたときに、画面をスクロールして入力欄のまわりに空ける余白',
  ),
  ReferenceArg(
    name: 'dragStartBehavior',
    typeLabel: 'DragStartBehavior',
    description: '文字の上でドラッグを始めたと見なす時点',
  ),
  ReferenceArg(
    name: 'selectAllOnFocus',
    typeLabel: 'bool?',
    description: 'フォーカスを当てたときに文字を全部選ぶか',
  ),
  ReferenceArg(
    name: 'selectionControls',
    typeLabel: 'TextSelectionControls?',
    description:
        '文字を選んだときのつまみとメニューを描くもの。CupertinoTextSelectionControls の収録で比べられる',
  ),
  ReferenceArg(
    name: 'onTap',
    typeLabel: 'GestureTapCallback?',
    description: '入力欄を押したときに呼ばれる',
  ),
  ReferenceArg(
    name: 'scrollController',
    typeLabel: 'ScrollController?',
    description: '入力欄の中のスクロールの位置を読み書きするもの',
  ),
  ReferenceArg(
    name: 'scrollPhysics',
    typeLabel: 'ScrollPhysics?',
    description: '入力欄の中をスクロールするときの動き方',
  ),
  ReferenceArg(
    name: 'autofillHints',
    typeLabel: 'Iterable<String>?',
    description: '自動入力に使う種類（メールアドレス・パスワードなど）',
  ),
  ReferenceArg(
    name: 'contentInsertionConfiguration',
    typeLabel: 'ContentInsertionConfiguration?',
    description: 'キーボードから画像などを差し込んだときの受け取り方',
  ),
  ReferenceArg(
    name: 'clipBehavior',
    typeLabel: 'Clip',
    description: '入力欄からはみ出した文字を切り抜く方法',
  ),
  ReferenceArg(
    name: 'restorationId',
    typeLabel: 'String?',
    description: 'アプリを作り直したときに、入れた文字を戻すための ID',
  ),
  ReferenceArg(
    name: 'scribbleEnabled',
    typeLabel: 'bool',
    description: 'iPad の手書き入力を受け付けるか（非推奨。stylusHandwritingEnabled を使う）',
  ),
  ReferenceArg(
    name: 'stylusHandwritingEnabled',
    typeLabel: 'bool',
    description: 'ペンでの手書き入力を受け付けるか',
  ),
  ReferenceArg(
    name: 'enableIMEPersonalizedLearning',
    typeLabel: 'bool',
    description: 'キーボードが入力を覚えて、候補に使ってよいか',
  ),
  ReferenceArg(
    name: 'enableInlinePrediction',
    typeLabel: 'bool?',
    description: 'iOS のキーボードの、入力欄の中に続きを薄く出す予測を使うか',
  ),
  ReferenceArg(
    name: 'contextMenuBuilder',
    typeLabel: 'EditableTextContextMenuBuilder?',
    description: '文字を選んだときのメニューを作る関数',
  ),
  ReferenceArg(
    name: 'spellCheckConfiguration',
    typeLabel: 'SpellCheckConfiguration?',
    description: 'つづりの確かめと、直す候補の出し方',
  ),
  ReferenceArg(
    name: 'magnifierConfiguration',
    typeLabel: 'TextMagnifierConfiguration?',
    description: '文字を選ぶときに出す虫めがねの作り方',
  ),
];

/// [names] の順に、入力欄の収録でそろえる補足を返す。
List<ReferenceArg> textFieldReferences(List<String> names) => [
  for (final name in names)
    _textFieldReferenceArgs.firstWhere((reference) => reference.name == name),
];

/// CupertinoTextField の引数のうち [except] 以外を、全部補足にして返す。
/// 選ぶときのつまみの収録（codeName が CupertinoTextField）で、入力欄そのものの引数を載せる。
List<ReferenceArg> textFieldArgsAsReferences({required Set<String> except}) => [
  for (final reference in _textFieldReferenceArgs)
    if (!except.contains(reference.name)) reference,
  for (final spec in cupertinoTextFieldEntry.properties)
    if (!except.contains(spec.name))
      ReferenceArg(
        name: spec.name,
        typeLabel: spec.typeLabel,
        description: spec.description,
      ),
];

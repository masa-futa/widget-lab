import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_scope.dart';
import 'package:widget_lab/catalog/demo/semantics_readout.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final semanticsEntry = WidgetEntry(
  id: 'semantics',
  name: 'Semantics',
  genreIds: const ['accessibility'],
  summary: '子に読み上げの名前や役割を付ける',
  description:
      'VoiceOver・TalkBack が読む名前（label）や役割（button など）を子に付けます。'
      '見た目は変わりません。文字のないアイコンだけのボタンは、付けないと何と読めばよいか伝わりません。'
      'プレビューの下に、読み上げの木を書き出します。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/Semantics-class.html',
  ),
  kind: EntryKind.behavior,
  properties: [
    const PropertySpec(
      name: 'label',
      group: PropertyGroup.content,
      typeLabel: 'String?',
      description: '読み上げる名前',
      control: TextControl(initialValue: '保存'),
    ),
    const PropertySpec(
      name: 'value',
      group: PropertyGroup.content,
      typeLabel: 'String?',
      description: '今の値。名前のあとに読む（例: 音量の「50%」）',
      initiallyOn: false,
      control: TextControl(initialValue: '未保存の変更あり'),
    ),
    const PropertySpec(
      name: 'hint',
      group: PropertyGroup.content,
      typeLabel: 'String?',
      description: '押すと何が起きるかの説明。名前のあとに読む',
      initiallyOn: false,
      control: TextControl(initialValue: '書いた内容を保存します'),
    ),
    const PropertySpec(
      name: 'button',
      group: PropertyGroup.behavior,
      typeLabel: 'bool?',
      description: 'ボタンとして読む（「ボタン」と添えて読む）',
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'header',
      group: PropertyGroup.behavior,
      typeLabel: 'bool?',
      description: '見出しとして読む（「見出し」と添えて読む）',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'image',
      group: PropertyGroup.behavior,
      typeLabel: 'bool?',
      description: '画像として読む（「画像」と添えて読む）',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'checked',
      group: PropertyGroup.behavior,
      excludes: ['mixed', 'toggled'],
      typeLabel: 'bool?',
      description: 'チェックボックスとして、チェックの有無を読む',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'mixed',
      group: PropertyGroup.behavior,
      excludes: const ['checked', 'toggled'],
      omitIf: (settings) => _isOn(settings, 'checked'),
      typeLabel: 'bool?',
      description: '3 状態のチェックボックスとして、一部だけチェックの状態を読む',
      initiallyOn: false,
      control: const SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'toggled',
      group: PropertyGroup.behavior,
      excludes: const ['checked', 'mixed'],
      omitIf: (settings) =>
          _isOn(settings, 'checked') || _isOn(settings, 'mixed'),
      typeLabel: 'bool?',
      description: 'スイッチとして、オン・オフを読む',
      initiallyOn: false,
      control: const SwitchControl(initialValue: true),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'child',
      typeLabel: 'Widget?',
      description: '読み上げの情報を付ける子。ここでは文字のない保存のアイコン（コードでは const SaveIcon()）',
    ),
    ReferenceArg(
      name: 'container',
      typeLabel: 'bool',
      description: 'true にすると、親のノードにまとめず、自分のノードを作る',
    ),
    ReferenceArg(
      name: 'explicitChildNodes',
      typeLabel: 'bool',
      description: '子孫の情報を自分のノードにまとめず、別々のノードのままにするか',
    ),
    ReferenceArg(
      name: 'excludeSemantics',
      typeLabel: 'bool',
      description: 'true にすると、子孫の読み上げの情報を外し、このノードの情報だけを残す',
    ),
    ReferenceArg(
      name: 'blockUserActions',
      typeLabel: 'bool',
      description: 'true にすると、読み上げからの操作（タップなど）を受け付けない',
    ),
    ReferenceArg(
      name: 'enabled',
      typeLabel: 'bool?',
      description: '使えるかどうか。false なら「使用不可」と読む端末がある',
    ),
    ReferenceArg(
      name: 'selected',
      typeLabel: 'bool?',
      description: '選ばれているか（タブの今のページなど）',
    ),
    ReferenceArg(
      name: 'slider',
      typeLabel: 'bool?',
      description: 'スライダーとして読む。onIncrease・onDecrease と組で使う',
    ),
    ReferenceArg(
      name: 'keyboardKey',
      typeLabel: 'bool?',
      description: 'キーボードのキーとして読む',
    ),
    ReferenceArg(name: 'link', typeLabel: 'bool?', description: 'リンクとして読む'),
    ReferenceArg(
      name: 'linkUrl',
      typeLabel: 'Uri?',
      description: 'リンク先の URL。Web で a 要素の href になる',
    ),
    ReferenceArg(
      name: 'headingLevel',
      typeLabel: 'int?',
      description: '見出しの段（1〜6）。Web の h1〜h6 になる。header と組で使う',
    ),
    ReferenceArg(
      name: 'textField',
      typeLabel: 'bool?',
      description: '文字の入力欄として読む',
    ),
    ReferenceArg(
      name: 'readOnly',
      typeLabel: 'bool?',
      description: '入力欄が読むだけで書けないか',
    ),
    ReferenceArg(
      name: 'focusable',
      typeLabel: 'bool?',
      description: 'キーボードなどでフォーカスを当てられるか',
    ),
    ReferenceArg(
      name: 'focused',
      typeLabel: 'bool?',
      description: '今フォーカスが当たっているか',
    ),
    ReferenceArg(
      name: 'accessibilityFocusBlockType',
      typeLabel: 'AccessibilityFocusBlockType?',
      description: '読み上げのフォーカスを、このノードやその子孫に当てさせないか',
    ),
    ReferenceArg(
      name: 'inMutuallyExclusiveGroup',
      typeLabel: 'bool?',
      description: 'ラジオボタンのように、1 つだけ選べる組の中にあるか',
    ),
    ReferenceArg(
      name: 'obscured',
      typeLabel: 'bool?',
      description: 'パスワードのように、値を伏せて読むか',
    ),
    ReferenceArg(
      name: 'multiline',
      typeLabel: 'bool?',
      description: '入力欄が複数行か',
    ),
    ReferenceArg(
      name: 'scopesRoute',
      typeLabel: 'bool?',
      description: '画面（ルート）の区切りになるノードか。namesRoute と組で使う',
    ),
    ReferenceArg(
      name: 'namesRoute',
      typeLabel: 'bool?',
      description: 'このノードの label を、画面の名前として読むか',
    ),
    ReferenceArg(
      name: 'hidden',
      typeLabel: 'bool?',
      description: '画面の外にあって見えていないか',
    ),
    ReferenceArg(
      name: 'liveRegion',
      typeLabel: 'bool?',
      description: '中身が変わったら、自動で読み上げるか（知らせの帯など）',
    ),
    ReferenceArg(
      name: 'expanded',
      typeLabel: 'bool?',
      description: '開いているか（メニュー・折りたたみなど）',
    ),
    ReferenceArg(
      name: 'isRequired',
      typeLabel: 'bool?',
      description: '入力が必須の項目か',
    ),
    ReferenceArg(
      name: 'maxValueLength',
      typeLabel: 'int?',
      description: '入力欄に書ける文字数の上限',
    ),
    ReferenceArg(
      name: 'currentValueLength',
      typeLabel: 'int?',
      description: '入力欄に今書いてある文字数',
    ),
    ReferenceArg(
      name: 'identifier',
      typeLabel: 'String?',
      description: 'テストの自動化などで使う、ノードの識別子。読み上げない',
    ),
    ReferenceArg(
      name: 'traversalParentIdentifier',
      typeLabel: 'Object?',
      description: '読む順を組み替えるときの、親の識別子',
    ),
    ReferenceArg(
      name: 'traversalChildIdentifier',
      typeLabel: 'Object?',
      description: '読む順を組み替えるときの、子の識別子',
    ),
    ReferenceArg(
      name: 'attributedLabel',
      typeLabel: 'AttributedString?',
      description: '言語や読み方の指定を付けた label。label と同時には渡せない',
    ),
    ReferenceArg(
      name: 'attributedValue',
      typeLabel: 'AttributedString?',
      description: '言語や読み方の指定を付けた value。value と同時には渡せない',
    ),
    ReferenceArg(
      name: 'increasedValue',
      typeLabel: 'String?',
      description: 'onIncrease を行ったあとの値',
    ),
    ReferenceArg(
      name: 'attributedIncreasedValue',
      typeLabel: 'AttributedString?',
      description: '言語や読み方の指定を付けた increasedValue',
    ),
    ReferenceArg(
      name: 'decreasedValue',
      typeLabel: 'String?',
      description: 'onDecrease を行ったあとの値',
    ),
    ReferenceArg(
      name: 'attributedDecreasedValue',
      typeLabel: 'AttributedString?',
      description: '言語や読み方の指定を付けた decreasedValue',
    ),
    ReferenceArg(
      name: 'attributedHint',
      typeLabel: 'AttributedString?',
      description: '言語や読み方の指定を付けた hint。hint と同時には渡せない',
    ),
    ReferenceArg(
      name: 'tooltip',
      typeLabel: 'String?',
      description: 'ツールチップの文。label とは別に読む',
    ),
    ReferenceArg(
      name: 'onTapHint',
      typeLabel: 'String?',
      description: 'タップの操作の説明（Android の「ダブルタップして…」の部分）',
    ),
    ReferenceArg(
      name: 'onLongPressHint',
      typeLabel: 'String?',
      description: '長押しの操作の説明',
    ),
    ReferenceArg(
      name: 'textDirection',
      typeLabel: 'TextDirection?',
      description: 'label・value・hint の文字の向き',
    ),
    ReferenceArg(
      name: 'sortKey',
      typeLabel: 'SemanticsSortKey?',
      description: '兄弟の中で読む順を決める鍵',
    ),
    ReferenceArg(
      name: 'tagForChildren',
      typeLabel: 'SemanticsTag?',
      description: '子のノードに付ける印。親のレンダーオブジェクトが見分けるのに使う',
    ),
    ReferenceArg(
      name: 'onTap',
      typeLabel: 'VoidCallback?',
      description: '読み上げからタップされたときに呼ぶ',
    ),
    ReferenceArg(
      name: 'onLongPress',
      typeLabel: 'VoidCallback?',
      description: '読み上げから長押しされたときに呼ぶ',
    ),
    ReferenceArg(
      name: 'onScrollLeft',
      typeLabel: 'VoidCallback?',
      description: '読み上げから左にスクロールされたときに呼ぶ',
    ),
    ReferenceArg(
      name: 'onScrollRight',
      typeLabel: 'VoidCallback?',
      description: '読み上げから右にスクロールされたときに呼ぶ',
    ),
    ReferenceArg(
      name: 'onScrollUp',
      typeLabel: 'VoidCallback?',
      description: '読み上げから上にスクロールされたときに呼ぶ',
    ),
    ReferenceArg(
      name: 'onScrollDown',
      typeLabel: 'VoidCallback?',
      description: '読み上げから下にスクロールされたときに呼ぶ',
    ),
    ReferenceArg(
      name: 'onIncrease',
      typeLabel: 'VoidCallback?',
      description: '読み上げから値を上げられたときに呼ぶ',
    ),
    ReferenceArg(
      name: 'onDecrease',
      typeLabel: 'VoidCallback?',
      description: '読み上げから値を下げられたときに呼ぶ',
    ),
    ReferenceArg(
      name: 'onCopy',
      typeLabel: 'VoidCallback?',
      description: '読み上げからコピーされたときに呼ぶ',
    ),
    ReferenceArg(
      name: 'onCut',
      typeLabel: 'VoidCallback?',
      description: '読み上げから切り取られたときに呼ぶ',
    ),
    ReferenceArg(
      name: 'onPaste',
      typeLabel: 'VoidCallback?',
      description: '読み上げから貼り付けられたときに呼ぶ',
    ),
    ReferenceArg(
      name: 'onDismiss',
      typeLabel: 'VoidCallback?',
      description: '読み上げから閉じられたときに呼ぶ',
    ),
    ReferenceArg(
      name: 'onMoveCursorForwardByCharacter',
      typeLabel: 'MoveCursorHandler?',
      description: '読み上げからカーソルを 1 文字進められたときに呼ぶ',
    ),
    ReferenceArg(
      name: 'onMoveCursorBackwardByCharacter',
      typeLabel: 'MoveCursorHandler?',
      description: '読み上げからカーソルを 1 文字戻されたときに呼ぶ',
    ),
    ReferenceArg(
      name: 'onSetSelection',
      typeLabel: 'SetSelectionHandler?',
      description: '読み上げから選択の範囲を変えられたときに呼ぶ',
    ),
    ReferenceArg(
      name: 'onSetText',
      typeLabel: 'SetTextHandler?',
      description: '読み上げから文字を書き換えられたときに呼ぶ',
    ),
    ReferenceArg(
      name: 'onDidGainAccessibilityFocus',
      typeLabel: 'VoidCallback?',
      description: '読み上げのフォーカスが当たったときに呼ぶ',
    ),
    ReferenceArg(
      name: 'onDidLoseAccessibilityFocus',
      typeLabel: 'VoidCallback?',
      description: '読み上げのフォーカスが外れたときに呼ぶ',
    ),
    ReferenceArg(
      name: 'onFocus',
      typeLabel: 'VoidCallback?',
      description: '読み上げからフォーカスを当てる操作をされたときに呼ぶ',
    ),
    ReferenceArg(
      name: 'onExpand',
      typeLabel: 'VoidCallback?',
      description: '読み上げから開く操作をされたときに呼ぶ',
    ),
    ReferenceArg(
      name: 'onCollapse',
      typeLabel: 'VoidCallback?',
      description: '読み上げから閉じる操作をされたときに呼ぶ',
    ),
    ReferenceArg(
      name: 'customSemanticsActions',
      typeLabel: 'Map<CustomSemanticsAction, VoidCallback>?',
      description: '独自の操作（「削除」など）と、そのときに呼ぶ関数',
    ),
    ReferenceArg(
      name: 'role',
      typeLabel: 'SemanticsRole?',
      description: 'ノードの役割（表・タブ・ダイアログなど）。主に Web の ARIA の role になる',
    ),
    ReferenceArg(
      name: 'controlsNodes',
      typeLabel: 'Set<String>?',
      description: 'このノードが操作する、ほかのノードの identifier',
    ),
    ReferenceArg(
      name: 'validationResult',
      typeLabel: 'SemanticsValidationResult',
      description: '入力の検証の結果（正しい・誤り）。指定しないと none',
    ),
    ReferenceArg(
      name: 'hitTestBehavior',
      typeLabel: 'SemanticsHitTestBehavior?',
      description: '読み上げのタップを、このノードがどう受けるか',
    ),
    ReferenceArg(
      name: 'inputType',
      typeLabel: 'SemanticsInputType?',
      description: '入力欄の種類（メール・電話番号など）',
    ),
    ReferenceArg(
      name: 'localeForSubtree',
      typeLabel: 'Locale?',
      description: '子孫の読み上げに使う言語',
    ),
    ReferenceArg(
      name: 'minValue',
      typeLabel: 'String?',
      description: '値の最小（スライダーなど）',
    ),
    ReferenceArg(
      name: 'maxValue',
      typeLabel: 'String?',
      description: '値の最大（スライダーなど）',
    ),
  ],
  build: _build,
  buildWithout: _buildWithout,
  codeName: 'Semantics',
  codeArguments: const ['child: const SaveIcon()'],
);

bool _isOn(Map<String, PropertySetting> settings, String name) =>
    settings[name]?.on ?? false;

Widget _build(DemoArgs args) {
  final label = args.valueOf<String>('label');
  final value = args.valueOf<String>('value');
  final hint = args.valueOf<String>('hint');
  final button = args.valueOf<bool>('button');
  final header = args.valueOf<bool>('header');
  final image = args.valueOf<bool>('image');
  // checked・mixed・toggled は同時に使えない。両方 ON のときは omitIf と同じ順で前のものを使う
  final checked = args.valueOf<bool>('checked');
  final mixed = checked == null ? args.valueOf<bool>('mixed') : null;
  final toggled = checked == null && mixed == null
      ? args.valueOf<bool>('toggled')
      : null;
  final values = [
    if (label != null) 'label: $label',
    if (value != null) 'value: $value',
    if (hint != null) 'hint: $hint',
    if (button != null) 'button: $button',
    if (header != null) 'header: $header',
    if (image != null) 'image: $image',
    if (checked != null) 'checked: $checked',
    if (mixed != null) 'mixed: $mixed',
    if (toggled != null) 'toggled: $toggled',
  ];
  return DemoFit(
    child: SemanticsReadout(
      label: 'Semantics(${values.join(', ')})',
      child: Semantics(
        label: label,
        value: value,
        hint: hint,
        button: button,
        header: header,
        image: image,
        checked: checked,
        mixed: mixed,
        toggled: toggled,
        child: const _SaveIcon(),
      ),
    ),
  );
}

/// 包みを外す。アイコンには文字がないので、読み上げには何も出ない。
Widget _buildWithout(DemoArgs args) =>
    const DemoFit(child: SemanticsReadout(child: _SaveIcon()));

/// 文字のない、押せるアイコン（デモの部品。コードでは `const SaveIcon()`）。
class _SaveIcon extends StatelessWidget {
  const _SaveIcon();

  @override
  Widget build(BuildContext context) => Center(
    child: GestureDetector(
      onTap: () {},
      child: const Icon(Icons.save_outlined, size: 32),
    ),
  );
}

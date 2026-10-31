import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// maxLines の選択肢で null（上限なし）を表す印。Choice の値は null にできないので 0 で表す。
const _noLimit = 0;

final textFieldEntry = WidgetEntry(
  id: 'textField',
  name: 'TextField',
  genreIds: const ['material'],
  summary: 'キーボードで文字を入れる欄',
  description:
      'キーボードで文字を入れる欄です。見出し・ヒント・枠などの見た目は decoration（InputDecoration）で決めます。'
      '入れた文字は controller か onChanged で受け取ります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/TextField-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'decoration',
      group: PropertyGroup.paint,
      typeLabel: 'InputDecoration?',
      description: '欄の見た目。指定しないと下線だけ。null を渡すと飾りなし',
      control: ChoiceControl(
        choices: [
          Choice(
            '見出し',
            InputDecoration(labelText: '名前'),
            "InputDecoration(labelText: '名前')",
          ),
          Choice(
            '枠つき',
            InputDecoration(border: OutlineInputBorder(), labelText: '名前'),
            "InputDecoration(border: OutlineInputBorder(), labelText: '名前')",
          ),
          Choice(
            'ヒント',
            InputDecoration(hintText: '山田 太郎', prefixIcon: Icon(Icons.person)),
            "InputDecoration(hintText: '山田 太郎', prefixIcon: Icon(Icons.person))",
          ),
          Choice(
            '誤り',
            InputDecoration(labelText: '名前', errorText: '入力してください'),
            "InputDecoration(labelText: '名前', errorText: '入力してください')",
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'enabled',
      group: PropertyGroup.behavior,
      typeLabel: 'bool?',
      description: '入力できるか。false だと薄い見た目になり、押してもキーボードが出ない',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'obscureText',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description:
          '入れた文字を ● で隠すか（パスワード用）。文字を入れると違いが見える。'
          '隠すときは 1 行だけなので、maxLines が 1 でない間は渡さない',
      initiallyOn: false,
      omitIf: (settings) =>
          _isTrue(settings['obscureText']) && _maxLinesOf(settings) != 1,
      control: const SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'obscuringCharacter',
      group: PropertyGroup.text,
      requires: 'obscureText',
      typeLabel: 'String',
      description: 'obscureText で隠すときに、文字の代わりに出す 1 文字。指定しないと •',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('*', '*', "'*'"),
          Choice('●', '●', "'●'"),
          Choice('×', '×', "'×'"),
        ],
      ),
    ),
    PropertySpec(
      name: 'maxLength',
      group: PropertyGroup.behavior,
      typeLabel: 'int?',
      description: '入れられる文字数の上限。指定すると右下に「0/10」のような数が出る',
      initiallyOn: false,
      control: SliderControl(
        min: 5,
        max: 30,
        divisions: 5,
        initialValue: 10,
        resolve: (v) => v.round(),
        code: (v) => '${v.round()}',
      ),
    ),
    PropertySpec(
      name: 'maxLengthEnforcement',
      group: PropertyGroup.behavior,
      requires: 'maxLength',
      typeLabel: 'MaxLengthEnforcement?',
      description: 'maxLength を超えて入れようとしたときの扱い。none にすると超えて入れられ、数が赤くなる',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final value in MaxLengthEnforcement.values)
            Choice(value.name, value, 'MaxLengthEnforcement.${value.name}'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'buildCounter',
      group: PropertyGroup.content,
      typeLabel: 'InputCounterWidgetBuilder?',
      description: '欄の右下に出す数の Widget を作る。指定しないと maxLength があるときだけ「0/10」を出す',
      initiallyOn: false,
      control: FixedControl(
        value: _counter,
        source:
            '(context, {required currentLength, required isFocused, required maxLength}) '
            "=> Text('\$currentLength 文字')",
      ),
    ),
    PropertySpec(
      name: 'textAlign',
      group: PropertyGroup.text,
      typeLabel: 'TextAlign',
      description: '欄の中での文字の横の揃え方',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 2,
        choices: [
          for (final value in const [
            TextAlign.left,
            TextAlign.right,
            TextAlign.center,
            TextAlign.start,
            TextAlign.end,
          ])
            Choice(value.name, value, 'TextAlign.${value.name}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'style',
      group: PropertyGroup.text,
      typeLabel: 'TextStyle?',
      description: '入れた文字の書式。中の値を組み合わせて TextStyle を作る。指定しないとテーマの bodyLarge',
      initiallyOn: false,
      control: NestedControl(
        typeName: 'TextStyle',
        children: [
          PropertySpec(
            name: 'color',
            typeLabel: 'Color?',
            description: '文字の色',
            control: ColorControl(
              palette: [
                Choice.color('瑠璃', const Color(0xFF1E50A2)),
                Choice.color('紅', const Color(0xFFD7003A)),
              ],
            ),
          ),
          PropertySpec(
            name: 'fontSize',
            typeLabel: 'double?',
            description: '文字の大きさ',
            initiallyOn: false,
            control: SliderControl(
              min: 12,
              max: 24,
              divisions: 6,
              initialValue: 20,
              resolve: (v) => v,
              code: (v) => '$v',
            ),
          ),
          const PropertySpec(
            name: 'fontWeight',
            typeLabel: 'FontWeight?',
            description: '文字の太さ',
            initiallyOn: false,
            control: ChoiceControl(
              choices: [
                Choice('太字', FontWeight.bold, 'FontWeight.bold'),
                Choice('細字', FontWeight.w300, 'FontWeight.w300'),
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
    ),
    const PropertySpec(
      name: 'strutStyle',
      group: PropertyGroup.text,
      typeLabel: 'StrutStyle?',
      description: '行の高さの最低限。forceStrutHeight にすると、文字の大きさにかかわらず行の高さをそろえる',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '行を高く',
            StrutStyle(height: 1.8, forceStrutHeight: true),
            'StrutStyle(height: 1.8, forceStrutHeight: true)',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'maxLines',
      group: PropertyGroup.text,
      typeLabel: 'int?',
      description: '欄の行数の上限。null にすると上限なしで、入れた分だけ伸びる。指定しないと 1',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          for (final (label, value, code) in const [
            ('1', 1, '1'),
            ('3', 3, '3'),
            ('null（上限なし）', _noLimit, 'null'),
          ])
            Choice(label, value, code),
        ],
      ),
    ),
    PropertySpec(
      name: 'minLines',
      group: PropertyGroup.text,
      requires: 'maxLines',
      excludes: const ['expands'],
      typeLabel: 'int?',
      description:
          '欄の行数の最低限。文字が少なくてもこの行数の高さになる。'
          'maxLines より大きくできないので、超える間は渡さない',
      initiallyOn: false,
      omitIf: _omitMinLines,
      control: SliderControl(
        min: 1,
        max: 3,
        divisions: 2,
        initialValue: 2,
        resolve: (v) => v.round(),
        code: (v) => '${v.round()}',
      ),
    ),
    PropertySpec(
      name: 'expands',
      group: PropertyGroup.size,
      requires: 'maxLines',
      excludes: const ['minLines'],
      typeLabel: 'bool',
      description:
          '欄の高さを親いっぱいに広げるか。maxLines と minLines が null のときだけ使えるので、'
          'maxLines が null でない間は渡さない。指定しないと false',
      initiallyOn: false,
      omitIf: (settings) => _maxLinesOf(settings) != null,
      control: const SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'textAlignVertical',
      group: PropertyGroup.layout,
      typeLabel: 'TextAlignVertical?',
      description: '欄の中での文字の縦の位置。欄が文字より高いとき（expands など）に違いが見える。指定しないと上',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final (name, value) in const [
            ('top', TextAlignVertical.top),
            ('center', TextAlignVertical.center),
            ('bottom', TextAlignVertical.bottom),
          ])
            Choice(name, value, 'TextAlignVertical.$name'),
        ],
      ),
    ),
    PropertySpec(
      name: 'textDirection',
      group: PropertyGroup.layout,
      typeLabel: 'TextDirection?',
      description: '文字を書く向き。rtl にすると右から書き、start の揃えも右になる。指定しないとまわりの向き',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final value in TextDirection.values)
            Choice(value.name, value, 'TextDirection.${value.name}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'keyboardType',
      group: PropertyGroup.behavior,
      typeLabel: 'TextInputType?',
      description:
          '出すキーボードの種類（数字・メールなど）。指定しないと maxLines が 1 なら text、それ以外は multiline',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          for (final (name, value) in const [
            ('text', TextInputType.text),
            ('number', TextInputType.number),
            ('emailAddress', TextInputType.emailAddress),
            ('phone', TextInputType.phone),
            ('url', TextInputType.url),
          ])
            Choice(name, value, 'TextInputType.$name'),
        ],
      ),
    ),
    PropertySpec(
      name: 'textInputAction',
      group: PropertyGroup.behavior,
      typeLabel: 'TextInputAction?',
      description: 'キーボードの決定キーの種類（完了・検索・次へなど）。指定しないと端末に任せる',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final value in const [
            TextInputAction.done,
            TextInputAction.search,
            TextInputAction.next,
            TextInputAction.send,
          ])
            Choice(value.name, value, 'TextInputAction.${value.name}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'textCapitalization',
      group: PropertyGroup.behavior,
      typeLabel: 'TextCapitalization',
      description: '英字を入れるとき、キーボードを自動で大文字にする場所。指定しないと none（自動では大文字にしない）',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final value in const [
            TextCapitalization.words,
            TextCapitalization.sentences,
            TextCapitalization.characters,
          ])
            Choice(value.name, value, 'TextCapitalization.${value.name}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'keyboardAppearance',
      group: PropertyGroup.behavior,
      typeLabel: 'Brightness?',
      description: 'キーボードの明るさ。iOS だけで効く。指定しないとテーマの明るさ',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final value in Brightness.values)
            Choice(value.name, value, 'Brightness.${value.name}'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'autocorrect',
      group: PropertyGroup.behavior,
      typeLabel: 'bool?',
      description: '入れた文字を自動で直すか。指定しないと true',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    const PropertySpec(
      name: 'enableSuggestions',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: 'キーボードに入力の候補を出すか。指定しないと true',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'inputFormatters',
      group: PropertyGroup.behavior,
      typeLabel: 'List<TextInputFormatter>?',
      description: '入れた文字を、欄に入る前に絞り込む・整える。ここでは数字だけを通す',
      initiallyOn: false,
      control: FixedControl(
        value: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
        source: '[FilteringTextInputFormatter.digitsOnly]',
      ),
    ),
    const PropertySpec(
      name: 'readOnly',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description:
          '文字を変えられないようにするか。enabled と違い、見た目は薄くならず、選んでコピーはできる。指定しないと false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'ignorePointers',
      group: PropertyGroup.behavior,
      typeLabel: 'bool?',
      description: 'true にすると、押しても反応しない（見た目は変わらない）。指定しないと反応する',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'canRequestFocus',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: 'false にすると、押してもフォーカスが来ず、キーボードが出ない。指定しないと true',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    const PropertySpec(
      name: 'enableInteractiveSelection',
      group: PropertyGroup.behavior,
      typeLabel: 'bool?',
      description: '長押しで文字を選んだり、コピー・貼り付けしたりできるか。指定しないと、readOnly かつ obscureText のときだけ false',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    const PropertySpec(
      name: 'selectAllOnFocus',
      group: PropertyGroup.behavior,
      typeLabel: 'bool?',
      description: 'フォーカスが来たとき、入っている文字を全部選ぶか。指定しないとスマホでは false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'showCursor',
      group: PropertyGroup.paint,
      typeLabel: 'bool?',
      description: 'フォーカスがあるときに、点滅する縦線（カーソル）を出すか。指定しないと readOnly でなければ出す',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'cursorWidth',
      group: PropertyGroup.paint,
      typeLabel: 'double',
      description: 'カーソルの太さ。指定しないと 2',
      initiallyOn: false,
      control: SliderControl(
        min: 1,
        max: 6,
        divisions: 5,
        initialValue: 4,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'cursorHeight',
      group: PropertyGroup.paint,
      typeLabel: 'double?',
      description: 'カーソルの高さ。指定しないと文字の高さ',
      initiallyOn: false,
      control: SliderControl(
        min: 8,
        max: 32,
        divisions: 6,
        initialValue: 24,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'cursorRadius',
      group: PropertyGroup.paint,
      typeLabel: 'Radius?',
      description: 'カーソルの角の丸み。cursorWidth を太くすると見える。指定しないと角は丸まらない（iOS では丸まる）',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 3,
        divisions: 3,
        initialValue: 2,
        resolve: Radius.circular,
        code: (v) => 'Radius.circular($v)',
      ),
    ),
    PropertySpec(
      name: 'cursorColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'カーソルの色。指定しないとテーマの primary',
      initiallyOn: false,
      control: _colorControl(),
    ),
    PropertySpec(
      name: 'cursorErrorColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'decoration で誤り（errorText）を出している間のカーソルの色。指定しないとテーマの error',
      initiallyOn: false,
      control: _colorControl(),
    ),
    const PropertySpec(
      name: 'cursorOpacityAnimates',
      group: PropertyGroup.paint,
      typeLabel: 'bool?',
      description:
          'カーソルの点滅を、ふわっと薄くなる動きにするか。指定しないと iOS では true、Android では false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'clipBehavior',
      group: PropertyGroup.transform,
      typeLabel: 'Clip',
      description:
          '欄からはみ出した文字を切り抜くか。none にすると、長い文字が欄の外にも描かれる。指定しないと Clip.hardEdge',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final clip in const [Clip.none, Clip.antiAlias])
            Choice(clip.name, clip, 'Clip.${clip.name}'),
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
      name: 'groupId',
      typeLabel: 'Object',
      description: '欄の外を押したとき（onTapOutside）に、同じ仲間として扱う欄の印',
    ),
    ReferenceArg(
      name: 'controller',
      typeLabel: 'TextEditingController?',
      description: '入っている文字を外から読み書きするときに渡す',
    ),
    ReferenceArg(
      name: 'focusNode',
      typeLabel: 'FocusNode?',
      description: 'フォーカスを外から操作・監視するときに渡す',
    ),
    ReferenceArg(
      name: 'undoController',
      typeLabel: 'UndoHistoryController?',
      description: '元に戻す・やり直すを外から操作するときに渡す',
    ),
    ReferenceArg(
      name: 'toolbarOptions',
      typeLabel: 'ToolbarOptions?',
      description: '非推奨。contextMenuBuilder を使う',
    ),
    ReferenceArg(
      name: 'autofocus',
      typeLabel: 'bool',
      description: '画面を開いたときに、最初からフォーカスを持ってキーボードを出すか。指定しないと false',
    ),
    ReferenceArg(
      name: 'statesController',
      typeLabel: 'WidgetStatesController?',
      description: 'フォーカス・誤りなどの状態を、外から読み書きするときに渡す',
    ),
    ReferenceArg(
      name: 'smartDashesType',
      typeLabel: 'SmartDashesType?',
      description: '「--」を「—」に変えるか。iOS だけで効く。指定しないと obscureText でなければ変える',
    ),
    ReferenceArg(
      name: 'smartQuotesType',
      typeLabel: 'SmartQuotesType?',
      description: '「"」を向きのある引用符に変えるか。iOS だけで効く。指定しないと obscureText でなければ変える',
    ),
    ReferenceArg(
      name: 'onChanged',
      typeLabel: 'ValueChanged<String>?',
      description: '文字が変わるたびに、新しい文字で呼ばれる',
    ),
    ReferenceArg(
      name: 'onEditingComplete',
      typeLabel: 'VoidCallback?',
      description: 'キーボードの決定キーを押したときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onSubmitted',
      typeLabel: 'ValueChanged<String>?',
      description: 'キーボードの決定キーを押したときに、入っている文字で呼ばれる',
    ),
    ReferenceArg(
      name: 'onAppPrivateCommand',
      typeLabel: 'AppPrivateCommandCallback?',
      description: 'Android の入力方式（IME）から独自の命令が届いたときに呼ばれる',
    ),
    ReferenceArg(
      name: 'selectionHeightStyle',
      typeLabel: 'BoxHeightStyle?',
      description: '文字を選んだときに塗る範囲の高さの決め方。見本の 1 行の文字ではほとんど違いが出ない',
    ),
    ReferenceArg(
      name: 'selectionWidthStyle',
      typeLabel: 'BoxWidthStyle?',
      description: '文字を選んだときに塗る範囲の幅の決め方。複数行を選んだときの行末で違いが出る',
    ),
    ReferenceArg(
      name: 'scrollPadding',
      typeLabel: 'EdgeInsets',
      description: 'スクロールの中でフォーカスが来たとき、欄のまわりにこの分の空きを見せるまでスクロールする。指定しないと 20',
    ),
    ReferenceArg(
      name: 'dragStartBehavior',
      typeLabel: 'DragStartBehavior',
      description: 'ドラッグを、指が動き始めた位置と触れた位置のどちらから始めるか',
    ),
    ReferenceArg(
      name: 'selectionControls',
      typeLabel: 'TextSelectionControls?',
      description: '文字を選んだときの持ち手とメニューを、自分で作るときに渡す',
    ),
    ReferenceArg(
      name: 'onTap',
      typeLabel: 'GestureTapCallback?',
      description: '欄を押したときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onTapAlwaysCalled',
      typeLabel: 'bool',
      description: 'true にすると、続けて押したとき（2 回押しなど）も毎回 onTap を呼ぶ。指定しないと false',
    ),
    ReferenceArg(
      name: 'onTapOutside',
      typeLabel: 'TapRegionCallback?',
      description: 'フォーカスがあるときに、欄の外を押し始めたら呼ばれる',
    ),
    ReferenceArg(
      name: 'onTapUpOutside',
      typeLabel: 'TapRegionUpCallback?',
      description: 'フォーカスがあるときに、欄の外で指を離したら呼ばれる',
    ),
    ReferenceArg(
      name: 'mouseCursor',
      typeLabel: 'MouseCursor?',
      description: 'マウスを乗せたときのポインタの形。タッチの端末では違いが出ない',
    ),
    ReferenceArg(
      name: 'scrollController',
      typeLabel: 'ScrollController?',
      description: '欄の中のスクロールの位置を、外から読み書きするときに渡す',
    ),
    ReferenceArg(
      name: 'scrollPhysics',
      typeLabel: 'ScrollPhysics?',
      description: '欄の中をスクロールするときの動き方。文字が欄に収まらないときだけ違いが出る',
    ),
    ReferenceArg(
      name: 'autofillHints',
      typeLabel: 'Iterable<String>?',
      description: '自動入力（パスワード・住所など）に、何を入れる欄かを知らせる',
    ),
    ReferenceArg(
      name: 'contentInsertionConfiguration',
      typeLabel: 'ContentInsertionConfiguration?',
      description: 'キーボードから画像・ステッカーなどを入れられるようにするときに渡す',
    ),
    ReferenceArg(
      name: 'restorationId',
      typeLabel: 'String?',
      description: 'アプリが OS に止められて戻ったときに、入っていた文字を戻すための名前',
    ),
    ReferenceArg(
      name: 'scribbleEnabled',
      typeLabel: 'bool',
      description: '非推奨。stylusHandwritingEnabled を使う',
    ),
    ReferenceArg(
      name: 'stylusHandwritingEnabled',
      typeLabel: 'bool',
      description: 'スタイラスペンの手書きで文字を入れられるか（iPad の Scribble など）。指定しないと true',
    ),
    ReferenceArg(
      name: 'enableIMEPersonalizedLearning',
      typeLabel: 'bool',
      description: '入力方式（IME）に、入れた文字を覚えさせてよいか。Android だけで効く。指定しないと true',
    ),
    ReferenceArg(
      name: 'enableInlinePrediction',
      typeLabel: 'bool?',
      description: '続きの予測を、欄の中に薄い文字で出すか。iOS だけで効く',
    ),
    ReferenceArg(
      name: 'contextMenuBuilder',
      typeLabel: 'EditableTextContextMenuBuilder?',
      description: '長押しで出るメニュー（コピー・貼り付けなど）を作る。null にするとメニューを出さない',
    ),
    ReferenceArg(
      name: 'spellCheckConfiguration',
      typeLabel: 'SpellCheckConfiguration?',
      description: 'つづりの誤りに印を付けるときの設定。端末のつづり確認の機能を使う',
    ),
    ReferenceArg(
      name: 'magnifierConfiguration',
      typeLabel: 'TextMagnifierConfiguration?',
      description: '文字を選ぶときに出る拡大鏡の設定',
    ),
    ReferenceArg(
      name: 'hintLocales',
      typeLabel: 'List<Locale>?',
      description: 'キーボードに、どの言語で入れるかを知らせる',
    ),
  ],
  build: _build,
  codeName: 'TextField',
);

ColorControl _colorControl() => ColorControl(
  palette: [
    Choice.color('紅', const Color(0xFFD7003A)),
    Choice.color('若竹', const Color(0xFF68BE8D)),
  ],
);

Widget? _counter(
  BuildContext context, {
  required int currentLength,
  required bool isFocused,
  required int? maxLength,
}) => Text('$currentLength 文字');

bool _isTrue(PropertySetting? setting) =>
    setting != null &&
    setting.on &&
    setting.value is SwitchValue &&
    (setting.value as SwitchValue).value;

/// maxLines の選択肢の値。OFF なら Flutter の既定値の 1、null は上限なし。
int? _maxLinesOf(Map<String, PropertySetting> settings) {
  final setting = settings['maxLines'];
  if (setting == null || !setting.on) return 1;
  final value = setting.value;
  if (value is! ChoiceValue) return 1;
  return switch (value.index) {
    0 => 1,
    1 => 3,
    _ => null,
  };
}

/// expands を渡すか（ON で true、かつ maxLines が null）。
bool _expandsIn(Map<String, PropertySetting> settings) =>
    _isTrue(settings['expands']) && _maxLinesOf(settings) == null;

/// minLines を渡さない条件。expands と同時には使えず、maxLines を超えられない。
bool _omitMinLines(Map<String, PropertySetting> settings) {
  if (_expandsIn(settings)) return true;
  final maxLines = _maxLinesOf(settings);
  final value = settings['minLines']?.value;
  final minLines = value is SliderValue ? value.value.round() : 1;
  return maxLines != null && minLines > maxLines;
}

Widget _build(DemoArgs args) {
  // omitIf の条件を、ここでも手で守る（DemoArgs はトップレベルの omitIf を見ない）。
  final rawMaxLines = args.valueOf<int>('maxLines');
  final maxLines = rawMaxLines == null
      ? 1
      : (rawMaxLines == _noLimit ? null : rawMaxLines);
  final expands = maxLines == null && (args.valueOf<bool>('expands') ?? false);
  final rawMinLines = args.valueOf<int>('minLines');
  final minLines =
      expands ||
          rawMinLines == null ||
          (maxLines != null && rawMinLines > maxLines)
      ? null
      : rawMinLines;
  final obscureText =
      maxLines == 1 && (args.valueOf<bool>('obscureText') ?? false);
  return TextField(
    decoration:
        args.valueOf<InputDecoration>('decoration') ?? const InputDecoration(),
    enabled: args.valueOf<bool>('enabled'),
    obscureText: obscureText,
    // Flutter の既定値（•）。OFF のときも省いたコードと同じ挙動にそろえる。
    obscuringCharacter: args.valueOf<String>('obscuringCharacter') ?? '•',
    maxLength: args.valueOf<int>('maxLength'),
    maxLengthEnforcement: args.valueOf<MaxLengthEnforcement>(
      'maxLengthEnforcement',
    ),
    buildCounter: args.valueOf<InputCounterWidgetBuilder>('buildCounter'),
    textAlign: args.valueOf<TextAlign>('textAlign') ?? TextAlign.start,
    style: args.valueOf<TextStyle>('style'),
    strutStyle: args.valueOf<StrutStyle>('strutStyle'),
    maxLines: maxLines,
    minLines: minLines,
    expands: expands,
    textAlignVertical: args.valueOf<TextAlignVertical>('textAlignVertical'),
    textDirection: args.valueOf<TextDirection>('textDirection'),
    keyboardType: args.valueOf<TextInputType>('keyboardType'),
    textInputAction: args.valueOf<TextInputAction>('textInputAction'),
    textCapitalization:
        args.valueOf<TextCapitalization>('textCapitalization') ??
        TextCapitalization.none,
    keyboardAppearance: args.valueOf<Brightness>('keyboardAppearance'),
    autocorrect: args.valueOf<bool>('autocorrect'),
    enableSuggestions: args.valueOf<bool>('enableSuggestions') ?? true,
    inputFormatters: args.valueOf<List<TextInputFormatter>>('inputFormatters'),
    readOnly: args.valueOf<bool>('readOnly') ?? false,
    ignorePointers: args.valueOf<bool>('ignorePointers'),
    canRequestFocus: args.valueOf<bool>('canRequestFocus') ?? true,
    enableInteractiveSelection: args.valueOf<bool>(
      'enableInteractiveSelection',
    ),
    selectAllOnFocus: args.valueOf<bool>('selectAllOnFocus'),
    showCursor: args.valueOf<bool>('showCursor'),
    cursorWidth: args.valueOf<double>('cursorWidth') ?? 2,
    cursorHeight: args.valueOf<double>('cursorHeight'),
    cursorRadius: args.valueOf<Radius>('cursorRadius'),
    cursorColor: args.valueOf<Color>('cursorColor'),
    cursorErrorColor: args.valueOf<Color>('cursorErrorColor'),
    cursorOpacityAnimates: args.valueOf<bool>('cursorOpacityAnimates'),
    clipBehavior: args.valueOf<Clip>('clipBehavior') ?? Clip.hardEdge,
  );
}

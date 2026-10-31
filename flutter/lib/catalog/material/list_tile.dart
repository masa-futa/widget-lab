import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final listTileEntry = WidgetEntry(
  id: 'listTile',
  name: 'ListTile',
  genreIds: const ['material'],
  summary: '一覧の 1 行。左のアイコン・題・説明・右の印を並べる',
  description:
      '一覧の 1 行の決まった形です。左に leading、中に title と subtitle、右に trailing を並べます。'
      'onTap を渡すと押せる行になり、押したときに波紋が出ます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/ListTile-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'leading',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '題の左に置く Widget。ふつうは Icon か CircleAvatar',
      control: FixedControl(
        value: Icon(Icons.person),
        source: 'Icon(Icons.person)',
      ),
    ),
    const PropertySpec(
      name: 'title',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '行の題',
      control: FixedControl(value: Text('山田 花子'), source: "Text('山田 花子')"),
    ),
    const PropertySpec(
      name: 'subtitle',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '題の下の説明',
      initiallyOn: false,
      control: FixedControl(
        value: Text('明日の打ち合わせについて'),
        source: "Text('明日の打ち合わせについて')",
      ),
    ),
    const PropertySpec(
      name: 'trailing',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '題の右に置く Widget',
      initiallyOn: false,
      control: FixedControl(
        value: Icon(Icons.chevron_right),
        source: 'Icon(Icons.chevron_right)',
      ),
    ),
    PropertySpec(
      name: 'isThreeLine',
      group: PropertyGroup.layout,
      requires: 'subtitle',
      omitIf: (settings) => !(settings['subtitle']?.on ?? false),
      typeLabel: 'bool?',
      description: '3 行ぶんの高さの行にするか。subtitle がないと使えない。指定しないと false',
      initiallyOn: false,
      control: const SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'onTap',
      group: PropertyGroup.behavior,
      typeLabel: 'GestureTapCallback?',
      description: '行を押したときに呼ばれる。指定すると押したときに波紋が出る',
      control: FixedControl(value: _noop, source: '() {}'),
    ),
    const PropertySpec(
      name: 'selected',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: '選んでいる行か。true だとアイコンと文字がテーマの primary の色になる。指定しないと false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'enabled',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: '押せる行か。false だと文字が薄い色になり、押しても反応しない。指定しないと true',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    const PropertySpec(
      name: 'dense',
      group: PropertyGroup.size,
      typeLabel: 'bool?',
      description: '詰めた一覧の行にするか。true だと行が低く、文字が小さくなる',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'visualDensity',
      group: PropertyGroup.size,
      typeLabel: 'VisualDensity?',
      description: '行の詰まり具合。compact で低く、指定しないとテーマの値',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('compact', VisualDensity.compact, 'VisualDensity.compact'),
          Choice(
            'comfortable',
            VisualDensity.comfortable,
            'VisualDensity.comfortable',
          ),
          Choice('standard', VisualDensity.standard, 'VisualDensity.standard'),
        ],
      ),
    ),
    PropertySpec(
      name: 'minTileHeight',
      group: PropertyGroup.size,
      typeLabel: 'double?',
      description: '行の高さの下限。指定しないと 1 行で 56、2 行で 72、3 行で 88',
      initiallyOn: false,
      control: SliderControl(
        min: 32,
        max: 96,
        divisions: 8,
        initialValue: 80,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'minLeadingWidth',
      group: PropertyGroup.size,
      requires: 'leading',
      typeLabel: 'double?',
      description: 'leading に取る幅の下限。指定しないと 24（Material 3）',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 64,
        divisions: 8,
        initialValue: 56,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'contentPadding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry?',
      description: '行の内側の余白。指定しないと左 16・右 24',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 6,
        initialValue: 8,
        resolve: (v) => EdgeInsets.symmetric(horizontal: v),
        code: (v) => 'EdgeInsets.symmetric(horizontal: $v)',
      ),
    ),
    PropertySpec(
      name: 'horizontalTitleGap',
      group: PropertyGroup.spacing,
      typeLabel: 'double?',
      description: '題と leading・trailing のあいだの横の間隔。指定しないと 16',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 6,
        initialValue: 4,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'minVerticalPadding',
      group: PropertyGroup.spacing,
      typeLabel: 'double?',
      description: '題と説明の上下の余白の下限。指定しないと 4（Material 3 では 8）',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 6,
        initialValue: 16,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'titleAlignment',
      group: PropertyGroup.layout,
      typeLabel: 'ListTileTitleAlignment?',
      description: 'leading・trailing を題に対して縦のどこに置くか。指定しないと threeLine',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final value in ListTileTitleAlignment.values)
            Choice(value.name, value, 'ListTileTitleAlignment.${value.name}'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'shape',
      group: PropertyGroup.paint,
      typeLabel: 'ShapeBorder?',
      description: '行の形。地の色と波紋がこの形に切り抜かれる。指定しないと四角',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '角丸の枠',
            RoundedRectangleBorder(
              side: BorderSide(),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            'RoundedRectangleBorder(side: BorderSide(), '
                'borderRadius: BorderRadius.all(Radius.circular(12)))',
          ),
          Choice(
            '丸い端',
            StadiumBorder(side: BorderSide()),
            'StadiumBorder(side: BorderSide())',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'tileColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '選んでいないときの行の地の色。指定しないと透明',
      initiallyOn: false,
      control: _colorControl(),
    ),
    PropertySpec(
      name: 'selectedTileColor',
      group: PropertyGroup.paint,
      requires: 'selected',
      typeLabel: 'Color?',
      description: '選んでいるときの行の地の色。指定しないと透明',
      initiallyOn: false,
      control: _colorControl(),
    ),
    PropertySpec(
      name: 'iconColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'leading・trailing のアイコンの色。指定しないとテーマの onSurfaceVariant',
      initiallyOn: false,
      control: _colorControl(),
    ),
    PropertySpec(
      name: 'textColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '題・説明などの文字の色。指定しないとテーマの文字の色',
      initiallyOn: false,
      control: _colorControl(),
    ),
    PropertySpec(
      name: 'selectedColor',
      group: PropertyGroup.paint,
      requires: 'selected',
      typeLabel: 'Color?',
      description: '選んでいるときのアイコンと文字の色。指定しないとテーマの primary',
      initiallyOn: false,
      control: _colorControl(),
    ),
    PropertySpec(
      name: 'splashColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '押したときに広がる波紋の色',
      initiallyOn: false,
      control: _colorControl(),
    ),
    PropertySpec(
      name: 'titleTextStyle',
      group: PropertyGroup.text,
      requires: 'title',
      typeLabel: 'TextStyle?',
      description: '題の文字の書式。指定しないとテーマの bodyLarge',
      initiallyOn: false,
      control: _textStyleControl(),
    ),
    PropertySpec(
      name: 'subtitleTextStyle',
      group: PropertyGroup.text,
      requires: 'subtitle',
      typeLabel: 'TextStyle?',
      description: '説明の文字の書式。指定しないとテーマの bodyMedium',
      initiallyOn: false,
      control: _textStyleControl(),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'style',
      typeLabel: 'ListTileStyle?',
      description: '題の書体を一覧用（list）かドロワー用（drawer）か決める。Material 3 では効かない',
    ),
    ReferenceArg(
      name: 'leadingAndTrailingTextStyle',
      typeLabel: 'TextStyle?',
      description: 'leading・trailing に置いた文字の書式。この見本はアイコンなので違いが出ない',
    ),
    ReferenceArg(
      name: 'onLongPress',
      typeLabel: 'GestureLongPressCallback?',
      description: '行を長押ししたときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onFocusChange',
      typeLabel: 'ValueChanged<bool>?',
      description: '行にフォーカスが当たったり外れたりしたときに呼ばれる',
    ),
    ReferenceArg(
      name: 'mouseCursor',
      typeLabel: 'MouseCursor?',
      description: 'マウスを重ねたときのカーソルの形。タッチ端末では違いが出ない',
    ),
    ReferenceArg(
      name: 'focusColor',
      typeLabel: 'Color?',
      description: 'キーボードなどでフォーカスが当たったときの地の色',
    ),
    ReferenceArg(
      name: 'hoverColor',
      typeLabel: 'Color?',
      description: 'マウスを重ねたときの地の色。タッチ端末では違いが出ない',
    ),
    ReferenceArg(
      name: 'focusNode',
      typeLabel: 'FocusNode?',
      description: 'フォーカスを外から操作したいときに渡す',
    ),
    ReferenceArg(
      name: 'autofocus',
      typeLabel: 'bool',
      description: '画面を開いたときに最初からフォーカスを当てるか。指定しないと false',
    ),
    ReferenceArg(
      name: 'enableFeedback',
      typeLabel: 'bool?',
      description: '押したときに音や振動で知らせるか。指定しないと true',
    ),
    ReferenceArg(
      name: 'internalAddSemanticForOnTap',
      typeLabel: 'bool',
      description: 'onTap があるとき、読み上げ向けにボタンの役割を足すか。Flutter の中で使うためのもの',
    ),
    ReferenceArg(
      name: 'statesController',
      typeLabel: 'WidgetStatesController?',
      description: '押している・選んでいるなどの状態を外から読み書きするときに渡す',
    ),
  ],
  build: _build,
  codeName: 'ListTile',
);

void _noop() {}

ColorControl _colorControl() => ColorControl(
  palette: [
    Choice.color('桜', const Color(0xFFFEF4F4)),
    Choice.color('瑠璃', const Color(0xFF1E50A2)),
    Choice.color('若竹', const Color(0xFF68BE8D)),
    Choice.color('紅', const Color(0xFFD7003A)),
  ],
);

NestedControl _textStyleControl() => NestedControl(
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
        min: 10,
        max: 20,
        divisions: 5,
        initialValue: 18,
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
          Choice('bold', FontWeight.bold, 'FontWeight.bold'),
          Choice('w300', FontWeight.w300, 'FontWeight.w300'),
        ],
      ),
    ),
  ],
  build: _buildTextStyle,
);

TextStyle _buildTextStyle(Map<String, Object> values) => TextStyle(
  color: values['color'] as Color?,
  fontSize: values['fontSize'] as double?,
  fontWeight: values['fontWeight'] as FontWeight?,
);

/// 行は幅いっぱいに広がるので、プレビューでは見やすい幅に決める。
/// 一覧の見本では地の色の箱の上に置かれるので、透明な Material で包んで
/// 波紋の描き先を ListTile のすぐ上にする（どちらもコードには出さない）。
Widget _build(DemoArgs args) {
  final subtitle = args.valueOf<Widget>('subtitle');
  return SizedBox(
    width: 280,
    child: Material(
      type: MaterialType.transparency,
      child: ListTile(
        leading: args.valueOf<Widget>('leading'),
        title: args.valueOf<Widget>('title'),
        subtitle: subtitle,
        trailing: args.valueOf<Widget>('trailing'),
        // subtitle がないのに true を渡すと assert で落ちる
        isThreeLine: subtitle == null
            ? null
            : args.valueOf<bool>('isThreeLine'),
        dense: args.valueOf<bool>('dense'),
        visualDensity: args.valueOf<VisualDensity>('visualDensity'),
        shape: args.valueOf<ShapeBorder>('shape'),
        selectedColor: args.valueOf<Color>('selectedColor'),
        iconColor: args.valueOf<Color>('iconColor'),
        textColor: args.valueOf<Color>('textColor'),
        titleTextStyle: args.valueOf<TextStyle>('titleTextStyle'),
        subtitleTextStyle: args.valueOf<TextStyle>('subtitleTextStyle'),
        contentPadding: args.valueOf<EdgeInsetsGeometry>('contentPadding'),
        // Flutter の既定値（true）。OFF のときも省いたコードと同じ挙動にそろえる。
        enabled: args.valueOf<bool>('enabled') ?? true,
        onTap: args.valueOf<GestureTapCallback>('onTap'),
        selected: args.valueOf<bool>('selected') ?? false,
        splashColor: args.valueOf<Color>('splashColor'),
        tileColor: args.valueOf<Color>('tileColor'),
        selectedTileColor: args.valueOf<Color>('selectedTileColor'),
        horizontalTitleGap: args.valueOf<double>('horizontalTitleGap'),
        minVerticalPadding: args.valueOf<double>('minVerticalPadding'),
        minLeadingWidth: args.valueOf<double>('minLeadingWidth'),
        minTileHeight: args.valueOf<double>('minTileHeight'),
        titleAlignment: args.valueOf<ListTileTitleAlignment>('titleAlignment'),
      ),
    ),
  );
}

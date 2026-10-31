import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_text_field.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoSearchTextFieldEntry = WidgetEntry(
  id: 'cupertinoSearchTextField',
  name: 'CupertinoSearchTextField',
  genreIds: const ['cupertino'],
  summary: 'iOS の見た目の検索欄',
  description:
      '虫めがねのアイコンと消すボタンのついた、iOS の見た目の検索欄です。'
      '入れた文字は onChanged・onSubmitted で受け取ります。'
      '消すボタンは、ふつうは文字を入れている間だけ出ます（suffixMode）。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoSearchTextField-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'placeholder',
      group: PropertyGroup.content,
      typeLabel: 'String?',
      description: '中が空の間に薄く出す文字。指定しないと端末の言語の「検索」',
      control: TextControl(initialValue: '曲名で探す'),
    ),
    PropertySpec(
      name: 'backgroundColor',
      group: PropertyGroup.paint,
      excludes: const ['decoration'],
      omitIf: _decorationOn,
      typeLabel: 'Color?',
      description: '地の色。指定しないと薄い灰色（tertiarySystemFill）',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          const Choice(
            'systemYellow',
            CupertinoColors.systemYellow,
            'CupertinoColors.systemYellow',
          ),
          const Choice(
            'systemTeal',
            CupertinoColors.systemTeal,
            'CupertinoColors.systemTeal',
          ),
          Choice.color('白', const Color(0xFFFFFFFF)),
        ],
      ),
    ),
    PropertySpec(
      name: 'borderRadius',
      group: PropertyGroup.paint,
      excludes: const ['decoration'],
      omitIf: _decorationOn,
      typeLabel: 'BorderRadius?',
      description: '角の丸み。指定しないと 9',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 6,
        initialValue: 20,
        resolve: (v) => BorderRadius.circular(v),
        code: (v) => 'BorderRadius.circular($v)',
      ),
    ),
    const PropertySpec(
      name: 'itemColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color',
      description: 'アイコン（虫めがね・消すボタン）の色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice(
            'activeBlue',
            CupertinoColors.activeBlue,
            'CupertinoColors.activeBlue',
          ),
          Choice(
            'systemRed',
            CupertinoColors.systemRed,
            'CupertinoColors.systemRed',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'suffixMode',
      group: PropertyGroup.behavior,
      typeLabel: 'OverlayVisibilityMode',
      description: '消すボタンを、いつ出すか',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 3,
        choices: [
          for (final mode in OverlayVisibilityMode.values)
            Choice(mode.name, mode, 'OverlayVisibilityMode.${mode.name}'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'enabled',
      group: PropertyGroup.behavior,
      typeLabel: 'bool?',
      description: 'false なら入力できない',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    textFieldDecorationSpec(
      description: '検索欄の地に描く飾り。backgroundColor・borderRadius の代わりに使う。中の値を組み合わせて BoxDecoration を作る',
      excludes: const ['backgroundColor', 'borderRadius'],
    ),
    PropertySpec(
      name: 'padding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry',
      description: '文字のまわりの余白',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 20,
        divisions: 5,
        initialValue: 16,
        resolve: EdgeInsets.all,
        code: (v) => 'EdgeInsets.all($v)',
      ),
    ),
    const PropertySpec(
      name: 'prefixIcon',
      group: PropertyGroup.content,
      typeLabel: 'Widget',
      description: '左に出すアイコン。指定しないと虫めがね',
      initiallyOn: false,
      control: FixedControl(
        value: Icon(CupertinoIcons.music_note),
        source: 'Icon(CupertinoIcons.music_note)',
      ),
    ),
    const PropertySpec(
      name: 'prefixInsets',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry',
      description: '左のアイコンのまわりの余白',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '左を広く',
            EdgeInsetsDirectional.fromSTEB(20, 8, 4, 8),
            'EdgeInsetsDirectional.fromSTEB(20, 8, 4, 8)',
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'suffixIcon',
      group: PropertyGroup.content,
      typeLabel: 'Icon',
      description: '右に出す消すボタンのアイコン。出る時期は suffixMode で決まる',
      initiallyOn: false,
      control: FixedControl(
        value: Icon(CupertinoIcons.clear),
        source: 'Icon(CupertinoIcons.clear)',
      ),
    ),
    const PropertySpec(
      name: 'suffixInsets',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry',
      description: '右の消すボタンのまわりの余白',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '右を広く',
            EdgeInsetsDirectional.fromSTEB(4, 8, 20, 8),
            'EdgeInsetsDirectional.fromSTEB(4, 8, 20, 8)',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'itemSize',
      group: PropertyGroup.size,
      typeLabel: 'double',
      description: 'アイコン（虫めがね・消すボタン）の大きさ',
      initiallyOn: false,
      control: SliderControl(
        min: 12,
        max: 32,
        divisions: 5,
        initialValue: 28,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    textFieldTextStyleSpec(
      name: 'style',
      description: '入れた文字の見た目。指定しないとテーマの文字の見た目',
    ),
    textFieldTextStyleSpec(
      name: 'placeholderStyle',
      description: 'placeholder の文字の見た目。指定しないと灰色（secondaryLabel）',
    ),
    textFieldCursorColorSpec(),
    textFieldCursorWidthSpec(),
    textFieldCursorHeightSpec(),
    textFieldCursorRadiusSpec(),
  ],
  references: [
    ...textFieldReferences(const [
      'key',
      'controller',
      'onChanged',
      'onSubmitted',
      'keyboardType',
    ]),
    const ReferenceArg(
      name: 'onSuffixTap',
      typeLabel: 'VoidCallback?',
      description: '消すボタンを押したときに呼ばれる。指定しないと入れた文字を消す',
    ),
    ...textFieldReferences(const [
      'restorationId',
      'focusNode',
      'smartQuotesType',
      'smartDashesType',
      'enableIMEPersonalizedLearning',
      'autofocus',
      'onTap',
      'autocorrect',
      'cursorOpacityAnimates',
    ]),
  ],
  build: _build,
  codeName: 'CupertinoSearchTextField',
);

/// decoration と backgroundColor・borderRadius は同時に渡せない（SDK の assert）。
bool _decorationOn(Map<String, PropertySetting> settings) =>
    settings['decoration']?.on ?? false;

Widget _build(DemoArgs args) {
  final decoration = args.valueOf<BoxDecoration>('decoration');
  return SizedBox(
    width: 280,
    child: CupertinoSearchTextField(
      placeholder: args.valueOf<String>('placeholder'),
      decoration: decoration,
      backgroundColor: decoration == null
          ? args.valueOf<Color>('backgroundColor')
          : null,
      borderRadius: decoration == null
          ? args.valueOf<BorderRadius>('borderRadius')
          : null,
      itemColor:
          args.valueOf<Color>('itemColor') ?? CupertinoColors.secondaryLabel,
      suffixMode:
          args.valueOf<OverlayVisibilityMode>('suffixMode') ??
          OverlayVisibilityMode.editing,
      enabled: args.valueOf<bool>('enabled'),
      padding:
          args.valueOf<EdgeInsetsGeometry>('padding') ??
          const EdgeInsetsDirectional.fromSTEB(5.5, 8, 5.5, 8),
      prefixIcon:
          args.valueOf<Widget>('prefixIcon') ??
          const Icon(CupertinoIcons.search),
      prefixInsets:
          args.valueOf<EdgeInsetsGeometry>('prefixInsets') ??
          const EdgeInsetsDirectional.fromSTEB(6, 8, 0, 8),
      suffixIcon:
          args.valueOf<Icon>('suffixIcon') ??
          const Icon(CupertinoIcons.xmark_circle_fill),
      suffixInsets:
          args.valueOf<EdgeInsetsGeometry>('suffixInsets') ??
          const EdgeInsetsDirectional.fromSTEB(0, 8, 5, 8),
      itemSize: args.valueOf<double>('itemSize') ?? 20,
      style: args.valueOf<TextStyle>('style'),
      placeholderStyle: args.valueOf<TextStyle>('placeholderStyle'),
      cursorColor: args.valueOf<Color>('cursorColor'),
      cursorWidth: args.valueOf<double>('cursorWidth') ?? 2,
      cursorHeight: args.valueOf<double>('cursorHeight'),
      cursorRadius:
          args.valueOf<Radius>('cursorRadius') ?? const Radius.circular(2),
    ),
  );
}

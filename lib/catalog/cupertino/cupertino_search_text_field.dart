import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
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
      typeLabel: 'String?',
      description: '中が空の間に薄く出す文字。指定しないと端末の言語の「検索」',
      control: TextControl(initialValue: '曲名で探す'),
    ),
    PropertySpec(
      name: 'backgroundColor',
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
      typeLabel: 'bool?',
      description: 'false なら入力できない',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
  ],
  build: _build,
  codeName: 'CupertinoSearchTextField',
);

Widget _build(DemoArgs args) => SizedBox(
  width: 280,
  child: CupertinoSearchTextField(
    placeholder: args.valueOf<String>('placeholder'),
    backgroundColor: args.valueOf<Color>('backgroundColor'),
    borderRadius: args.valueOf<BorderRadius>('borderRadius'),
    itemColor:
        args.valueOf<Color>('itemColor') ?? CupertinoColors.secondaryLabel,
    suffixMode:
        args.valueOf<OverlayVisibilityMode>('suffixMode') ??
        OverlayVisibilityMode.editing,
    enabled: args.valueOf<bool>('enabled'),
  ),
);

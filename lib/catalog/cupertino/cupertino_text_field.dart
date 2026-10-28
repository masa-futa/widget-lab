import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

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
      typeLabel: 'String?',
      description: '中が空の間に薄く出す文字',
      control: TextControl(initialValue: 'メールアドレス'),
    ),
    const PropertySpec(
      name: 'prefix',
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
      name: 'clearButtonMode',
      typeLabel: 'OverlayVisibilityMode',
      description: '右に出す消すボタンを、いつ出すか。中が空のときは出ない',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 2,
        choices: [
          for (final mode in OverlayVisibilityMode.values)
            Choice(mode.name, mode, 'OverlayVisibilityMode.${mode.name}'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'obscureText',
      typeLabel: 'bool',
      description: 'true なら入れた文字を • で隠す（パスワード向け）',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'textAlign',
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
    ),
    PropertySpec(
      name: 'padding',
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
    const PropertySpec(
      name: 'enabled',
      typeLabel: 'bool',
      description: 'false なら入力できず、地が灰色になる',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
  ],
  build: _build,
  codeName: 'CupertinoTextField',
);

Widget _build(DemoArgs args) => SizedBox(
  width: 280,
  child: CupertinoTextField(
    placeholder: args.valueOf<String>('placeholder'),
    prefix: args.valueOf<Widget>('prefix'),
    clearButtonMode:
        args.valueOf<OverlayVisibilityMode>('clearButtonMode') ??
        OverlayVisibilityMode.never,
    obscureText: args.valueOf<bool>('obscureText') ?? false,
    textAlign: args.valueOf<TextAlign>('textAlign') ?? TextAlign.start,
    padding:
        args.valueOf<EdgeInsetsGeometry>('padding') ?? const EdgeInsets.all(7),
    enabled: args.valueOf<bool>('enabled') ?? true,
  ),
);

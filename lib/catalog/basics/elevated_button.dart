import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final elevatedButtonEntry = WidgetEntry(
  id: 'elevatedButton',
  name: 'ElevatedButton',
  genreIds: const ['basics'],
  summary: '影で少し浮いて見えるボタン',
  description:
      '地に影を付けて、少し浮いて見えるボタンです。押すと影が深くなります。'
      'Material 3 では、平らな地の上で目立たせたいときに使います'
      '（ほかの基本のボタンは Material design の Common buttons）。'
      'onPressed を渡さないと、押せない見た目になります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/ElevatedButton-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'onPressed',
      group: PropertyGroup.behavior,
      typeLabel: 'VoidCallback?',
      description: '押されたときに呼ばれる。null（指定なし）だと押せない見た目になる',
      control: FixedControl(value: _noop, source: '() {}'),
    ),
    const PropertySpec(
      name: 'onLongPress',
      group: PropertyGroup.behavior,
      typeLabel: 'VoidCallback?',
      description: '長押しされたときに呼ばれる。onPressed がなくても、これがあれば押せる見た目になる',
      initiallyOn: false,
      control: FixedControl(value: _noop, source: '() {}'),
    ),
    PropertySpec(
      name: 'style',
      group: PropertyGroup.paint,
      typeLabel: 'ButtonStyle?',
      description: 'ボタンの見た目。ここでは浮き上がりの高さだけを変える',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final elevation in const [0.0, 6.0, 12.0])
            Choice(
              '$elevation',
              ElevatedButton.styleFrom(elevation: elevation),
              'ElevatedButton.styleFrom(elevation: $elevation)',
            ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: 'ボタンの中に置く Widget。ふつうは Text',
      required: true,
      control: FixedControl(value: Text('保存'), source: "Text('保存')"),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'onHover',
      typeLabel: 'ValueChanged<bool>?',
      description: 'ポインターが乗ったとき・離れたときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onFocusChange',
      typeLabel: 'ValueChanged<bool>?',
      description: 'フォーカスを得たとき・失ったときに呼ばれる',
    ),
    ReferenceArg(
      name: 'focusNode',
      typeLabel: 'FocusNode?',
      description: 'フォーカスを外から動かしたり調べたりするための印',
    ),
    ReferenceArg(
      name: 'autofocus',
      typeLabel: 'bool',
      description: '画面を開いたときに最初からフォーカスを持つか。キーボードで操作するときに効く',
    ),
    ReferenceArg(
      name: 'clipBehavior',
      typeLabel: 'Clip?',
      description: 'ボタンの形で中身を切り抜くか。中身がはみ出さない見本では違いが出ない',
    ),
    ReferenceArg(
      name: 'statesController',
      typeLabel: 'WidgetStatesController?',
      description: '押されている・ポインターが乗っているなどの状態を外から読み書きするためのもの',
    ),
  ],
  build: _build,
  codeName: 'ElevatedButton',
);

void _noop() {}

Widget _build(DemoArgs args) => ElevatedButton(
  onPressed: args.valueOf<VoidCallback>('onPressed'),
  onLongPress: args.valueOf<VoidCallback>('onLongPress'),
  style: args.valueOf<ButtonStyle>('style'),
  child: args.valueOf<Widget>('child'),
);

import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final imageEntry = WidgetEntry(
  id: 'image',
  name: 'Image',
  genreIds: const ['assets', 'basics'],
  summary: '画像（アセット・ネット・ファイル・メモリ）を描く',
  description:
      '画像を読み込んで描きます。アプリに同梱した画像は Image.asset、'
      'ネットの画像は Image.network、ファイルは Image.file で読みます。'
      '大きさを指定したときの合わせ方は fit で決めます。'
      'ここでは同梱した 64×40 の画像を読んでいます。',
  docUrl: Uri.parse('https://api.flutter.dev/flutter/widgets/Image-class.html'),
  properties: const [
    PropertySpec(
      name: 'name',
      typeLabel: 'String',
      description: 'アセットの名前（pubspec.yaml の assets に書いた場所）',
      required: true,
      arg: PropertyArg.positional,
      control: FixedControl(
        value: _asset,
        source: "'assets/demo/landscape.png'",
      ),
    ),
    PropertySpec(
      name: 'width',
      typeLabel: 'double?',
      description: '幅。指定しないと画像の幅',
      control: SliderControl(
        min: 40,
        max: 200,
        divisions: 8,
        initialValue: 160,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'height',
      typeLabel: 'double?',
      description: '高さ。指定しないと画像の高さ',
      control: SliderControl(
        min: 24,
        max: 56,
        divisions: 4,
        initialValue: 56,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'fit',
      typeLabel: 'BoxFit?',
      description: '大きさへの合わせ方。指定しないと scaleDown（縮めるだけ）',
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice('contain', BoxFit.contain, 'BoxFit.contain'),
          Choice('cover', BoxFit.cover, 'BoxFit.cover'),
          Choice('fill', BoxFit.fill, 'BoxFit.fill'),
          Choice('fitWidth', BoxFit.fitWidth, 'BoxFit.fitWidth'),
          Choice('none', BoxFit.none, 'BoxFit.none'),
        ],
      ),
    ),
    PropertySpec(
      name: 'repeat',
      typeLabel: 'ImageRepeat',
      description: '余った所に画像を繰り返して敷くか。既定は noRepeat',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice('noRepeat', ImageRepeat.noRepeat, 'ImageRepeat.noRepeat'),
          Choice('repeat', ImageRepeat.repeat, 'ImageRepeat.repeat'),
          Choice('repeatX', ImageRepeat.repeatX, 'ImageRepeat.repeatX'),
        ],
      ),
    ),
  ],
  build: _build,
  codeName: 'Image.asset',
);

const _asset = 'assets/demo/landscape.png';

Widget _build(DemoArgs args) => Image.asset(
  // 必須のプロパティなので、常に値がある
  args.valueOf<String>('name')!,
  width: args.valueOf<double>('width'),
  height: args.valueOf<double>('height'),
  fit: args.valueOf<BoxFit>('fit'),
  repeat: args.valueOf<ImageRepeat>('repeat') ?? ImageRepeat.noRepeat,
);

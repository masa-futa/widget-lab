import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final rawImageEntry = WidgetEntry(
  id: 'rawImage',
  name: 'RawImage',
  genreIds: const ['assets'],
  summary: '読み込み済みの ui.Image をそのまま描く',
  description:
      'すでに手元にある ui.Image（デコード済みの画像）を描きます。読み込みはしません。'
      'ふつうは Image を使い、自分で作った画像（描いた絵やカメラの画面など）を描くときに使います。'
      'ここでは 8×5 の小さな絵を描いて作り、拡大しています。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/RawImage-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'image',
      typeLabel: 'ui.Image?',
      description: '描く画像（8×5 の色の格子）',
      required: true,
      control: FixedControl(value: _PixelArt(), source: 'image'),
    ),
    PropertySpec(
      name: 'width',
      typeLabel: 'double?',
      description: '幅。指定しないと画像の幅（8）',
      control: SliderControl(
        min: 8,
        max: 168,
        divisions: 10,
        initialValue: 88,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'height',
      typeLabel: 'double?',
      description: '高さ。指定しないと画像の高さ（5）',
      control: SliderControl(
        min: 5,
        max: 55,
        divisions: 5,
        initialValue: 55,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'filterQuality',
      typeLabel: 'FilterQuality',
      description: '拡大・縮小するときの補い方。none は点がくっきり、medium はなめらか。既定は medium',
      control: ChoiceControl(
        choices: [
          Choice('none', FilterQuality.none, 'FilterQuality.none'),
          Choice('low', FilterQuality.low, 'FilterQuality.low'),
          Choice('medium', FilterQuality.medium, 'FilterQuality.medium'),
          Choice('high', FilterQuality.high, 'FilterQuality.high'),
        ],
      ),
    ),
    PropertySpec(
      name: 'fit',
      typeLabel: 'BoxFit?',
      description: '大きさへの合わせ方。指定しないと拡大・縮小せず中央に置く',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('fill', BoxFit.fill, 'BoxFit.fill'),
          Choice('contain', BoxFit.contain, 'BoxFit.contain'),
          Choice('cover', BoxFit.cover, 'BoxFit.cover'),
        ],
      ),
    ),
  ],
  build: _build,
  codeName: 'RawImage',
);

Widget _build(DemoArgs args) => RawImage(
  image: args.valueOf<_PixelArt>('image')?.image,
  width: args.valueOf<double>('width'),
  height: args.valueOf<double>('height'),
  filterQuality:
      args.valueOf<FilterQuality>('filterQuality') ?? FilterQuality.medium,
  fit: args.valueOf<BoxFit>('fit'),
);

/// 8×5 の色の格子の絵。最初に使うときに描いて作り、アプリの間ずっと持つ
/// （RawImage は描くときに複製するので、元は捨てない）。
final class _PixelArt {
  const _PixelArt();

  static const _width = 8;
  static const _height = 5;

  static ui.Image? _image;

  ui.Image get image => _image ??= _draw();

  static ui.Image _draw() {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    for (var y = 0; y < _height; y++) {
      for (var x = 0; x < _width; x++) {
        final color = DemoTile.colors[(x + y) % DemoTile.colors.length];
        canvas.drawRect(
          Rect.fromLTWH(x.toDouble(), y.toDouble(), 1, 1),
          Paint()..color = color,
        );
      }
    }
    final picture = recorder.endRecording();
    final image = picture.toImageSync(_width, _height);
    picture.dispose();
    return image;
  }
}

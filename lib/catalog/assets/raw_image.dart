import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
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
  properties: [
    const PropertySpec(
      name: 'image',
      group: PropertyGroup.content,
      typeLabel: 'ui.Image?',
      description: '描く画像（8×5 の色の格子）',
      required: true,
      control: FixedControl(value: _PixelArt(), source: 'image'),
    ),
    const PropertySpec(
      name: 'width',
      group: PropertyGroup.size,
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
    const PropertySpec(
      name: 'height',
      group: PropertyGroup.size,
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
    const PropertySpec(
      name: 'filterQuality',
      group: PropertyGroup.paint,
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
    const PropertySpec(
      name: 'fit',
      group: PropertyGroup.layout,
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
    const PropertySpec(
      name: 'alignment',
      group: PropertyGroup.layout,
      typeLabel: 'AlignmentGeometry',
      description: '枠の中での画像の位置。fit で余白やはみ出しが出るときに違いが見える。既定は center',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: alignmentCenter,
        choices: alignmentChoices,
      ),
    ),
    const PropertySpec(
      name: 'repeat',
      group: PropertyGroup.layout,
      typeLabel: 'ImageRepeat',
      description: '余った所に画像を繰り返して敷くか。既定は noRepeat',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('repeat', ImageRepeat.repeat, 'ImageRepeat.repeat'),
          Choice('repeatX', ImageRepeat.repeatX, 'ImageRepeat.repeatX'),
          Choice('repeatY', ImageRepeat.repeatY, 'ImageRepeat.repeatY'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'centerSlice',
      group: PropertyGroup.layout,
      typeLabel: 'Rect?',
      description: '画像の中で伸ばす部分（ナインパッチ）。四隅は伸ばさずに描く。fit が cover のときは使えない',
      initiallyOn: false,
      omitIf: _omitsCenterSlice,
      control: FixedControl(value: _slice, source: 'Rect.fromLTWH(2, 1, 4, 3)'),
    ),
    const PropertySpec(
      name: 'scale',
      group: PropertyGroup.size,
      typeLabel: 'double',
      description:
          '画像の点の細かさ。2.0 なら画像の大きさを半分として扱う（width・height を指定しないときに違いが見える）。既定は 1.0',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [Choice('2.0', 2.0, '2.0'), Choice('0.5', 0.5, '0.5')],
      ),
    ),
    PropertySpec(
      name: 'color',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '画像に混ぜる色。colorBlendMode を指定しないと、画像の形をこの色で塗る（srcIn）',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅', DemoTile.colors[3]),
          Choice.color('墨', const Color(0xFF18181B)),
        ],
      ),
    ),
    const PropertySpec(
      name: 'colorBlendMode',
      group: PropertyGroup.paint,
      requires: 'color',
      typeLabel: 'BlendMode?',
      description: 'color を画像に混ぜる方法',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('multiply', BlendMode.multiply, 'BlendMode.multiply'),
          Choice('color', BlendMode.color, 'BlendMode.color'),
          Choice('difference', BlendMode.difference, 'BlendMode.difference'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'opacity',
      group: PropertyGroup.paint,
      typeLabel: 'Animation<double>?',
      description: '画像の不透明度。Animation で渡すので、動かしながら薄くできる',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '0.5',
            AlwaysStoppedAnimation<double>(0.5),
            'const AlwaysStoppedAnimation(0.5)',
          ),
          Choice(
            '0.2',
            AlwaysStoppedAnimation<double>(0.2),
            'const AlwaysStoppedAnimation(0.2)',
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'invertColors',
      group: PropertyGroup.paint,
      typeLabel: 'bool',
      description: '画像の色を反転して描くか（白黒反転の設定と同じ）。既定は false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'debugImageLabel',
      typeLabel: 'String?',
      description: 'デバッグの表示で画像を見分ける名前。見た目は変わらない',
    ),
    ReferenceArg(
      name: 'matchTextDirection',
      typeLabel: 'bool',
      description: '右から左の言語のときに、画像を左右反転して描くか',
    ),
    ReferenceArg(
      name: 'isAntiAlias',
      typeLabel: 'bool',
      description: '画像の縁をなめらかにするか。回転したときなどに効き、見本では違いが見えにくい',
    ),
  ],
  build: _build,
  codeName: 'RawImage',
);

/// 8×5 の絵の真ん中。四隅の 2×1 は伸ばさない。
const _slice = Rect.fromLTWH(2, 1, 4, 3);

/// centerSlice を渡さない組み合わせ。cover は画像の一部しか見えないので assert で落ち、
/// scale で画像の大きさが変わると、伸ばす部分が画像からはみ出す。
bool _omitsCenterSlice(Map<String, PropertySetting> settings) {
  if (settings['scale']?.on ?? false) return true;
  final fit = settings['fit'];
  if (fit == null || !fit.on) return false;
  final value = fit.value;
  return value is ChoiceValue && _fitChoices[value.index] == BoxFit.cover;
}

/// fit の選択肢の値（並びは収録データと同じ）。
const _fitChoices = [BoxFit.fill, BoxFit.contain, BoxFit.cover];

Widget _build(DemoArgs args) {
  final fit = args.valueOf<BoxFit>('fit');
  final scale = args.valueOf<double>('scale');
  return RawImage(
    image: args.valueOf<_PixelArt>('image')?.image,
    width: args.valueOf<double>('width'),
    height: args.valueOf<double>('height'),
    filterQuality:
        args.valueOf<FilterQuality>('filterQuality') ?? FilterQuality.medium,
    fit: fit,
    alignment: args.valueOf<AlignmentGeometry>('alignment') ?? Alignment.center,
    repeat: args.valueOf<ImageRepeat>('repeat') ?? ImageRepeat.noRepeat,
    centerSlice: fit == BoxFit.cover || scale != null
        ? null
        : args.valueOf<Rect>('centerSlice'),
    scale: scale ?? 1.0,
    color: args.valueOf<Color>('color'),
    colorBlendMode: args.valueOf<BlendMode>('colorBlendMode'),
    opacity: args.valueOf<Animation<double>>('opacity'),
    invertColors: args.valueOf<bool>('invertColors') ?? false,
  );
}

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

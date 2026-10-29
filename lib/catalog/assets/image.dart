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

/// fit の選択肢。centerSlice と組めるのは画像の全体が見える contain と fill だけ。
const _fits = [
  (BoxFit.contain, true),
  (BoxFit.cover, false),
  (BoxFit.fill, true),
  (BoxFit.fitWidth, false),
  (BoxFit.none, false),
];

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
  properties: [
    const PropertySpec(
      name: 'name',
      group: PropertyGroup.content,
      typeLabel: 'String',
      description: 'アセットの名前（pubspec.yaml の assets に書いた場所）',
      required: true,
      arg: PropertyArg.positional,
      control: FixedControl(
        value: _asset,
        source: "'assets/demo/landscape.png'",
      ),
    ),
    const PropertySpec(
      name: 'width',
      group: PropertyGroup.size,
      pairsWith: ['height'],
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
    const PropertySpec(
      name: 'height',
      group: PropertyGroup.size,
      pairsWith: ['width'],
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
      group: PropertyGroup.layout,
      typeLabel: 'BoxFit?',
      description: '大きさへの合わせ方。指定しないと scaleDown（縮めるだけ）',
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          for (final (fit, _) in _fits)
            Choice(fit.name, fit, 'BoxFit.${fit.name}'),
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
        initialIndex: 1,
        choices: [
          Choice('noRepeat', ImageRepeat.noRepeat, 'ImageRepeat.noRepeat'),
          Choice('repeat', ImageRepeat.repeat, 'ImageRepeat.repeat'),
          Choice('repeatX', ImageRepeat.repeatX, 'ImageRepeat.repeatX'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'centerSlice',
      group: PropertyGroup.layout,
      typeLabel: 'Rect?',
      description:
          '画像の中で伸ばす部分（ナインパッチ）。四隅は伸ばさずに描く。fit が cover・fitWidth・none のときは使えない',
      initiallyOn: false,
      omitIf: _omitsCenterSlice,
      control: FixedControl(
        value: _slice,
        source: 'Rect.fromLTWH(16, 10, 32, 20)',
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
          Choice.color('瑠璃', DemoTile.colors[0]),
          Choice.color('山吹', DemoTile.colors[1]),
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
      name: 'filterQuality',
      group: PropertyGroup.paint,
      typeLabel: 'FilterQuality',
      description: '拡大・縮小するときの補い方。none は点がくっきり、medium はなめらか。既定は medium',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('none', FilterQuality.none, 'FilterQuality.none'),
          Choice('low', FilterQuality.low, 'FilterQuality.low'),
          Choice('high', FilterQuality.high, 'FilterQuality.high'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'scale',
      group: PropertyGroup.size,
      typeLabel: 'double?',
      description:
          '画像の点の細かさ。2.0 なら画像の大きさを半分として扱う（width・height を指定しないときに違いが見える）',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [Choice('2.0', 2.0, '2.0'), Choice('0.5', 0.5, '0.5')],
      ),
    ),
    const PropertySpec(
      name: 'cacheWidth',
      group: PropertyGroup.size,
      typeLabel: 'int?',
      description: 'この幅に縮めてから読み込む。メモリが減るが、拡大すると粗く見える',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [Choice('16', 16, '16'), Choice('32', 32, '32')],
      ),
    ),
    const PropertySpec(
      name: 'cacheHeight',
      group: PropertyGroup.size,
      typeLabel: 'int?',
      description: 'この高さに縮めてから読み込む。メモリが減るが、拡大すると粗く見える',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [Choice('10', 10, '10'), Choice('20', 20, '20')],
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
      name: 'bundle',
      typeLabel: 'AssetBundle?',
      description: '画像を読む束。指定しないとまわりの DefaultAssetBundle を使う',
    ),
    ReferenceArg(
      name: 'package',
      typeLabel: 'String?',
      description: 'ほかのパッケージに同梱された画像を読むときの、パッケージの名前',
    ),
    ReferenceArg(
      name: 'frameBuilder',
      typeLabel: 'ImageFrameBuilder?',
      description: '読み込みの途中やコマごとに、画像のまわりを組み立てる関数。フェードインなどに使う',
    ),
    ReferenceArg(
      name: 'errorBuilder',
      typeLabel: 'ImageErrorWidgetBuilder?',
      description: '読み込みに失敗したときに、代わりに出す Widget を組み立てる関数',
    ),
    ReferenceArg(
      name: 'semanticLabel',
      typeLabel: 'String?',
      description: '読み上げる画像の説明。見た目は変わらない',
    ),
    ReferenceArg(
      name: 'excludeFromSemantics',
      typeLabel: 'bool',
      description: '読み上げの対象から外すか。飾りの画像で使う',
    ),
    ReferenceArg(
      name: 'matchTextDirection',
      typeLabel: 'bool',
      description: '右から左の言語のときに、画像を左右反転して描くか',
    ),
    ReferenceArg(
      name: 'gaplessPlayback',
      typeLabel: 'bool',
      description: '画像を差し替えるとき、新しい画像が届くまで古い画像を出し続けるか',
    ),
    ReferenceArg(
      name: 'isAntiAlias',
      typeLabel: 'bool',
      description: '画像の縁をなめらかにするか。回転したときなどに効き、見本では違いが見えにくい',
    ),
  ],
  build: _build,
  codeName: 'Image.asset',
);

const _asset = 'assets/demo/landscape.png';

/// 64×40 の画像の真ん中。四隅の 16×10 は伸ばさない。
const _slice = Rect.fromLTWH(16, 10, 32, 20);

bool _isOn(Map<String, PropertySetting> settings, String name) =>
    settings[name]?.on ?? false;

/// centerSlice を渡さない組み合わせ。画像の一部しか見えない fit は assert で落ち、
/// scale・cacheWidth・cacheHeight で画像の大きさが変わると、伸ばす部分が画像からはみ出す。
bool _omitsCenterSlice(Map<String, PropertySetting> settings) {
  if (_isOn(settings, 'scale') ||
      _isOn(settings, 'cacheWidth') ||
      _isOn(settings, 'cacheHeight')) {
    return true;
  }
  final fit = settings['fit'];
  if (fit == null || !fit.on) return false;
  final value = fit.value;
  return value is ChoiceValue && !_fits[value.index].$2;
}

Widget _build(DemoArgs args) {
  final fit = args.valueOf<BoxFit>('fit');
  final slicesFit = fit == null || _fits.any((f) => f.$1 == fit && f.$2);
  final sizeChanged =
      args.valueOf<double>('scale') != null ||
      args.valueOf<int>('cacheWidth') != null ||
      args.valueOf<int>('cacheHeight') != null;
  return Image.asset(
    // 必須のプロパティなので、常に値がある
    args.valueOf<String>('name')!,
    width: args.valueOf<double>('width'),
    height: args.valueOf<double>('height'),
    fit: fit,
    alignment: args.valueOf<AlignmentGeometry>('alignment') ?? Alignment.center,
    repeat: args.valueOf<ImageRepeat>('repeat') ?? ImageRepeat.noRepeat,
    centerSlice: slicesFit && !sizeChanged
        ? args.valueOf<Rect>('centerSlice')
        : null,
    color: args.valueOf<Color>('color'),
    colorBlendMode: args.valueOf<BlendMode>('colorBlendMode'),
    opacity: args.valueOf<Animation<double>>('opacity'),
    filterQuality:
        args.valueOf<FilterQuality>('filterQuality') ?? FilterQuality.medium,
    scale: args.valueOf<double>('scale'),
    cacheWidth: args.valueOf<int>('cacheWidth'),
    cacheHeight: args.valueOf<int>('cacheHeight'),
  );
}

import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_recorder.dart';
import 'package:widget_lab/catalog/demo/demo_scope.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// Hero は同じ tag が木の中で一意であることを前提にするので、見本はアイコンにする
/// （behavior。docs/design/functions/demo-engine.md の「見本」）。
/// 画面の移り変わりは、アプリの Navigator ではなくデモの中の Navigator で行う。
final heroEntry = WidgetEntry(
  id: 'hero',
  name: 'Hero',
  genreIds: const ['animation', 'interaction'],
  summary: '画面が移るとき、同じ tag の Widget を次の画面の位置へ飛ばす',
  description:
      '移る前と後の画面に同じ tag の Hero があると、画面が移る間、その子を前の位置と大きさから'
      '次の位置と大きさへ飛ばして見せます。tag は 1 つの画面の中で重ねられません。'
      'ここではデモの中の Navigator で、ロゴを押すと大きなロゴの画面へ移ります。',
  docUrl: Uri.parse('https://api.flutter.dev/flutter/widgets/Hero-class.html'),
  kind: EntryKind.behavior,
  properties: [
    const PropertySpec(
      name: 'tag',
      typeLabel: 'Object',
      description: '前後の画面の Hero を結び付ける目印。両方の画面で同じ値にする',
      required: true,
      control: FixedControl(value: 'logo', source: "'logo'"),
    ),
    PropertySpec(
      name: 'curve',
      typeLabel: 'Curve',
      description: '飛ぶ動きの速さの変わり方。指定しないと fastOutSlowIn',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final (name, curve) in const [
            ('fastOutSlowIn', Curves.fastOutSlowIn),
            ('linear', Curves.linear),
            ('easeInOutBack', Curves.easeInOutBack),
          ])
            Choice(name, curve, 'Curves.$name'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'child',
      typeLabel: 'Widget',
      description: '飛ばす Widget。前後の画面で見た目が違ってよい（大きさは画面ごとに決まる）',
      required: true,
      control: FixedControl(
        value: FlutterLogo(),
        source: 'const FlutterLogo()',
      ),
    ),
  ],
  build: _build,
  buildWithout: _buildWithout,
  codeName: 'Hero',
);

Widget _build(DemoArgs args) {
  final curve = args.valueOf<Curve>('curve');
  return DemoScope(
    label: 'Hero(tag: logo${curve == null ? '' : ', curve: …'})',
    child: _HeroDemo(
      useHero: true,
      tag: args.valueOf<Object>('tag') ?? 'logo',
      curve: curve ?? Curves.fastOutSlowIn,
      child: args.valueOf<Widget>('child') ?? const FlutterLogo(),
    ),
  );
}

/// 包みを外す。ロゴは飛ばず、画面ごと入れ替わる。
Widget _buildWithout(DemoArgs args) => DemoFit(
  child: _HeroDemo(
    useHero: false,
    tag: args.valueOf<Object>('tag') ?? 'logo',
    curve: Curves.fastOutSlowIn,
    child: args.valueOf<Widget>('child') ?? const FlutterLogo(),
  ),
);

/// デモの中の Navigator。1 枚目は小さなロゴ、2 枚目は大きなロゴ。
class _HeroDemo extends StatefulWidget {
  const _HeroDemo({
    required this.useHero,
    required this.tag,
    required this.curve,
    required this.child,
  });

  final bool useHero;
  final Object tag;
  final Curve curve;
  final Widget child;

  @override
  State<_HeroDemo> createState() => _HeroDemoState();
}

class _HeroDemoState extends State<_HeroDemo> {
  /// 入れ子の Navigator では Hero が飛ぶのに HeroController が要る
  /// （MaterialApp が付けるのはアプリの Navigator の分だけ）。
  final _heroController = MaterialApp.createMaterialHeroController();

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  /// 前後の画面のロゴ。Hero を使わない側では包まない。
  Widget _logo(double size) {
    final logo = SizedBox.square(dimension: size, child: widget.child);
    if (!widget.useHero) return logo;
    return Hero(tag: widget.tag, curve: widget.curve, child: logo);
  }

  @override
  Widget build(BuildContext context) {
    final recorder = DemoRecorder.of(context);
    return SizedBox(
      height: _height,
      child: ClipRect(
        child: Navigator(
          observers: [_heroController, _LogObserver(recorder)],
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            settings: settings,
            builder: (context) => _FirstPage(
              logo: _logo(32),
              onOpen: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => _SecondPage(logo: _logo(96)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// デモの Navigator の高さ（DemoFit の中は高さに上限がないので決めておく）。
const _height = 200.0;

/// 画面の移り変わりをログに出す（デモの部品。コードには出さない）。
class _LogObserver extends NavigatorObserver {
  _LogObserver(this.recorder);

  final DemoRecorder recorder;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // 最初の画面を置いたときは出さない
    if (previousRoute != null) recorder.log('push: 大きなロゴの画面へ');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      recorder.log('pop: 小さなロゴの画面へ');
}

/// 1 枚目。小さなロゴを左上に置き、押すと 2 枚目へ移る。
class _FirstPage extends StatelessWidget {
  const _FirstPage({required this.logo, required this.onOpen});

  final Widget logo;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => Material(
    child: ListTile(
      leading: logo,
      title: Text('ロゴを押す', textScaler: DemoRecorder.textScalerOf(context)),
      onTap: onOpen,
    ),
  );
}

/// 2 枚目。大きなロゴを中央に置き、戻るボタンで 1 枚目へ戻る。
class _SecondPage extends StatelessWidget {
  const _SecondPage({required this.logo});

  final Widget logo;

  @override
  Widget build(BuildContext context) => Material(
    child: Stack(
      children: [
        Center(child: logo),
        Align(
          alignment: AlignmentDirectional.topStart,
          child: BackButton(onPressed: () => Navigator.of(context).pop()),
        ),
      ],
    ),
  );
}

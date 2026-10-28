import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/animation/transition_curves.dart';
import 'package:widget_lab/catalog/demo/demo_animation.dart';
import 'package:widget_lab/catalog/demo/demo_stage.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final sliverFadeTransitionEntry = WidgetEntry(
  id: 'sliverFadeTransition',
  name: 'SliverFadeTransition',
  genreIds: const ['animation'],
  summary: 'Animation の値に合わせて、Sliver の不透明度を変える',
  description:
      'FadeTransition の Sliver 版です。CustomScrollView の中で、Sliver（ここでは 5 行のリスト）を'
      'Animation の値の不透明度で描きます。ここでは高さ 160 の CustomScrollView に置きます。'
      'controller は 0→1→0 を繰り返す AnimationController です。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/SliverFadeTransition-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'opacity',
      typeLabel: 'Animation<double>',
      description: '不透明度の Animation。ここでは 0.2 → 1.0 を曲線を選んで動かす',
      required: true,
      control: ChoiceControl(choices: curveChoices(begin: 0.2)),
    ),
    const PropertySpec(
      name: 'alwaysIncludeSemantics',
      typeLabel: 'bool',
      description: '透明（0）のときも読み上げの対象に残すか。見た目は変わらない',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'sliver',
      typeLabel: 'Widget?',
      description:
          '不透明度を変えて描く Sliver。ここでは 5 行の箱（Rows）を Sliver にしたもの。'
          '型は null を許すが、ないと組み立てで落ちるので必須にしている',
      required: true,
      control: FixedControl(
        value: SliverToBoxAdapter(child: _Rows()),
        source: 'SliverToBoxAdapter(child: Rows())',
      ),
    ),
  ],
  build: _build,
  codeName: 'SliverFadeTransition',
);

Widget _build(DemoArgs args) => DemoStage(
  size: const Size(240, 160),
  child: DemoAnimation(
    builder: (context, controller) => CustomScrollView(
      slivers: [
        SliverFadeTransition(
          opacity: (args.valueOf<AnimationOf<double>>('opacity') ?? linearOf)(
            controller,
          ),
          alwaysIncludeSemantics:
              args.valueOf<bool>('alwaysIncludeSemantics') ?? false,
          sliver: args.valueOf<Widget>('sliver'),
        ),
      ],
    ),
  ),
);

/// 5 行の箱（コードでは `Rows`）。
class _Rows extends StatelessWidget {
  const _Rows();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var i = 1; i <= 5; i++)
        Container(
          height: 32,
          alignment: Alignment.centerLeft,
          color: Color(i.isOdd ? 0xFF1E50A2 : 0xFF68BE8D),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '$i 行目',
            style: const TextStyle(color: Color(0xFFFFFFFF)),
          ),
        ),
    ],
  );
}

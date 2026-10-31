/// scrolling の収録で繰り返し使う選択肢。
library;

import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';

/// `ScrollPhysics` の 3 つ（はね返る・端で止まる・スクロールしない）。
const physicsChoices = [
  Choice('はね返る', BouncingScrollPhysics(), 'BouncingScrollPhysics()'),
  Choice('端で止まる', ClampingScrollPhysics(), 'ClampingScrollPhysics()'),
  Choice(
    'スクロールしない',
    NeverScrollableScrollPhysics(),
    'NeverScrollableScrollPhysics()',
  ),
];

/// スクロールの見える範囲の外を切り抜くか（既定の hardEdge 以外）。
final clipChoices = [
  for (final clip in const [Clip.none, Clip.antiAlias])
    Choice(clip.name, clip, 'Clip.${clip.name}'),
];

/// `ScrollBehavior` の 2 つ（スクロールバーなし・はね返る）。
final scrollBehaviorChoices = [
  Choice(
    'スクロールバーなし',
    const MaterialScrollBehavior().copyWith(scrollbars: false),
    'const MaterialScrollBehavior().copyWith(scrollbars: false)',
  ),
  Choice(
    'はね返る',
    const MaterialScrollBehavior().copyWith(
      physics: const BouncingScrollPhysics(),
    ),
    'const MaterialScrollBehavior().copyWith(\n'
        '    physics: const BouncingScrollPhysics(),\n'
        '  )',
  ),
];

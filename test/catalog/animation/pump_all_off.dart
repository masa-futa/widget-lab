import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/demo/demo_animation.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

import '../all_off.dart';

/// [entry] を全部 OFF（必須は ON）で組み立てて置く。Transition は DemoAnimation の
/// 中で組み立てるので、置いてから木の中の Widget を見る。
Future<void> pumpAllOff(WidgetTester tester, WidgetEntry entry) =>
    tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: entry.build(DemoArgs(entry, allOff(entry)))),
        ),
      ),
    );

/// デモの中（DemoAnimation の下）の [type] の Widget。アプリの部品の同じ型は数えない。
Finder demoFinder(Type type) => find.descendant(
  of: find.byType(DemoAnimation),
  matching: find.byType(type),
);

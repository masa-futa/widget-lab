import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_stage.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final scaffoldEntry = WidgetEntry(
  id: 'scaffold',
  name: 'Scaffold',
  genreIds: const ['basics'],
  summary: '画面の骨組み。上の帯・本文・下の帯・浮いたボタンの置き場を持つ',
  description:
      'Material の画面の骨組みです。appBar・body・bottomNavigationBar・'
      'floatingActionButton などの置き場を持ち、それぞれを決まった位置に並べます。'
      'SnackBar やボトムシートもこの上に出ます。ここでは小さな画面に縮めて見ます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/Scaffold-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'appBar',
      typeLabel: 'PreferredSizeWidget?',
      description: '画面の上の帯',
      control: FixedControl(
        value: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('ホーム'),
        ),
        source: "AppBar(title: Text('ホーム'))",
      ),
    ),
    const PropertySpec(
      name: 'body',
      typeLabel: 'Widget?',
      description: '本文。上下の帯の間の広さいっぱいに置かれる',
      control: FixedControl(
        value: Center(child: Text('本文')),
        source: "Center(child: Text('本文'))",
      ),
    ),
    const PropertySpec(
      name: 'floatingActionButton',
      typeLabel: 'Widget?',
      description: '本文の上に浮かせるボタン。既定は右下',
      control: FixedControl(
        value: FloatingActionButton(onPressed: _noop, child: Icon(Icons.add)),
        source:
            'FloatingActionButton(onPressed: () {}, child: Icon(Icons.add))',
      ),
    ),
    PropertySpec(
      name: 'floatingActionButtonLocation',
      typeLabel: 'FloatingActionButtonLocation?',
      description: '浮いたボタンの位置。指定しないと endFloat（右下）',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          for (final (name, value) in const [
            ('endFloat', FloatingActionButtonLocation.endFloat),
            ('centerFloat', FloatingActionButtonLocation.centerFloat),
            ('startFloat', FloatingActionButtonLocation.startFloat),
            ('endDocked', FloatingActionButtonLocation.endDocked),
          ])
            Choice(name, value, 'FloatingActionButtonLocation.$name'),
        ],
      ),
    ),
    PropertySpec(
      name: 'bottomNavigationBar',
      typeLabel: 'Widget?',
      description: '画面の下の帯。ふつうは NavigationBar',
      initiallyOn: false,
      control: FixedControl(
        value: NavigationBar(
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'ホーム'),
            NavigationDestination(icon: Icon(Icons.settings), label: '設定'),
          ],
        ),
        source:
            'NavigationBar(destinations: '
            "[NavigationDestination(icon: Icon(Icons.home), label: 'ホーム'), "
            "NavigationDestination(icon: Icon(Icons.settings), label: '設定')])",
      ),
    ),
    PropertySpec(
      name: 'backgroundColor',
      typeLabel: 'Color?',
      description: '画面の地の色。指定しないとテーマの surface',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('卯の花', const Color(0xFFF7FCFE)),
          Choice.color('桜', const Color(0xFFFEF4F4)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
        ],
      ),
    ),
  ],
  build: _build,
  codeName: 'Scaffold',
);

void _noop() {}

Widget _build(DemoArgs args) => DemoStage(
  size: const Size(240, 400),
  // 詳細画面の上下の余白（ステータスバーなど）を取らない小さな画面にする
  child: Builder(
    builder: (context) => MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      child: Scaffold(
        appBar: args.valueOf<PreferredSizeWidget>('appBar'),
        body: args.valueOf<Widget>('body'),
        floatingActionButton: args.valueOf<Widget>('floatingActionButton'),
        floatingActionButtonLocation: args
            .valueOf<FloatingActionButtonLocation>(
              'floatingActionButtonLocation',
            ),
        bottomNavigationBar: args.valueOf<Widget>('bottomNavigationBar'),
        backgroundColor: args.valueOf<Color>('backgroundColor'),
      ),
    ),
  ),
);

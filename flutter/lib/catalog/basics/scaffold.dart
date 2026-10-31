import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_stage.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
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
      group: PropertyGroup.content,
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
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '本文。上下の帯の間の広さいっぱいに置かれる',
      control: FixedControl(
        value: Center(child: Text('本文')),
        source: "Center(child: Text('本文'))",
      ),
    ),
    const PropertySpec(
      name: 'floatingActionButton',
      group: PropertyGroup.content,
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
      group: PropertyGroup.layout,
      typeLabel: 'FloatingActionButtonLocation?',
      description: '浮いたボタンの位置。指定しないと endFloat（右下）',
      requires: 'floatingActionButton',
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
      group: PropertyGroup.content,
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
      group: PropertyGroup.paint,
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
    const PropertySpec(
      name: 'persistentFooterButtons',
      group: PropertyGroup.content,
      typeLabel: 'List<Widget>?',
      description: '本文の下、下の帯の上に、いつも出しておくボタンの並び',
      initiallyOn: false,
      control: FixedControl(
        value: <Widget>[TextButton(onPressed: _noop, child: Text('閉じる'))],
        source: "[TextButton(onPressed: () {}, child: Text('閉じる'))]",
      ),
    ),
    const PropertySpec(
      name: 'persistentFooterAlignment',
      group: PropertyGroup.layout,
      typeLabel: 'AlignmentDirectional',
      description: 'persistentFooterButtons の並びの位置。既定は右寄せ（centerEnd）',
      initiallyOn: false,
      requires: 'persistentFooterButtons',
      control: ChoiceControl(
        choices: [
          Choice(
            'centerStart',
            AlignmentDirectional.centerStart,
            'AlignmentDirectional.centerStart',
          ),
          Choice(
            'center',
            AlignmentDirectional.center,
            'AlignmentDirectional.center',
          ),
          Choice(
            'centerEnd',
            AlignmentDirectional.centerEnd,
            'AlignmentDirectional.centerEnd',
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'persistentFooterDecoration',
      group: PropertyGroup.paint,
      typeLabel: 'BoxDecoration?',
      description: 'persistentFooterButtons の並びの地に描く飾り。既定は上に区切りの線',
      initiallyOn: false,
      requires: 'persistentFooterButtons',
      control: ChoiceControl(
        choices: [
          Choice(
            '山吹の地',
            BoxDecoration(color: Color(0xFFF8B500)),
            'BoxDecoration(color: Color(0xFFF8B500))',
          ),
          Choice(
            '紅の上線',
            BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFD7003A), width: 3),
              ),
            ),
            'BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFD7003A), width: 3)))',
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'drawer',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '左の端から引き出す引き出し。左端から右へなぞると開く',
      initiallyOn: false,
      control: FixedControl(
        value: Drawer(child: Center(child: Text('メニュー'))),
        source: "Drawer(child: Center(child: Text('メニュー')))",
      ),
    ),
    const PropertySpec(
      name: 'endDrawer',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '右の端から引き出す引き出し。右端から左へなぞると開く',
      initiallyOn: false,
      control: FixedControl(
        value: Drawer(child: Center(child: Text('設定'))),
        source: "Drawer(child: Center(child: Text('設定')))",
      ),
    ),
    const PropertySpec(
      name: 'drawerEnableOpenDragGesture',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: '端からなぞって drawer を開けるか',
      initiallyOn: false,
      requires: 'drawer',
      control: SwitchControl(initialValue: false),
    ),
    const PropertySpec(
      name: 'endDrawerEnableOpenDragGesture',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: '端からなぞって endDrawer を開けるか',
      initiallyOn: false,
      requires: 'endDrawer',
      control: SwitchControl(initialValue: false),
    ),
    const PropertySpec(
      name: 'drawerBarrierDismissible',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: '引き出しを開いているとき、まわりの暗い所を押して閉じられるか',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'drawerScrimColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '引き出しを開いているときに、本文にかぶせる色。既定は半透明の黒',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅（半透明）', const Color(0x66D7003A)),
          Choice.color('瑠璃（半透明）', const Color(0x661E50A2)),
        ],
      ),
    ),
    const PropertySpec(
      name: 'bottomSheet',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '本文の下に、いつも出しておくシート',
      initiallyOn: false,
      control: FixedControl(
        value: ColoredBox(
          color: Color(0xFFE8ECEF),
          child: SizedBox(height: 40, child: Center(child: Text('シート'))),
        ),
        source: "ColoredBox(color: Color(0xFFE8ECEF), child: SizedBox(height: 40, child: Center(child: Text('シート'))))",
      ),
    ),
    const PropertySpec(
      name: 'extendBody',
      group: PropertyGroup.layout,
      typeLabel: 'bool',
      description:
          '本文を、下の帯（bottomNavigationBar・persistentFooterButtons）の後ろまで広げるか',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'extendBodyBehindAppBar',
      group: PropertyGroup.layout,
      typeLabel: 'bool',
      description: '本文を、上の帯（appBar）の後ろまで広げるか',
      initiallyOn: false,
      requires: 'appBar',
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
      name: 'floatingActionButtonAnimator',
      typeLabel: 'FloatingActionButtonAnimator?',
      description: '浮いたボタンの位置を変えたときの動き方',
    ),
    ReferenceArg(
      name: 'onDrawerChanged',
      typeLabel: 'DrawerCallback?',
      description: 'drawer が開いたとき・閉じたときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onEndDrawerChanged',
      typeLabel: 'DrawerCallback?',
      description: 'endDrawer が開いたとき・閉じたときに呼ばれる',
    ),
    ReferenceArg(
      name: 'resizeToAvoidBottomInset',
      typeLabel: 'bool?',
      description: 'キーボードが出たときに、本文を縮めて隠れないようにするか。見本ではキーボードが出ない',
    ),
    ReferenceArg(
      name: 'primary',
      typeLabel: 'bool',
      description: '画面のいちばん上に置くか。上の帯がステータスバーの分の余白を取る。見本ではステータスバーの余白を消している',
    ),
    ReferenceArg(
      name: 'drawerDragStartBehavior',
      typeLabel: 'DragStartBehavior',
      description: '引き出しをなぞって動かし始める時点。指が触れたときか、動き出したときか',
    ),
    ReferenceArg(
      name: 'bottomSheetScrimBuilder',
      typeLabel: 'Widget? Function(BuildContext, Animation<double>)',
      description: 'ボトムシートを広げたときに、本文にかぶせる Widget を作る',
    ),
    ReferenceArg(
      name: 'drawerEdgeDragWidth',
      typeLabel: 'double?',
      description: '引き出しを開くためになぞれる、端からの幅',
    ),
    ReferenceArg(
      name: 'restorationId',
      typeLabel: 'String?',
      description: 'アプリを作り直したあとに、引き出しの開き具合を戻すための名前',
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
        persistentFooterButtons: args.valueOf<List<Widget>>(
          'persistentFooterButtons',
        ),
        persistentFooterAlignment:
            args.valueOf<AlignmentDirectional>('persistentFooterAlignment') ??
            AlignmentDirectional.centerEnd,
        persistentFooterDecoration: args.valueOf<BoxDecoration>(
          'persistentFooterDecoration',
        ),
        drawer: args.valueOf<Widget>('drawer'),
        endDrawer: args.valueOf<Widget>('endDrawer'),
        drawerEnableOpenDragGesture:
            args.valueOf<bool>('drawerEnableOpenDragGesture') ?? true,
        endDrawerEnableOpenDragGesture:
            args.valueOf<bool>('endDrawerEnableOpenDragGesture') ?? true,
        drawerBarrierDismissible:
            args.valueOf<bool>('drawerBarrierDismissible') ?? true,
        drawerScrimColor: args.valueOf<Color>('drawerScrimColor'),
        bottomSheet: args.valueOf<Widget>('bottomSheet'),
        extendBody: args.valueOf<bool>('extendBody') ?? false,
        extendBodyBehindAppBar:
            args.valueOf<bool>('extendBodyBehindAppBar') ?? false,
      ),
    ),
  ),
);

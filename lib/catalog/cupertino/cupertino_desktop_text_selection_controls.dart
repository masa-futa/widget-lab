import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_text_field.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoDesktopTextSelectionControlsEntry = WidgetEntry(
  id: 'cupertinoDesktopTextSelectionControls',
  name: 'CupertinoDesktopTextSelectionControls',
  genreIds: const ['cupertino'],
  summary: '文字を選んだときのつまみとメニューを macOS の見た目にする',
  description:
      'Widget ではなく、入力欄の selectionControls に渡すクラスです。文字を選んだときに'
      'つまみ（ハンドル）を出さず、メニューを macOS の縦に並ぶ見た目で描きます。'
      'CupertinoTextField は macOS では指定しなくてもこの見た目なので、違いが出るのは'
      'iOS・Android です（プレビューの文字をダブルタップで選ぶと、つまみが出なくなる）。'
      '入力欄のほかの引数は、CupertinoTextField の収録で触れます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoDesktopTextSelectionControls-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'selectionControls',
      group: PropertyGroup.behavior,
      typeLabel: 'TextSelectionControls?',
      description: '文字を選んだときのつまみとメニューを描くもの。指定しないと端末に合わせる',
      control: FixedControl(
        value: CupertinoDesktopTextSelectionControls(),
        source: 'CupertinoDesktopTextSelectionControls()',
      ),
    ),
  ],
  // 入力欄そのものの引数は CupertinoTextField の収録で触れるので、ここでは補足に載せる
  references: textFieldArgsAsReferences(except: const {'selectionControls'}),
  build: _build,
  codeName: 'CupertinoTextField',
  codeArguments: const ['controller: controller'],
);

Widget _build(DemoArgs args) => _Field(
  selectionControls: args.valueOf<TextSelectionControls>('selectionControls'),
);

/// 最初から文字の入った入力欄（選んで違いを見るため）。controller を持つので State にする。
class _Field extends StatefulWidget {
  const _Field({required this.selectionControls});

  final TextSelectionControls? selectionControls;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  final _controller = TextEditingController(text: 'ダブルタップで語を選べます');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 280,
    child: CupertinoTextField(
      controller: _controller,
      selectionControls: widget.selectionControls,
    ),
  );
}

import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoTextSelectionControlsEntry = WidgetEntry(
  id: 'cupertinoTextSelectionControls',
  name: 'CupertinoTextSelectionControls',
  genreIds: const ['cupertino'],
  summary: '文字を選んだときのつまみとメニューを iOS の見た目にする',
  description:
      'Widget ではなく、入力欄の selectionControls に渡すクラスです。文字を選んだときの'
      'つまみ（ハンドル）とメニューを iOS の見た目で描きます。'
      'CupertinoTextField は iOS・Android では指定しなくても iOS の見た目なので、'
      '違いが出るのは macOS などのデスクトップです（プレビューの文字をダブルタップで選べる）。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoTextSelectionControls-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'selectionControls',
      typeLabel: 'TextSelectionControls?',
      description: '文字を選んだときのつまみとメニューを描くもの。指定しないと端末に合わせる',
      control: FixedControl(
        value: CupertinoTextSelectionControls(),
        source: 'CupertinoTextSelectionControls()',
      ),
    ),
  ],
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

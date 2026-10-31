import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:widget_lab/catalog/demo/demo_recorder.dart';
import 'package:widget_lab/catalog/demo/demo_scope.dart';
import 'package:widget_lab/catalog/demo/rebuild_counter.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final keyboardListenerEntry = WidgetEntry(
  id: 'keyboardListener',
  name: 'KeyboardListener',
  genreIds: const ['input'],
  summary: 'フォーカスを持っている間、押されたキーの出来事を受け取る',
  description:
      'focusNode がフォーカスを持っている間、ハードウェアキーボードのキーを押した・離した・'
      '押し続けた出来事（KeyDownEvent・KeyUpEvent・KeyRepeatEvent）を onKeyEvent で受け取ります。'
      '画面のソフトウェアキーボードの入力は来ません（それは TextField で受けます）。'
      '出来事を受けても子は組み直されません。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/KeyboardListener-class.html',
  ),
  kind: EntryKind.behavior,
  properties: const [
    PropertySpec(
      name: 'focusNode',
      group: PropertyGroup.behavior,
      typeLabel: 'FocusNode',
      description: 'キーを受けるためのフォーカス。State に持ち、dispose で捨てる',
      required: true,
      control: FixedControl(value: true, source: '_focusNode'),
    ),
    PropertySpec(
      name: 'autofocus',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: '開いたときに自分でフォーカスを取るか。false なら枠を押すとフォーカスを取る',
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'onKeyEvent',
      group: PropertyGroup.behavior,
      typeLabel: 'ValueChanged<KeyEvent>?',
      description: 'キーの出来事が来たときに呼ばれる。ここではログに出す',
      control: FixedControl(value: true, source: '(event) => log(event)'),
    ),
    PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget',
      description: 'キーを受ける間に描く Widget。ここでは押してほしいキーの案内',
      required: true,
      control: FixedControl(value: _KeyPad(), source: 'const KeyPad()'),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'includeSemantics',
      typeLabel: 'bool',
      description: '読み上げの情報にフォーカスの状態を含めるか。既定は true',
    ),
  ],
  build: _build,
  buildWithout: _buildWithout,
  codeName: 'KeyboardListener',
);

Widget _build(DemoArgs args) {
  final autofocus = args.valueOf<bool>('autofocus') ?? false;
  final listens = args.valueOf<bool>('onKeyEvent') ?? false;
  final values = [
    'focusNode',
    if (autofocus) 'autofocus: true',
    if (listens) 'onKeyEvent',
  ];
  return DemoScope(
    label: 'KeyboardListener(${values.join(', ')})',
    child: _ListenerDemo(autofocus: autofocus, listens: listens),
  );
}

/// 包みを外す。キーを押しても誰も受けないので、ログには何も出ない。
Widget _buildWithout(DemoArgs args) => const DemoFit(child: _KeyPad());

/// FocusNode を State に持ち、KeyboardListener に渡す。
class _ListenerDemo extends StatefulWidget {
  const _ListenerDemo({required this.autofocus, required this.listens});

  final bool autofocus;

  /// onKeyEvent を渡すか。
  final bool listens;

  @override
  State<_ListenerDemo> createState() => _ListenerDemoState();
}

class _ListenerDemoState extends State<_ListenerDemo> {
  final _focusNode = FocusNode(debugLabel: 'KeyboardListener のデモ');

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 出来事は木を作り直している途中にも来うるので、窓口は build のうちに引いておく
    final recorder = DemoRecorder.of(context);
    return GestureDetector(
      // 枠を押したらフォーカスを取る（autofocus が false のとき用）
      onTap: _focusNode.requestFocus,
      child: KeyboardListener(
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        onKeyEvent: widget.listens
            ? (event) => recorder.log(_describe(event))
            : null,
        child: const _KeyPad(),
      ),
    );
  }
}

/// ログに出すキーの出来事の文（例: `KeyDownEvent: A`）。
/// ビルドの設定で型の名前が変わっても、ログの文が変わらないように書き出す。
String _describe(KeyEvent event) {
  final type = switch (event) {
    KeyDownEvent() => 'KeyDownEvent',
    KeyUpEvent() => 'KeyUpEvent',
    KeyRepeatEvent() => 'KeyRepeatEvent',
    // KeyEvent は sealed ではないので、ほかのサブクラスに備える
    _ => 'KeyEvent',
  };
  return '$type: ${event.logicalKey.keyLabel}';
}

/// KeyboardListener の下に置く子。const にして、出来事を受けても組み直されないことを回数で見せる。
class _KeyPad extends StatelessWidget {
  const _KeyPad();

  @override
  Widget build(BuildContext context) => RebuildCounter(
    label: 'キーを受ける枠',
    builder: (context) => const Text('ハードウェアキーボードのキーを押す'),
  );
}

import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_recorder.dart';
import 'package:widget_lab/catalog/demo/demo_scope.dart';
import 'package:widget_lab/catalog/demo/rebuild_counter.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// 選べるアセット（名前・場所・アセットにしない場合にコードへ書く文）。
const _assets = [
  ('greeting.txt', 'assets/demo/greeting.txt', 'こんにちは。これはアセットの文です。'),
  ('haiku.txt', 'assets/demo/haiku.txt', '古池や\n蛙飛び込む\n水の音'),
  ('ない名前', 'assets/demo/missing.txt', null),
];

final assetBundleEntry = WidgetEntry(
  id: 'assetBundle',
  name: 'AssetBundle',
  genreIds: const ['assets'],
  summary: 'アプリに同梱したファイル（アセット）を読む',
  description:
      'pubspec.yaml の assets に書いたファイルを、名前で読みます。'
      '読み込みは非同期なので、届くまでは「読み込み中」を出します。'
      'Image.asset もこの仕組みで読みます。'
      'DefaultAssetBundle.of(context) で読むと、テストで差し替えられます（rootBundle はアプリの束）。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/services/AssetBundle-class.html',
  ),
  kind: EntryKind.behavior,
  properties: [
    PropertySpec(
      name: 'key',
      group: PropertyGroup.content,
      typeLabel: 'String',
      description: '読むアセットの名前。ない名前だと読み込みに失敗します。',
      required: true,
      arg: PropertyArg.positional,
      control: ChoiceControl(
        choices: [
          for (final (label, key, _) in _assets) Choice(label, key, "'$key'"),
        ],
      ),
    ),
  ],
  build: _build,
  buildWithout: _buildWithout,
  codeName: 'await DefaultAssetBundle.of(context).loadString',
  codeWithout: _codeWithout,
);

/// 使わない場合のよくある書き方。文をコードの中に書いておく（変えるにはアプリを作り直す）。
const _codeWithout = '''
const greeting = 'こんにちは。これはアセットの文です。';

Text(greeting)''';

Widget _build(DemoArgs args) {
  // 必須のプロパティなので、常に値がある
  final key = args.valueOf<String>('key')!;
  return DemoScope(
    label: "loadString('${key.split('/').last}')",
    child: _Loader(assetKey: key),
  );
}

/// 使わない側。文はコードに書いてあるので、読み込まずにすぐ出る。
Widget _buildWithout(DemoArgs args) {
  final key = args.valueOf<String>('key')!;
  final text = _assets.firstWhere((a) => a.$2 == key).$3;
  return DemoFit(
    child: RebuildCounter(
      label: '文を出す子',
      builder: (context) => Text(text ?? '（コードに書いた文はありません）'),
    ),
  );
}

/// [assetKey] のアセットを読み、読めたら文を出す。読み込みの始まりと終わりをログに出す。
class _Loader extends StatefulWidget {
  const _Loader({required this.assetKey});

  final String assetKey;

  @override
  State<_Loader> createState() => _LoaderState();
}

sealed class _Loading {
  const _Loading();
}

final class _Waiting extends _Loading {
  const _Waiting();
}

final class _Loaded extends _Loading {
  const _Loaded(this.text);

  final String text;
}

final class _Failed extends _Loading {
  const _Failed();
}

class _LoaderState extends State<_Loader> {
  _Loading _loading = const _Waiting();
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // DefaultAssetBundle.of は依存を作るので、initState ではなくここで最初に読む
    if (!_started) {
      _started = true;
      _load();
    }
  }

  @override
  void didUpdateWidget(_Loader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetKey != widget.assetKey) _load();
  }

  void _load() {
    final key = widget.assetKey;
    final recorder = DemoRecorder.of(context)..log('読み込み開始: $key');
    _loading = const _Waiting();
    DefaultAssetBundle.of(context)
        .loadString(key)
        .then(
          (text) {
            if (!mounted || widget.assetKey != key) return;
            recorder.log('読み込み完了: ${text.length} 文字');
            setState(() => _loading = _Loaded(text));
          },
          onError: (Object _) {
            if (!mounted || widget.assetKey != key) return;
            recorder.log('読み込みに失敗: $key はありません');
            setState(() => _loading = const _Failed());
          },
        );
  }

  @override
  Widget build(BuildContext context) => RebuildCounter(
    label: '文を出す子',
    builder: (context) => Text(switch (_loading) {
      _Waiting() => '読み込み中…',
      _Loaded(:final text) => text,
      _Failed() => '読めませんでした',
    }),
  );
}

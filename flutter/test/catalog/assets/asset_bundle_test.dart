import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/assets/asset_bundle.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';

import '../demo_pump.dart';

/// greeting.txt だけを持つ束。ほかの名前は読めない。
final class _FakeBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key != 'assets/demo/greeting.txt') {
      throw FlutterError('Unable to load asset: "$key".');
    }
    final bytes = utf8.encode('アセットの文');
    return ByteData.sublistView(Uint8List.fromList(bytes));
  }
}

void main() {
  DemoArgs argsFor(int index) => DemoArgs(assetBundleEntry, {
    'key': PropertySetting(on: true, value: ChoiceValue(index)),
  });

  testWidgets('AssetBundle: 読み込み中を出してから、読めた文を出す（組み直しは 2 回）', (tester) async {
    final recorder = await pumpDemo(
      tester,
      DefaultAssetBundle(
        bundle: _FakeBundle(),
        child: assetBundleEntry.build(argsFor(0)),
      ),
    );
    expect(find.text('読み込み中…'), findsOneWidget);

    await tester.pump();

    expect(find.text('アセットの文'), findsOneWidget);
    expect(recorder.logs, ['読み込み開始: assets/demo/greeting.txt', '読み込み完了: 6 文字']);
    expect(recorder.buildsOf('文を出す子'), 2);
  });

  testWidgets('AssetBundle: ない名前は読み込みに失敗する', (tester) async {
    final recorder = await pumpDemo(
      tester,
      DefaultAssetBundle(
        bundle: _FakeBundle(),
        child: assetBundleEntry.build(argsFor(2)),
      ),
    );
    await tester.pump();

    expect(find.text('読めませんでした'), findsOneWidget);
    expect(recorder.logs.last, '読み込みに失敗: assets/demo/missing.txt はありません');
  });

  testWidgets('AssetBundle: 使わない側はコードに書いた文をすぐ出す', (tester) async {
    final recorder = await pumpDemo(
      tester,
      assetBundleEntry.buildWithout!(argsFor(0)),
    );

    expect(find.text('こんにちは。これはアセットの文です。'), findsOneWidget);
    expect(recorder.logs, isEmpty);
  });

  test('デモで読むアセットが同梱されている', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    for (final key in ['assets/demo/greeting.txt', 'assets/demo/haiku.txt']) {
      expect(await rootBundle.loadString(key), isNotEmpty, reason: key);
    }
    final image = await rootBundle.load('assets/demo/landscape.png');
    expect(image.lengthInBytes, greaterThan(0));
  });
}

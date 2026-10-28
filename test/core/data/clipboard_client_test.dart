import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/core/data/clipboard_client.dart';

void main() {
  test('文字をクリップボードに書けたら true', () async {
    ClipboardData? written;
    final client = SystemClipboardClient(
      setData: (data) async => written = data,
    );

    expect(await client.setText('Padding()'), isTrue);
    expect(written?.text, 'Padding()');
  });

  test('クリップボードに書けなければ false', () async {
    final client = SystemClipboardClient(
      setData: (data) async => throw PlatformException(code: 'denied'),
    );

    expect(await client.setText('Padding()'), isFalse);
  });

  test('プラグインがないなど、ほかの例外でも false', () async {
    final client = SystemClipboardClient(
      setData: (data) async => throw MissingPluginException(),
    );

    expect(await client.setText('Padding()'), isFalse);
  });
}

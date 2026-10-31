import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:widget_lab/core/data/url_launcher_client.dart';

void main() {
  final url = Uri.parse(
    'https://api.flutter.dev/flutter/widgets/Padding-class.html',
  );

  test('外部のブラウザで開き、開けたら true', () async {
    Uri? opened;
    LaunchMode? usedMode;
    final client = SystemUrlLauncherClient(
      launch: (url, {mode = LaunchMode.platformDefault}) async {
        opened = url;
        usedMode = mode;
        return true;
      },
    );

    expect(await client.open(url), isTrue);
    expect(opened, url);
    expect(usedMode, LaunchMode.externalApplication);
  });

  test('開けなければ false', () async {
    final client = SystemUrlLauncherClient(
      launch: (url, {mode = LaunchMode.platformDefault}) async => false,
    );

    expect(await client.open(url), isFalse);
  });

  test('開くときに例外が出ても false', () async {
    final client = SystemUrlLauncherClient(
      launch: (url, {mode = LaunchMode.platformDefault}) async =>
          throw PlatformException(code: 'ACTIVITY_NOT_FOUND'),
    );

    expect(await client.open(url), isFalse);
  });

  test('プラグインがないなど、ほかの例外でも false', () async {
    final client = SystemUrlLauncherClient(
      launch: (url, {mode = LaunchMode.platformDefault}) async =>
          throw MissingPluginException(),
    );

    expect(await client.open(url), isFalse);
  });

  test('https でない URL は開かずに false', () async {
    var launched = false;
    final client = SystemUrlLauncherClient(
      launch: (url, {mode = LaunchMode.platformDefault}) async =>
          launched = true,
    );

    for (final other in [
      'http://api.flutter.dev/',
      'tel:0120000000',
      'javascript:alert(1)',
      'intent://scan/#Intent;scheme=zxing;end',
    ]) {
      expect(await client.open(Uri.parse(other)), isFalse, reason: other);
    }
    expect(launched, isFalse);
  });
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'url_launcher_client.g.dart';

typedef LaunchUrl = Future<bool> Function(Uri url, {LaunchMode mode});

/// URL を外部のブラウザで開く。テストでは fake に差し替える。
abstract interface class UrlLauncherClient {
  /// [url] を開く。https でない・開けなければ `false`。
  Future<bool> open(Uri url);
}

class SystemUrlLauncherClient implements UrlLauncherClient {
  const SystemUrlLauncherClient({this._launch = _launchUrl});

  final LaunchUrl _launch;

  @override
  Future<bool> open(Uri url) async {
    // 開くのは公式ドキュメントだけ。ほかのアプリを起動するスキームは通さない
    if (url.scheme != 'https') return false;
    try {
      return await _launch(url, mode: LaunchMode.externalApplication);
    } on Exception {
      return false;
    }
  }
}

Future<bool> _launchUrl(
  Uri url, {
  LaunchMode mode = LaunchMode.platformDefault,
}) => launchUrl(url, mode: mode);

@Riverpod(keepAlive: true)
UrlLauncherClient urlLauncherClient(Ref ref) => const SystemUrlLauncherClient();

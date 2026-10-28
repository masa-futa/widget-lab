import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clipboard_client.g.dart';

/// クリップボードへの書き込み。テストでは fake に差し替える。
abstract interface class ClipboardClient {
  /// [text] を書く。書けなければ `false`。
  Future<bool> setText(String text);
}

class SystemClipboardClient implements ClipboardClient {
  const SystemClipboardClient({this._setData = Clipboard.setData});

  final Future<void> Function(ClipboardData data) _setData;

  @override
  Future<bool> setText(String text) async {
    try {
      await _setData(ClipboardData(text: text));
      return true;
    } on Exception {
      return false;
    }
  }
}

@Riverpod(keepAlive: true)
ClipboardClient clipboardClient(Ref ref) => const SystemClipboardClient();

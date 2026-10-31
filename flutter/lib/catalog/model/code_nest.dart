/// コードで、値をコンストラクタの引数ではなく入れ子の式の中に書くときの書き方。
///
/// 例: `data: MediaQuery.of(context).copyWith(textScaler: …)` は
/// `CodeNest(name: 'data', receiver: 'MediaQuery.of(context)')`。
/// `PropertyArg.nested` のプロパティ（ON のもの）を `{receiver}.{method}(` の中に 1 行ずつ書き、
/// 1 つもなければ `{name}: {receiver},` の 1 行にする。
final class CodeNest {
  const CodeNest({
    required this.name,
    required this.receiver,
    this.method = 'copyWith',
  });

  /// 引数の名前（例: `data`）。
  final String name;

  /// 元にする式（例: `MediaQuery.of(context)`）。
  final String receiver;

  /// 値を渡すメソッド（例: `copyWith`）。
  final String method;
}

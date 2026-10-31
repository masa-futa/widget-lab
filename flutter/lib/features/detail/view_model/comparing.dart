/// 何を比べているか。`null`（比較していない）とあわせて `DetailState.comparing` に持つ。
sealed class Comparing {
  const Comparing();
}

/// 見た目を持つ Widget。[name] のプロパティ（入れ子なら中の [child]）を付けた／付けないで比べる。
final class ComparingProperty extends Comparing {
  const ComparingProperty(this.name, {this.child});

  final String name;

  /// 入れ子のプロパティの中で比べる子。`null` はプロパティそのもの。
  final String? child;

  @override
  bool operator ==(Object other) =>
      other is ComparingProperty && other.name == name && other.child == child;

  @override
  int get hashCode => Object.hash(name, child);

  @override
  String toString() => 'ComparingProperty($name, child: $child)';
}

/// 見た目を持たない Widget。Widget そのものを使った／使わないで比べる。
final class ComparingUse extends Comparing {
  const ComparingUse();

  @override
  bool operator ==(Object other) => other is ComparingUse;

  @override
  int get hashCode => (ComparingUse).hashCode;

  @override
  String toString() => 'ComparingUse()';
}

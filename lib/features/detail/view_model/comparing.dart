/// 何を比べているか。`null`（比較していない）とあわせて `DetailState.comparing` に持つ。
sealed class Comparing {
  const Comparing();
}

/// 見た目を持つ Widget。[name] のプロパティを付けた／付けないで比べる。
final class ComparingProperty extends Comparing {
  const ComparingProperty(this.name);

  final String name;

  @override
  bool operator ==(Object other) =>
      other is ComparingProperty && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'ComparingProperty($name)';
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

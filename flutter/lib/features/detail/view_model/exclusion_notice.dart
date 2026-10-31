/// 同時には使えない相手を OFF にした知らせ（編集パネルに 3 秒ほど出す）。
final class ExclusionNotice {
  const ExclusionNotice({required this.turnedOn, required this.turnedOff});

  final String turnedOn;
  final String turnedOff;

  @override
  bool operator ==(Object other) =>
      other is ExclusionNotice &&
      other.turnedOn == turnedOn &&
      other.turnedOff == turnedOff;

  @override
  int get hashCode => Object.hash(turnedOn, turnedOff);

  @override
  String toString() => 'ExclusionNotice($turnedOn, off: $turnedOff)';
}

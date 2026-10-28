import 'package:flutter/widgets.dart';

/// 見た目を持つ Widget のデモで子に使う、番号つきの色の箱。コードでは `Tile(n)` と書く。
///
/// 色は Container の色見本（瑠璃・山吹・若竹・紅・墨）を番号の順に使う。
/// [width]・[height] を省くと、使える広さいっぱいに広がる（上限がなければ番号の大きさ）。
class DemoTile extends StatelessWidget {
  const DemoTile(this.number, {this.width, this.height, super.key});

  /// 箱の色。番号の順に使う。
  static const colors = [
    Color(0xFF1E50A2),
    Color(0xFFF8B500),
    Color(0xFF68BE8D),
    Color(0xFFD7003A),
    Color(0xFF18181B),
  ];

  /// 地が明るい色（山吹・若竹）は墨の文字、ほかは白の文字にする。
  static const _inks = [
    Color(0xFFFFFFFF),
    Color(0xFF18181B),
    Color(0xFF18181B),
    Color(0xFFFFFFFF),
    Color(0xFFFFFFFF),
  ];

  final int number;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final index = (number - 1) % colors.length;
    return Container(
      width: width,
      height: height,
      color: colors[index],
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            color: _inks[index],
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

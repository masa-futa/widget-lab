import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/catalog.dart';

/// 厳しく見る収録（段 2 で全件にしたら、この集合をやめて全件を厳しく見る）。
const _strict = {'Container'};

/// Flutter SDK のソースから、[className] の名前なしのコンストラクタの引数の名前を読む。
/// 読めなければ `null`。原因は、クラス名でない収録（Common buttons など）、
/// SDK のソースに見つからないクラス、クラス本体が通常の形でない、
/// 名前なしのコンストラクタを持たない（named / factory のみ）のいずれか。
Set<String>? _constructorParameters(String className, Map<String, File> index) {
  final file = index[className];
  if (file == null) return null;
  final unit = parseString(
    content: file.readAsStringSync(),
    path: file.path,
  ).unit;
  for (final declaration in unit.declarations.whereType<ClassDeclaration>()) {
    if (declaration.namePart.typeName.lexeme != className) continue;
    final body = declaration.body;
    if (body is! BlockClassBody) return null;
    final constructor = body.members
        .whereType<ConstructorDeclaration>()
        .where((c) => c.name == null)
        .firstOrNull;
    if (constructor == null) return null;
    return {
      for (final parameter in constructor.parameters.parameters)
        if (parameter.name case final name?) name.lexeme,
    };
  }
  return null;
}

void main() {
  final root = Platform.environment['FLUTTER_ROOT'];
  final index = <String, File>{};
  final classPattern = RegExp(
    r'^(?:abstract |base |final |sealed )*class (\w+)',
    multiLine: true,
  );
  setUpAll(() {
    for (final library in ['widgets', 'material', 'cupertino']) {
      final dir = Directory('$root/packages/flutter/lib/src/$library');
      for (final file in dir.listSync(recursive: true).whereType<File>()) {
        if (!file.path.endsWith('.dart')) continue;
        for (final match in classPattern.allMatches(file.readAsStringSync())) {
          index.putIfAbsent(match.group(1)!, () => file);
        }
      }
    }
  });

  test('FLUTTER_ROOT がある（flutter test が渡す）', () => expect(root, isNotNull));

  group('TC-90: コンストラクタの引数は、プロパティか補足のどちらかに入っている', () {
    for (final entry in allEntries) {
      test('${entry.codeName}（${entry.name}）', () {
        final parameters = _constructorParameters(entry.codeName, index);
        if (parameters == null) {
          if (_strict.contains(entry.codeName)) {
            fail(
              '厳しく見る収録のクラスのコンストラクタが Flutter SDK のソースで見つからない: ${entry.codeName}',
            );
          }
          return markTestSkipped(
            '名前なしのコンストラクタを SDK のソースで見つけられない（${entry.name}）',
          );
        }
        final covered = {
          for (final spec in entry.properties) spec.name,
          for (final reference in entry.references) reference.name,
        };
        final missing = parameters.difference(covered);
        if (!_strict.contains(entry.codeName) && missing.isNotEmpty) {
          return markTestSkipped(
            '抜け ${missing.length} 件（段 2 で埋める）: ${missing.join(', ')}',
          );
        }
        expect(missing, isEmpty);
      });
    }
  });
}

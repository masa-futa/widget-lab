import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/catalog.dart';

/// SDK のコンストラクタの呼び出しでない収録と、その理由。ここにある収録は突き合わせない。
const _notSdkConstructor = {
  'await DefaultAssetBundle.of(context).loadString': '読み込みのメソッドの呼び出し',
  'listKey.currentState!.insertItem': 'State のメソッドの呼び出し',
  'SpinningLogo': '抽象クラスを継いだ見本の自作クラス（AnimatedWidget）',
  'AnimatedRadius': '抽象クラスを継いだ見本の自作クラス（ImplicitlyAnimatedWidget）',
};

/// `Foo`・`Foo<int>`・`Foo.named`・`Foo<int>.named` を、クラス名とコンストラクタ名に分ける。
final _codeNamePattern = RegExp(r'^([A-Z]\w*)(?:<.*>)?(?:\.(\w+))?$');

/// Flutter SDK のソースから、[codeName] のコンストラクタの引数の名前を読む。
/// 読めなければ `null`。原因は、式の収録（`_notSdkConstructor`）、
/// SDK のソースに見つからないクラス、クラス本体が通常の形でない、
/// そのコンストラクタを持たないのいずれか。
Set<String>? _constructorParameters(String codeName, Map<String, File> index) {
  final match = _codeNamePattern.firstMatch(codeName);
  if (match == null) return null;
  final className = match.group(1)!;
  final constructorName = match.group(2);
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
        .where((c) => c.name?.lexeme == constructorName)
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
        if (_notSdkConstructor.containsKey(entry.codeName)) {
          // 突き合わせない理由が今も正しい（SDK のコンストラクタとして読めない）
          expect(parameters, isNull);
          return;
        }
        if (parameters == null) {
          fail('コンストラクタが Flutter SDK のソースで見つからない: ${entry.codeName}');
        }
        final covered = {
          for (final spec in entry.properties) spec.name,
          for (final reference in entry.references) reference.name,
        };
        final missing = parameters.difference(covered);
        expect(missing, isEmpty, reason: '抜けている引数: ${missing.join(', ')}');
      });
    }
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/padding.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';
import 'package:widget_lab/core/theme/app_theme.dart';
import 'package:widget_lab/features/catalog/ui/widgets/entry_sample.dart';

import '../../fake_catalog_repository.dart';

Future<void> _pumpSample(WidgetTester tester, WidgetEntry entry) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: Center(child: EntrySample(entry: entry)),
      ),
    ),
  );
}

void main() {
  testWidgets('TC-69: 見本は最初の値で組み立てた Widget を 64×64 に縮めて置く', (tester) async {
    final entry = fakeEntry(
      'Wide',
      ['basics'],
      build: (args) => const SizedBox(key: Key('demo'), width: 320, height: 32),
    );
    await _pumpSample(tester, entry);

    expect(tester.getSize(find.byType(EntrySample)), const Size(64, 64));
    final demo = tester.getRect(find.byKey(const Key('demo')));
    expect(demo.width, lessThanOrEqualTo(64));
    expect(demo.height, lessThan(32));
  });

  testWidgets('TC-69: 小さい Widget は拡大しない', (tester) async {
    final entry = fakeEntry(
      'Small',
      ['basics'],
      build: (args) => const SizedBox(key: Key('demo'), width: 16, height: 16),
    );
    await _pumpSample(tester, entry);

    expect(tester.getSize(find.byKey(const Key('demo'))), const Size(16, 16));
  });

  testWidgets('TC-69: 見本の中は押せず、読み上げない', (tester) async {
    var tapped = false;
    final entry = fakeEntry(
      'Button',
      ['basics'],
      build: (args) =>
          TextButton(onPressed: () => tapped = true, child: const Text('押す')),
    );
    final handle = tester.ensureSemantics();
    await _pumpSample(tester, entry);

    await tester.tap(find.text('押す'), warnIfMissed: false);
    expect(tapped, isFalse);
    expect(find.bySemanticsLabel('押す'), findsNothing);
    handle.dispose();
  });

  testWidgets('見本の中の部品はフォーカスを取らない', (tester) async {
    final entry = fakeEntry('Field', [
      'input',
    ], build: (args) => const TextField(autofocus: true));
    await _pumpSample(tester, entry);
    await tester.pump();

    expect(tester.testTextInput.isVisible, isFalse);
    expect(
      FocusManager.instance.primaryFocus?.context?.widget,
      isNot(isA<EditableText>()),
    );
  });

  testWidgets('見本の中のアニメーションは止まっている', (tester) async {
    final entry = fakeEntry('Progress', [
      'input',
    ], build: (args) => const CircularProgressIndicator());
    await _pumpSample(tester, entry);

    // 回り続けるアニメーションがあると、ここが時間切れで落ちる。
    await tester.pumpAndSettle();
  });

  testWidgets('TC-69: 組み立てが例外を出す見本は、空の枠になる', (tester) async {
    final entry = fakeEntry('Broken', [
      'basics',
    ], build: (args) => throw StateError('収録データの不備'));
    await _pumpSample(tester, entry);

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(EntrySample)), const Size(64, 64));
  });

  testWidgets('TC-80: 見た目を持たない Widget の見本は account_tree のアイコンで、組み立てず読み上げない', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final entry = fakeEntry(
      'Builder',
      ['basics'],
      kind: EntryKind.behavior,
      build: (args) => const Text('組み立てない'),
    );
    await _pumpSample(tester, entry);

    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon, Icons.account_tree_outlined);
    expect(icon.size, 24);
    expect(find.text('組み立てない'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(EntrySample),
        matching: find.bySemanticsLabel(RegExp('.')),
      ),
      findsNothing,
    );
    semantics.dispose();
  });

  testWidgets('本物の収録データ（Padding）の見本が例外を出さずに組み立つ', (tester) async {
    await _pumpSample(tester, paddingEntry);

    expect(tester.takeException(), isNull);
    expect(find.byType(Padding), findsWidgets);
  });
}

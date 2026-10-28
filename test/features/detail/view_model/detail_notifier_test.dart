import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/basics/container.dart';
import 'package:widget_lab/catalog/basics/text.dart';
import 'package:widget_lab/catalog/layout/padding.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/core/data/catalog_repository.dart';
import 'package:widget_lab/core/data/clipboard_client.dart';
import 'package:widget_lab/core/data/url_launcher_client.dart';
import 'package:widget_lab/features/detail/view_model/code_generator.dart';
import 'package:widget_lab/features/detail/view_model/comparing.dart';
import 'package:widget_lab/features/detail/view_model/detail_notifier.dart';
import 'package:widget_lab/features/detail/view_model/probe_notifier.dart';
import 'package:widget_lab/features/detail/view_model/probe_state.dart';

import '../fakes.dart';

void main() {
  late FakeClipboardClient clipboard;
  late FakeUrlLauncherClient launcher;

  ProviderContainer makeContainer({
    FakeCatalogRepository? repository,
    bool clipboardSucceeds = true,
    bool launcherSucceeds = true,
  }) {
    clipboard = FakeClipboardClient(succeeds: clipboardSucceeds);
    launcher = FakeUrlLauncherClient(succeeds: launcherSucceeds);
    final container = ProviderContainer(
      overrides: [
        catalogRepositoryProvider.overrideWithValue(
          repository ?? FakeCatalogRepository(),
        ),
        clipboardClientProvider.overrideWithValue(clipboard),
        urlLauncherClientProvider.overrideWithValue(launcher),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('開いたとき', () {
    test('受け取った ID の収録データの、最初の設定になる', () {
      final container = makeContainer();

      final state = container.read(detailProvider('padding'));

      expect(state.entry, paddingEntry);
      expect(state.settings, paddingEntry.initialSettings());
      expect(state.comparing, isNull);
      expect(state.isModified, isFalse);
    });

    test('その Widget が載るジャンルを、収録データの順で持つ', () {
      final container = makeContainer();

      final state = container.read(detailProvider('padding'));

      expect(state.genres.map((g) => g.name), ['Layout', 'Styling']);
    });

    test('収録データにない ID なら StateError', () {
      final container = makeContainer();

      expect(
        () => container.read(detailProvider('nothing')),
        throwsA(
          isA<ProviderException>().having(
            (e) => e.exception,
            'exception',
            isA<StateError>(),
          ),
        ),
      );
    });
  });

  group('ON / OFF と値', () {
    test('TC-17: OFF にすると on が false になり、変更ありになる', () {
      final container = makeContainer();
      final notifier = container.read(detailProvider('padding').notifier);

      notifier.propertyToggled('padding', false);

      final state = container.read(detailProvider('padding'));
      expect(state.settings['padding']?.on, isFalse);
      expect(state.isModified, isTrue);
    });

    test('TC-19: 値を変えると settings の値が変わる', () {
      final container = makeContainer();
      final notifier = container.read(detailProvider('padding').notifier);

      notifier.propertyValueChanged('padding', const SliderValue(32));

      expect(
        container.read(detailProvider('padding')).settings['padding'],
        const PropertySetting(on: true, value: SliderValue(32)),
      );
    });

    test('TC-24: 2 つのプロパティを変えると両方が残る', () {
      final container = makeContainer();
      final notifier = container.read(detailProvider('container').notifier);

      notifier
        ..propertyValueChanged('color', const ChoiceValue(2))
        ..propertyValueChanged('padding', const SliderValue(32));

      final settings = container.read(detailProvider('container')).settings;
      expect(settings['color']?.value, const ChoiceValue(2));
      expect(settings['padding']?.value, const SliderValue(32));
    });

    test('TC-25: 32 にしてから OFF → ON に戻すと 32 のまま', () {
      final container = makeContainer();
      final notifier = container.read(detailProvider('padding').notifier);

      notifier
        ..propertyValueChanged('padding', const SliderValue(32))
        ..propertyToggled('padding', false)
        ..propertyToggled('padding', true);

      expect(
        container.read(detailProvider('padding')).settings['padding'],
        const PropertySetting(on: true, value: SliderValue(32)),
      );
    });

    test('TC-26: 必須のプロパティは OFF にできない', () {
      final container = makeContainer();
      final notifier = container.read(detailProvider('text').notifier);

      notifier.propertyToggled('data', false);

      final state = container.read(detailProvider('text'));
      expect(state.settings['data']?.on, isTrue);
      expect(state.isModified, isFalse);
    });

    test('値を最初と同じに戻すと、変更なしに戻る', () {
      final container = makeContainer();
      final notifier = container.read(detailProvider('padding').notifier);

      notifier
        ..propertyValueChanged('padding', const SliderValue(32))
        ..propertyValueChanged('padding', const SliderValue(16));

      expect(container.read(detailProvider('padding')).isModified, isFalse);
    });
  });

  group('選ぶ', () {
    test('選んだプロパティに移り、変更ありにはならない', () {
      final container = makeContainer();
      final notifier = container.read(detailProvider('container').notifier);

      notifier.propertySelected('width');

      final state = container.read(detailProvider('container'));
      expect(state.selected, 'width');
      expect(state.selectedSpec?.name, 'width');
      expect(state.isModified, isFalse);
    });

    test('TC-28: 比較中に child を選ぶと、比較をやめて child を選んでいる', () {
      final container = makeContainer();
      final notifier = container.read(detailProvider('padding').notifier);

      notifier
        ..compareTapped('padding')
        ..propertySelected('child');

      final state = container.read(detailProvider('padding'));
      expect(state.comparing, isNull);
      expect(state.selected, 'child');
    });
  });

  group('既定に戻す', () {
    test('TC-65: そのプロパティだけが最初の値に戻り、ほかはそのまま', () {
      final container = makeContainer();
      final notifier = container.read(detailProvider('container').notifier);

      notifier
        ..propertyValueChanged('padding', const SliderValue(32))
        ..propertyToggled('padding', false)
        ..propertyValueChanged('color', const ChoiceValue(3))
        ..propertyDefaultTapped('padding');

      final state = container.read(detailProvider('container'));
      expect(
        state.settings['padding'],
        const PropertySetting(on: true, value: SliderValue(16)),
      );
      expect(state.settings['color']?.value, const ChoiceValue(3));
    });

    test('TC-65: 最初の値のままなら isDefault、変えると false', () {
      final container = makeContainer();
      final notifier = container.read(detailProvider('container').notifier);

      expect(
        container.read(detailProvider('container')).isDefault('padding'),
        isTrue,
      );

      notifier.propertyValueChanged('padding', const SliderValue(32));

      final state = container.read(detailProvider('container'));
      expect(state.isDefault('padding'), isFalse);
      expect(state.isDefault('color'), isTrue);
    });
  });

  group('比べる', () {
    test('TC-27: 比べるを押すと、そのプロパティを比較中になる', () {
      final container = makeContainer();
      final notifier = container.read(detailProvider('padding').notifier);

      notifier.compareTapped('padding');

      final state = container.read(detailProvider('padding'));
      expect(state.comparing, const ComparingProperty('padding'));
      expect(state.isModified, isTrue);
    });

    test('比較中に別のプロパティを渡しても、比較をやめる', () {
      final container = makeContainer();
      final notifier = container.read(detailProvider('padding').notifier);

      notifier
        ..compareTapped('padding')
        ..compareTapped('child');

      expect(container.read(detailProvider('padding')).comparing, isNull);
    });

    test('TC-29: 同じ行の比べるを押すと比較をやめ、値はそのまま', () {
      final container = makeContainer();
      final notifier = container.read(detailProvider('padding').notifier);

      notifier
        ..propertyValueChanged('padding', const SliderValue(24))
        ..compareTapped('padding')
        ..compareTapped('padding');

      final state = container.read(detailProvider('padding'));
      expect(state.comparing, isNull);
      expect(state.settings['padding']?.value, const SliderValue(24));
    });

    test('TC-29: 比較をやめるを押すと比較をやめ、値が最初のままなら変更なし', () {
      final container = makeContainer();
      final notifier = container.read(detailProvider('padding').notifier);

      notifier
        ..compareTapped('padding')
        ..compareDismissed();

      final state = container.read(detailProvider('padding'));
      expect(state.comparing, isNull);
      expect(state.isModified, isFalse);
    });

    test('TC-30: OFF でも「付けた」側は覚えている値、「付けない」側は OFF', () {
      final container = makeContainer();
      final notifier = container.read(detailProvider('padding').notifier);

      notifier
        ..propertyValueChanged('padding', const SliderValue(24))
        ..propertyToggled('padding', false)
        ..compareTapped('padding');

      final state = container.read(detailProvider('padding'));
      expect(
        state.settingsForSide(on: true)['padding'],
        const PropertySetting(on: true, value: SliderValue(24)),
      );
      expect(
        state.settingsForSide(on: false)['padding'],
        const PropertySetting(on: false, value: SliderValue(24)),
      );
    });

    test('TC-31: 比較中に別のプロパティを変えると、2 枚とも同じ値になる', () {
      final container = makeContainer();
      final notifier = container.read(detailProvider('container').notifier);

      notifier
        ..compareTapped('color')
        ..propertyValueChanged('padding', const SliderValue(40));

      final state = container.read(detailProvider('container'));
      final withColor = state.settingsForSide(on: true);
      final withoutColor = state.settingsForSide(on: false);
      expect(withColor['padding'], withoutColor['padding']);
      expect(withColor['padding']?.value, const SliderValue(40));
      expect(withColor['color']?.on, isTrue);
      expect(withoutColor['color']?.on, isFalse);
    });

    test('比較していないときは、2 枚とも今の設定', () {
      final container = makeContainer();

      final state = container.read(detailProvider('padding'));

      expect(state.settingsForSide(on: true), state.settings);
      expect(state.settingsForSide(on: false), state.settings);
    });
  });

  group('比べる（見た目を持たない Widget）', () {
    ProviderContainer behaviorContainer() =>
        makeContainer(repository: FakeCatalogRepository([behaviorEntry]));

    test('比べるを押すと、Widget そのものを使った／使わないで比べる', () {
      final container = behaviorContainer();
      final notifier = container.read(detailProvider('behavior').notifier);

      notifier.compareTapped('scale');

      final state = container.read(detailProvider('behavior'));
      expect(state.comparing, const ComparingUse());
      expect(state.comparingSpec, isNull);
      expect(state.isModified, isTrue);
    });

    test('TC-76: 比較中に別のチップを選んでも比較が続く', () {
      final container = behaviorContainer();
      final notifier = container.read(detailProvider('behavior').notifier);

      notifier
        ..compareTapped('scale')
        ..propertySelected('mode');

      final state = container.read(detailProvider('behavior'));
      expect(state.comparing, const ComparingUse());
      expect(state.selected, 'mode');
    });

    test('比較中にもう一度押すと比較をやめる', () {
      final container = behaviorContainer();
      final notifier = container.read(detailProvider('behavior').notifier);

      notifier
        ..compareTapped('scale')
        ..propertySelected('mode')
        ..compareTapped('mode');

      expect(container.read(detailProvider('behavior')).comparing, isNull);
    });

    test('使った／使わないの 2 枚は、どちらも今の設定', () {
      final container = behaviorContainer();
      final notifier = container.read(detailProvider('behavior').notifier);

      notifier
        ..compareTapped('scale')
        ..propertyToggled('scale', false);

      final state = container.read(detailProvider('behavior'));
      expect(state.settingsForSide(on: true), state.settings);
      expect(state.settingsForSide(on: false), state.settings);
    });
  });

  test('TC-32: 初期状態に戻すと、全プロパティが最初の値になり比較もやめる', () {
    final container = makeContainer();
    final notifier = container.read(detailProvider('container').notifier);

    notifier
      ..propertyValueChanged('padding', const SliderValue(40))
      ..propertyToggled('color', false)
      ..propertySelected('color')
      ..compareTapped('color')
      ..resetTapped();

    final state = container.read(detailProvider('container'));
    expect(state.settings, containerEntry.initialSettings());
    expect(state.comparing, isNull);
    expect(state.selected, 'padding');
    expect(state.isModified, isFalse);
  });

  test('TC-73: 初期状態に戻すと、build の回数とログを空にして計測をやり直す', () {
    final container = makeContainer(
      repository: FakeCatalogRepository([behaviorEntry]),
    );
    final probe = probeProvider('behavior');
    container.listen(probe, (_, _) {});
    container.read(probe.notifier).recorded(const [
      BuildEvent(side: DemoSide.used, label: '読む子'),
    ]);
    container.read(detailProvider('behavior').notifier)
      ..propertyValueChanged('scale', const SliderValue(1.5))
      ..resetTapped();

    expect(container.read(probe).counts, isEmpty);
    expect(container.read(probe).logs, isEmpty);
    expect(container.read(probe).epoch, 1);
    expect(
      container.read(detailProvider('behavior')).settings,
      behaviorEntry.initialSettings(),
    );
  });

  test('見た目を持たない Widget は、比べ始め・やめるたびに計測をやり直す', () {
    final container = makeContainer(
      repository: FakeCatalogRepository([behaviorEntry]),
    );
    final probe = probeProvider('behavior');
    container.listen(probe, (_, _) {});
    final notifier = container.read(detailProvider('behavior').notifier);

    notifier.compareTapped('scale');
    expect(container.read(probe).epoch, 1);

    notifier.compareDismissed();
    expect(container.read(probe).epoch, 2);
  });

  group('コード', () {
    test('TC-38: 今の設定のコードになり、設定を変えると作り直される', () {
      final container = makeContainer();
      final notifier = container.read(detailProvider('padding').notifier);

      notifier.propertyValueChanged('padding', const SliderValue(32));

      final state = container.read(detailProvider('padding'));
      expect(
        container.read(detailCodeProvider('padding')),
        const CodeGenerator().lines(paddingEntry, state.settings),
      );
      expect(
        container.read(detailCodeProvider('padding')).map((l) => l.text),
        contains('  padding: EdgeInsets.all(32.0),'),
      );
    });
  });

  group('コピー', () {
    test('TC-42: 今のコードをクリップボードに書き、true を返す', () async {
      final container = makeContainer();
      final notifier = container.read(detailProvider('text').notifier);

      final copied = await notifier.copyTapped();

      expect(copied, isTrue);
      expect(clipboard.written, [
        const CodeGenerator().generate(
          textEntry,
          container.read(detailProvider('text')).settings,
        ),
      ]);
    });

    test('TC-43: 書けなければ false', () async {
      final container = makeContainer(clipboardSucceeds: false);
      final notifier = container.read(detailProvider('text').notifier);

      expect(await notifier.copyTapped(), isFalse);
    });
  });

  group('公式ドキュメント', () {
    test('TC-44: その Widget の公式ドキュメントの URL を開き、true を返す', () async {
      final container = makeContainer();
      final notifier = container.read(detailProvider('text').notifier);

      final opened = await notifier.openDocsTapped();

      expect(opened, isTrue);
      expect(launcher.opened, [textEntry.docUrl]);
    });

    test('TC-45: 開けなければ false', () async {
      final container = makeContainer(launcherSucceeds: false);
      final notifier = container.read(detailProvider('text').notifier);

      expect(await notifier.openDocsTapped(), isFalse);
    });
  });

  test('画面を離れると設定を捨て、次は最初の設定になる', () async {
    final container = makeContainer();
    final subscription = container.listen(detailProvider('padding'), (_, _) {});
    container
        .read(detailProvider('padding').notifier)
        .propertyValueChanged('padding', const SliderValue(32));

    subscription.close();
    await container.pump();

    expect(
      container.read(detailProvider('padding')).settings,
      paddingEntry.initialSettings(),
    );
  });
}

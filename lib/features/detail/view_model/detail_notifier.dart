import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';
import 'package:widget_lab/core/data/catalog_repository.dart';
import 'package:widget_lab/core/data/clipboard_client.dart';
import 'package:widget_lab/core/data/url_launcher_client.dart';
import 'package:widget_lab/features/detail/view_model/code_generator.dart';
import 'package:widget_lab/features/detail/view_model/comparing.dart';
import 'package:widget_lab/features/detail/view_model/detail_state.dart';
import 'package:widget_lab/features/detail/view_model/exclusion_notice.dart';
import 'package:widget_lab/features/detail/view_model/picker_item.dart';
import 'package:widget_lab/features/detail/view_model/probe_notifier.dart';

part 'detail_notifier.g.dart';

/// 1つの Widget の詳細の設定・選択・比較。画面を離れると捨てる（autoDispose）。
@riverpod
class DetailNotifier extends _$DetailNotifier {
  @override
  DetailState build(String entryId) {
    final repository = ref.watch(catalogRepositoryProvider);
    final entry = repository.entryById(entryId);
    // 一覧は同じ収録データから作るので起きない
    if (entry == null) throw StateError('収録データにない ID: $entryId');
    final genres = [
      for (final id in entry.genreIds)
        ...repository.genres().where((genre) => genre.id == id),
    ];
    return DetailState.initial(entry, genres);
  }

  /// 編集パネルの中身を [name] に切り替える。プロパティの比較はやめ、
  /// 使った／使わないの比較は続ける（値の変化を左右で見られるように）。
  void propertySelected(String name) {
    final comparing = state.comparing;
    state = state.copyWith(
      selected: name,
      selectedChild: () =>
          DetailState.firstChildOf(state.entry, name, state.settings),
      showsReferences: false,
      notice: () => null,
      comparing: () => comparing is ComparingUse ? comparing : null,
    );
  }

  /// 補足を選ぶ。補足は比べられないので比較をやめる。
  void referencesSelected() {
    state = state.copyWith(
      showsReferences: true,
      notice: () => null,
      comparing: () => null,
    );
    _restartProbe();
  }

  /// 選ぶ欄の ‹。前のプロパティ（または補足）を選ぶ。先頭なら何もしない。
  void previousTapped() => _moveBy(-1);

  /// 選ぶ欄の ›。次のプロパティ（または補足）を選ぶ。最後なら何もしない。
  void nextTapped() => _moveBy(1);

  void _moveBy(int delta) {
    final items = state.pickerItems;
    final from = state.pickerIndex;
    final to = from + delta;
    if (from < 0 || to < 0 || to >= items.length) return;
    switch (items[to]) {
      case PickerProperty(:final spec):
        propertySelected(spec.name);
      case PickerReferences():
        referencesSelected();
    }
  }

  void noticeDismissed() => state = state.copyWith(notice: () => null);

  /// 必須のプロパティは変えない。ON にしたら、同時に使えない相手を OFF にして知らせる。
  void propertyToggled(String name, bool on) {
    final spec = state.entry.properties
        .where((p) => p.name == name)
        .firstOrNull;
    if (spec == null || spec.required) return;
    final setting = state.settings[name];
    if (setting == null) return;
    _apply(name, setting.copyWith(on: on));
  }

  /// 入れ子のプロパティの中で [child] を選ぶ。子の比較はやめる。
  void childSelected(String child) {
    final comparing = state.comparing;
    state = state.copyWith(
      selectedChild: () => child,
      comparing: () => comparing is ComparingProperty && comparing.child != null
          ? null
          : comparing,
    );
  }

  void childToggled(String parent, String child, bool on) =>
      _updateChild(parent, child, (s) => s.copyWith(on: on));

  void childValueChanged(String parent, String child, ControlValue value) =>
      _updateChild(parent, child, (s) => s.copyWith(value: value));

  void _updateChild(
    String parent,
    String child,
    PropertySetting Function(PropertySetting setting) change,
  ) => _update(parent, (setting) {
    final value = setting.value;
    if (value is! NestedValue) return setting;
    final childSetting = value.settings[child];
    if (childSetting == null) return setting;
    return setting.copyWith(
      value: value.copyWithChild(child, change(childSetting)),
    );
  });

  void propertyValueChanged(String name, ControlValue value) =>
      _update(name, (setting) => setting.copyWith(value: value));

  /// [name] の ON/OFF と値を最初の値に戻す。
  void propertyDefaultTapped(String name) {
    final initial = state.entry.initialSettings()[name];
    if (initial == null) return;
    _apply(name, initial);
  }

  /// [name] の設定を [setting] にする。ON なら、同時に使えない相手を OFF にして知らせる。
  void _apply(String name, PropertySetting setting) {
    final spec = state.entry.properties.where((p) => p.name == name).first;
    final settings = {...state.settings, name: setting};
    String? turnedOff;
    if (setting.on) {
      for (final other in spec.excludes) {
        final otherSetting = settings[other];
        if (otherSetting == null || !otherSetting.on) continue;
        settings[other] = otherSetting.copyWith(on: false);
        turnedOff ??= other;
      }
    }
    state = state.copyWith(
      settings: settings,
      notice: () => turnedOff == null
          ? null
          : ExclusionNotice(turnedOn: name, turnedOff: turnedOff),
    );
  }

  /// 比較中ならやめる。そうでなければ、見た目を持つ Widget は [name] のプロパティを、
  /// 持たない Widget は Widget そのものを比べる。
  void compareTapped(String name) {
    state = state.copyWith(
      comparing: () => switch ((state.comparing, state.entry.kind)) {
        (Comparing(), _) => null,
        (null, EntryKind.visual) => ComparingProperty(
          name,
          child: name == state.selected ? state.selectedChild : null,
        ),
        (null, EntryKind.behavior) => const ComparingUse(),
      },
    );
    _restartProbe();
  }

  void compareDismissed() {
    state = state.copyWith(comparing: () => null);
    _restartProbe();
  }

  /// 設定・選択・比較を最初に戻す。見た目を持たない Widget は計測もやり直す。
  void resetTapped() {
    state = DetailState.initial(state.entry, state.genres);
    _restartProbe();
  }

  /// 今のコード（[without] なら使わない側のコード）をクリップボードに書く。
  /// 書けなければ `false`。
  Future<bool> copyTapped({bool without = false}) => ref
      .read(clipboardClientProvider)
      .setText(
        (without ? state.entry.codeWithout : null) ??
            const CodeGenerator().generate(state.entry, state.settings),
      );

  /// 公式ドキュメントを外部のブラウザで開く。開けなければ `false`。
  Future<bool> openDocsTapped() =>
      ref.read(urlLauncherClientProvider).open(state.entry.docUrl);

  /// 見た目を持たない Widget の build の回数とログを空にして、デモの木を組み直させる。
  void _restartProbe() {
    if (state.entry.kind != EntryKind.behavior) return;
    ref.read(probeProvider(entryId).notifier).restarted();
  }

  void _update(
    String name,
    PropertySetting Function(PropertySetting setting) change,
  ) {
    final setting = state.settings[name];
    if (setting == null) return;
    state = state.copyWith(
      settings: {...state.settings, name: change(setting)},
      notice: () => null,
    );
  }
}

/// 今の設定を再現する Dart のコードの行（帯は選んでいる行、全文は全部）。
@riverpod
List<CodeLine> detailCode(Ref ref, String entryId) {
  // 選び替えや比較では作り直さない
  final (entry, settings) = ref.watch(
    detailProvider(entryId).select((s) => (s.entry, s.settings)),
  );
  return const CodeGenerator().lines(entry, settings);
}

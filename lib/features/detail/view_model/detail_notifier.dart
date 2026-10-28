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
      comparing: () => comparing is ComparingUse ? comparing : null,
    );
  }

  /// 必須のプロパティは変えない。
  void propertyToggled(String name, bool on) {
    final spec = state.entry.properties
        .where((p) => p.name == name)
        .firstOrNull;
    if (spec == null || spec.required) return;
    _update(name, (setting) => setting.copyWith(on: on));
  }

  void propertyValueChanged(String name, ControlValue value) =>
      _update(name, (setting) => setting.copyWith(value: value));

  /// [name] の ON/OFF と値を最初の値に戻す。
  void propertyDefaultTapped(String name) {
    final initial = state.entry.initialSettings()[name];
    if (initial == null) return;
    _update(name, (_) => initial);
  }

  /// 比較中ならやめる。そうでなければ、見た目を持つ Widget は [name] のプロパティを、
  /// 持たない Widget は Widget そのものを比べる。
  void compareTapped(String name) {
    state = state.copyWith(
      comparing: () => switch ((state.comparing, state.entry.kind)) {
        (Comparing(), _) => null,
        (null, EntryKind.visual) => ComparingProperty(name),
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

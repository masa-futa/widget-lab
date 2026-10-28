import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/core/data/catalog_repository.dart';
import 'package:widget_lab/core/data/clipboard_client.dart';
import 'package:widget_lab/core/data/url_launcher_client.dart';
import 'package:widget_lab/features/detail/view_model/code_generator.dart';
import 'package:widget_lab/features/detail/view_model/detail_state.dart';

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

  /// 編集パネルの中身を [name] に切り替え、比較をやめる。
  void propertySelected(String name) {
    state = state.copyWith(selected: name, comparing: () => null);
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

  /// 比較中のプロパティなら比較をやめ、それ以外ならそのプロパティを比べる。
  void compareTapped(String name) {
    state = state.copyWith(
      comparing: () => state.comparing == name ? null : name,
    );
  }

  void compareDismissed() {
    state = state.copyWith(comparing: () => null);
  }

  void resetTapped() {
    state = DetailState.initial(state.entry, state.genres);
  }

  /// 今のコードをクリップボードに書く。書けなければ `false`。
  Future<bool> copyTapped() => ref
      .read(clipboardClientProvider)
      .setText(const CodeGenerator().generate(state.entry, state.settings));

  /// 公式ドキュメントを外部のブラウザで開く。開けなければ `false`。
  Future<bool> openDocsTapped() =>
      ref.read(urlLauncherClientProvider).open(state.entry.docUrl);

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

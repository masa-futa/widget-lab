// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 1つの Widget の詳細の設定・選択・比較。画面を離れると捨てる（autoDispose）。

@ProviderFor(DetailNotifier)
final detailProvider = DetailNotifierFamily._();

/// 1つの Widget の詳細の設定・選択・比較。画面を離れると捨てる（autoDispose）。
final class DetailNotifierProvider
    extends $NotifierProvider<DetailNotifier, DetailState> {
  /// 1つの Widget の詳細の設定・選択・比較。画面を離れると捨てる（autoDispose）。
  DetailNotifierProvider._({
    required DetailNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'detailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$detailNotifierHash();

  @override
  String toString() {
    return r'detailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DetailNotifier create() => DetailNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DetailState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DetailNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$detailNotifierHash() => r'f940573bb39e04d86fec1959d37b75be23400e35';

/// 1つの Widget の詳細の設定・選択・比較。画面を離れると捨てる（autoDispose）。

final class DetailNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          DetailNotifier,
          DetailState,
          DetailState,
          DetailState,
          String
        > {
  DetailNotifierFamily._()
    : super(
        retry: null,
        name: r'detailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 1つの Widget の詳細の設定・選択・比較。画面を離れると捨てる（autoDispose）。

  DetailNotifierProvider call(String entryId) =>
      DetailNotifierProvider._(argument: entryId, from: this);

  @override
  String toString() => r'detailProvider';
}

/// 1つの Widget の詳細の設定・選択・比較。画面を離れると捨てる（autoDispose）。

abstract class _$DetailNotifier extends $Notifier<DetailState> {
  late final _$args = ref.$arg as String;
  String get entryId => _$args;

  DetailState build(String entryId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DetailState, DetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DetailState, DetailState>,
              DetailState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// 今の設定を再現する Dart のコードの行（帯は選んでいる行、全文は全部）。

@ProviderFor(detailCode)
final detailCodeProvider = DetailCodeFamily._();

/// 今の設定を再現する Dart のコードの行（帯は選んでいる行、全文は全部）。

final class DetailCodeProvider
    extends $FunctionalProvider<List<CodeLine>, List<CodeLine>, List<CodeLine>>
    with $Provider<List<CodeLine>> {
  /// 今の設定を再現する Dart のコードの行（帯は選んでいる行、全文は全部）。
  DetailCodeProvider._({
    required DetailCodeFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'detailCodeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$detailCodeHash();

  @override
  String toString() {
    return r'detailCodeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<CodeLine>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<CodeLine> create(Ref ref) {
    final argument = this.argument as String;
    return detailCode(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<CodeLine> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<CodeLine>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DetailCodeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$detailCodeHash() => r'c365fab7d23f41bd09604a2831ae13903bc6b477';

/// 今の設定を再現する Dart のコードの行（帯は選んでいる行、全文は全部）。

final class DetailCodeFamily extends $Family
    with $FunctionalFamilyOverride<List<CodeLine>, String> {
  DetailCodeFamily._()
    : super(
        retry: null,
        name: r'detailCodeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 今の設定を再現する Dart のコードの行（帯は選んでいる行、全文は全部）。

  DetailCodeProvider call(String entryId) =>
      DetailCodeProvider._(argument: entryId, from: this);

  @override
  String toString() => r'detailCodeProvider';
}

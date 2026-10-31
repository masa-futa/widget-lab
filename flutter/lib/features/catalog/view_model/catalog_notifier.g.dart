// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ホームのジャンルのタイルと、検索の結果。
///
/// 検索の入力は画面の中だけの状態に近いが、結果はロジックで作るので
/// ここで探す（docs/design/functions/demo-engine.md の CatalogState）。

@ProviderFor(CatalogNotifier)
final catalogProvider = CatalogNotifierProvider._();

/// ホームのジャンルのタイルと、検索の結果。
///
/// 検索の入力は画面の中だけの状態に近いが、結果はロジックで作るので
/// ここで探す（docs/design/functions/demo-engine.md の CatalogState）。
final class CatalogNotifierProvider
    extends $NotifierProvider<CatalogNotifier, CatalogState> {
  /// ホームのジャンルのタイルと、検索の結果。
  ///
  /// 検索の入力は画面の中だけの状態に近いが、結果はロジックで作るので
  /// ここで探す（docs/design/functions/demo-engine.md の CatalogState）。
  CatalogNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogNotifierHash();

  @$internal
  @override
  CatalogNotifier create() => CatalogNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CatalogState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CatalogState>(value),
    );
  }
}

String _$catalogNotifierHash() => r'49c7708754c12bc46f72a399e72f965175e251f4';

/// ホームのジャンルのタイルと、検索の結果。
///
/// 検索の入力は画面の中だけの状態に近いが、結果はロジックで作るので
/// ここで探す（docs/design/functions/demo-engine.md の CatalogState）。

abstract class _$CatalogNotifier extends $Notifier<CatalogState> {
  CatalogState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CatalogState, CatalogState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CatalogState, CatalogState>,
              CatalogState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

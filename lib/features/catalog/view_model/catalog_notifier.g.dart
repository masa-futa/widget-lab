// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CatalogNotifier)
final catalogProvider = CatalogNotifierProvider._();

final class CatalogNotifierProvider
    extends $NotifierProvider<CatalogNotifier, CatalogState> {
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

String _$catalogNotifierHash() => r'8731ba1b7b21d88db24523c1c6096950082abcb1';

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

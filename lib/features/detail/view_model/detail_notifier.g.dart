// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 1つの Widget の詳細の設定と比較。画面を離れると捨てる（autoDispose）。

@ProviderFor(DetailNotifier)
final detailProvider = DetailNotifierFamily._();

/// 1つの Widget の詳細の設定と比較。画面を離れると捨てる（autoDispose）。
final class DetailNotifierProvider
    extends $NotifierProvider<DetailNotifier, DetailState> {
  /// 1つの Widget の詳細の設定と比較。画面を離れると捨てる（autoDispose）。
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

String _$detailNotifierHash() => r'dd7af6e8e0c43ca79ed318cceec2cec70d9f4f91';

/// 1つの Widget の詳細の設定と比較。画面を離れると捨てる（autoDispose）。

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

  /// 1つの Widget の詳細の設定と比較。画面を離れると捨てる（autoDispose）。

  DetailNotifierProvider call(String entryId) =>
      DetailNotifierProvider._(argument: entryId, from: this);

  @override
  String toString() => r'detailProvider';
}

/// 1つの Widget の詳細の設定と比較。画面を離れると捨てる（autoDispose）。

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

/// 今の設定を再現する Dart のコード。

@ProviderFor(detailCode)
final detailCodeProvider = DetailCodeFamily._();

/// 今の設定を再現する Dart のコード。

final class DetailCodeProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// 今の設定を再現する Dart のコード。
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
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    final argument = this.argument as String;
    return detailCode(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
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

String _$detailCodeHash() => r'422fb654399a505b52178ea6b60ead81349bce87';

/// 今の設定を再現する Dart のコード。

final class DetailCodeFamily extends $Family
    with $FunctionalFamilyOverride<String, String> {
  DetailCodeFamily._()
    : super(
        retry: null,
        name: r'detailCodeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 今の設定を再現する Dart のコード。

  DetailCodeProvider call(String entryId) =>
      DetailCodeProvider._(argument: entryId, from: this);

  @override
  String toString() => r'detailCodeProvider';
}

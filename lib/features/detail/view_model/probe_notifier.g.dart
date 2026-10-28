// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'probe_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ログの時刻を取る（テストで差し替える）。

@ProviderFor(probeClock)
final probeClockProvider = ProbeClockProvider._();

/// ログの時刻を取る（テストで差し替える）。

final class ProbeClockProvider
    extends
        $FunctionalProvider<
          DateTime Function(),
          DateTime Function(),
          DateTime Function()
        >
    with $Provider<DateTime Function()> {
  /// ログの時刻を取る（テストで差し替える）。
  ProbeClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'probeClockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$probeClockHash();

  @$internal
  @override
  $ProviderElement<DateTime Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DateTime Function() create(Ref ref) {
    return probeClock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime Function()>(value),
    );
  }
}

String _$probeClockHash() => r'e497bff24e103640207d85a7700313887ae4a096';

/// 見た目を持たない Widget の build の回数とログ。画面を離れると捨てる（autoDispose）。

@ProviderFor(ProbeNotifier)
final probeProvider = ProbeNotifierFamily._();

/// 見た目を持たない Widget の build の回数とログ。画面を離れると捨てる（autoDispose）。
final class ProbeNotifierProvider
    extends $NotifierProvider<ProbeNotifier, ProbeState> {
  /// 見た目を持たない Widget の build の回数とログ。画面を離れると捨てる（autoDispose）。
  ProbeNotifierProvider._({
    required ProbeNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'probeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$probeNotifierHash();

  @override
  String toString() {
    return r'probeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProbeNotifier create() => ProbeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProbeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProbeState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProbeNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$probeNotifierHash() => r'db14a3ae57e55f1f6f28535747db0fde49e7849c';

/// 見た目を持たない Widget の build の回数とログ。画面を離れると捨てる（autoDispose）。

final class ProbeNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          ProbeNotifier,
          ProbeState,
          ProbeState,
          ProbeState,
          String
        > {
  ProbeNotifierFamily._()
    : super(
        retry: null,
        name: r'probeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 見た目を持たない Widget の build の回数とログ。画面を離れると捨てる（autoDispose）。

  ProbeNotifierProvider call(String entryId) =>
      ProbeNotifierProvider._(argument: entryId, from: this);

  @override
  String toString() => r'probeProvider';
}

/// 見た目を持たない Widget の build の回数とログ。画面を離れると捨てる（autoDispose）。

abstract class _$ProbeNotifier extends $Notifier<ProbeState> {
  late final _$args = ref.$arg as String;
  String get entryId => _$args;

  ProbeState build(String entryId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ProbeState, ProbeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProbeState, ProbeState>,
              ProbeState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

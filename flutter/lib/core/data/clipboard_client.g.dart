// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clipboard_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(clipboardClient)
final clipboardClientProvider = ClipboardClientProvider._();

final class ClipboardClientProvider
    extends
        $FunctionalProvider<ClipboardClient, ClipboardClient, ClipboardClient>
    with $Provider<ClipboardClient> {
  ClipboardClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clipboardClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clipboardClientHash();

  @$internal
  @override
  $ProviderElement<ClipboardClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ClipboardClient create(Ref ref) {
    return clipboardClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClipboardClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClipboardClient>(value),
    );
  }
}

String _$clipboardClientHash() => r'd9ff81a7cbbbeb9e97eb3d3e8d7cd46bb70db9df';

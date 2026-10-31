// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_launcher_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(urlLauncherClient)
final urlLauncherClientProvider = UrlLauncherClientProvider._();

final class UrlLauncherClientProvider
    extends
        $FunctionalProvider<
          UrlLauncherClient,
          UrlLauncherClient,
          UrlLauncherClient
        >
    with $Provider<UrlLauncherClient> {
  UrlLauncherClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'urlLauncherClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$urlLauncherClientHash();

  @$internal
  @override
  $ProviderElement<UrlLauncherClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UrlLauncherClient create(Ref ref) {
    return urlLauncherClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UrlLauncherClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UrlLauncherClient>(value),
    );
  }
}

String _$urlLauncherClientHash() => r'25a48627e0acf2c4932cde1e501ed1824475cd35';

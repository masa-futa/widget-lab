// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genre_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ジャンル画面に並べる Widget（公式カタログのページの順）。

@ProviderFor(genreEntries)
final genreEntriesProvider = GenreEntriesFamily._();

/// ジャンル画面に並べる Widget（公式カタログのページの順）。

final class GenreEntriesProvider
    extends
        $FunctionalProvider<
          List<WidgetEntry>,
          List<WidgetEntry>,
          List<WidgetEntry>
        >
    with $Provider<List<WidgetEntry>> {
  /// ジャンル画面に並べる Widget（公式カタログのページの順）。
  GenreEntriesProvider._({
    required GenreEntriesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'genreEntriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$genreEntriesHash();

  @override
  String toString() {
    return r'genreEntriesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<WidgetEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<WidgetEntry> create(Ref ref) {
    final argument = this.argument as String;
    return genreEntries(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<WidgetEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<WidgetEntry>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GenreEntriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$genreEntriesHash() => r'00ebe42fa10fb2c7dccfd2b4a31c232c6d4a31e2';

/// ジャンル画面に並べる Widget（公式カタログのページの順）。

final class GenreEntriesFamily extends $Family
    with $FunctionalFamilyOverride<List<WidgetEntry>, String> {
  GenreEntriesFamily._()
    : super(
        retry: null,
        name: r'genreEntriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// ジャンル画面に並べる Widget（公式カタログのページの順）。

  GenreEntriesProvider call(String genreId) =>
      GenreEntriesProvider._(argument: genreId, from: this);

  @override
  String toString() => r'genreEntriesProvider';
}

/// ジャンル画面の題と一言の説明に使うジャンル。
///
/// ない ID なら `StateError`（ホームは同じ収録データからタイルを作るので起きない）。

@ProviderFor(genre)
final genreProvider = GenreFamily._();

/// ジャンル画面の題と一言の説明に使うジャンル。
///
/// ない ID なら `StateError`（ホームは同じ収録データからタイルを作るので起きない）。

final class GenreProvider extends $FunctionalProvider<Genre, Genre, Genre>
    with $Provider<Genre> {
  /// ジャンル画面の題と一言の説明に使うジャンル。
  ///
  /// ない ID なら `StateError`（ホームは同じ収録データからタイルを作るので起きない）。
  GenreProvider._({
    required GenreFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'genreProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$genreHash();

  @override
  String toString() {
    return r'genreProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Genre> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Genre create(Ref ref) {
    final argument = this.argument as String;
    return genre(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Genre value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Genre>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GenreProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$genreHash() => r'50480a38584d4b27f7f946a33db4cba28859bb36';

/// ジャンル画面の題と一言の説明に使うジャンル。
///
/// ない ID なら `StateError`（ホームは同じ収録データからタイルを作るので起きない）。

final class GenreFamily extends $Family
    with $FunctionalFamilyOverride<Genre, String> {
  GenreFamily._()
    : super(
        retry: null,
        name: r'genreProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// ジャンル画面の題と一言の説明に使うジャンル。
  ///
  /// ない ID なら `StateError`（ホームは同じ収録データからタイルを作るので起きない）。

  GenreProvider call(String genreId) =>
      GenreProvider._(argument: genreId, from: this);

  @override
  String toString() => r'genreProvider';
}

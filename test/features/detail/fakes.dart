import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/basics/container.dart';
import 'package:widget_lab/catalog/basics/row.dart';
import 'package:widget_lab/catalog/basics/text.dart';
import 'package:widget_lab/catalog/genres.dart';
import 'package:widget_lab/catalog/layout/padding.dart';
import 'package:widget_lab/catalog/model/genre.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';
import 'package:widget_lab/core/data/catalog_repository.dart';
import 'package:widget_lab/core/data/clipboard_client.dart';
import 'package:widget_lab/core/data/url_launcher_client.dart';
import 'package:widget_lab/catalog/demo/rebuild_counter.dart';

/// お試しの4件（か渡したもの）だけを返す Repository。ジャンルは本物。
class FakeCatalogRepository implements CatalogRepository {
  FakeCatalogRepository([List<WidgetEntry>? entries])
    : _entries = entries ?? [paddingEntry, containerEntry, rowEntry, textEntry];

  final List<WidgetEntry> _entries;

  @override
  List<Genre> genres() => allGenres;

  @override
  List<WidgetEntry> entries() => _entries;

  @override
  WidgetEntry? entryById(String id) {
    for (final entry in _entries) {
      if (entry.id == id) return entry;
    }
    return null;
  }
}

/// 書いた文字を覚える。[succeeds] が `false` なら書けなかったことにする。
class FakeClipboardClient implements ClipboardClient {
  FakeClipboardClient({this.succeeds = true});

  final bool succeeds;
  final written = <String>[];

  @override
  Future<bool> setText(String text) async {
    if (!succeeds) return false;
    written.add(text);
    return true;
  }
}

/// 開こうとした URL を覚える。[succeeds] が `false` なら開けなかったことにする。
class FakeUrlLauncherClient implements UrlLauncherClient {
  FakeUrlLauncherClient({this.succeeds = true});

  final bool succeeds;
  final opened = <Uri>[];

  @override
  Future<bool> open(Uri url) async {
    opened.add(url);
    return succeeds;
  }
}

/// 最初は全部 OFF のプロパティを 2 つ持つ Widget。
final allOffEntry = WidgetEntry(
  id: 'allOff',
  name: 'AllOff',
  genreIds: const ['basics'],
  summary: '',
  description: '',
  docUrl: Uri.parse('https://api.flutter.dev/'),
  properties: const [
    PropertySpec(
      name: 'first',
      typeLabel: 'bool?',
      description: '',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'second',
      typeLabel: 'bool?',
      description: '',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
  ],
  build: (args) => const SizedBox(),
  codeName: 'AllOff',
);

/// 変えられるプロパティがない Widget。
final noPropertyEntry = WidgetEntry(
  id: 'none',
  name: 'None',
  genreIds: const ['basics'],
  summary: '',
  description: '',
  docUrl: Uri.parse('https://api.flutter.dev/'),
  properties: const [],
  build: (args) => const SizedBox(),
  codeName: 'None',
);

/// 見た目を持たない Widget。2 つのプロパティを持ち、「読む子」を数える。使わない側も同じ木。
final behaviorEntry = WidgetEntry(
  id: 'behavior',
  name: 'Behavior',
  genreIds: const ['styling'],
  summary: '',
  description: '',
  docUrl: Uri.parse('https://api.flutter.dev/'),
  kind: EntryKind.behavior,
  properties: [
    PropertySpec(
      name: 'scale',
      typeLabel: 'double',
      description: '',
      control: SliderControl(
        min: 1,
        max: 2,
        divisions: 10,
        initialValue: 1,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    const PropertySpec(
      name: 'mode',
      typeLabel: 'Brightness',
      description: '',
      control: ChoiceControl(
        choices: [
          Choice('light', Brightness.light, 'Brightness.light'),
          Choice('dark', Brightness.dark, 'Brightness.dark'),
        ],
      ),
    ),
  ],
  build: (args) =>
      RebuildCounter(label: '読む子', builder: (context) => const Text('中身')),
  buildWithout: (args) =>
      RebuildCounter(label: '読む子', builder: (context) => const Text('中身')),
  codeName: 'Behavior',
);

/// 使わない側のコード（codeWithout）を持つ、見た目を持たない Widget。
final behaviorWithCodeEntry = WidgetEntry(
  id: 'behaviorCode',
  name: 'BehaviorCode',
  genreIds: const ['styling'],
  summary: '',
  description: '',
  docUrl: Uri.parse('https://api.flutter.dev/'),
  kind: EntryKind.behavior,
  properties: behaviorEntry.properties,
  build: behaviorEntry.build,
  buildWithout: behaviorEntry.buildWithout,
  codeName: 'BehaviorCode',
  codeWithout:
      'class Plain extends StatefulWidget {\n  // listen して setState\n}',
);

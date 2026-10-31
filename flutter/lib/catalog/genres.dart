import 'package:widget_lab/catalog/model/genre.dart';

/// 公式 Widget カタログのジャンル。並びは公式のページの順
/// （デザインシステムの 2 つのあと、基本の Widget を ABC 順）。
const allGenres = [
  Genre(
    id: 'cupertino',
    name: 'Cupertino',
    group: GenreGroupKind.designSystem,
    description: 'iOS の見た目に合わせた Widget',
  ),
  Genre(
    id: 'material',
    name: 'Material design',
    group: GenreGroupKind.designSystem,
    description: 'Material Design の部品',
  ),
  Genre(
    id: 'accessibility',
    name: 'Accessibility',
    group: GenreGroupKind.base,
    description: '読み上げなど、使いやすさを助ける Widget',
  ),
  Genre(
    id: 'animation',
    name: 'Animation and motion',
    group: GenreGroupKind.base,
    description: '動きをつける Widget',
  ),
  Genre(
    id: 'assets',
    name: 'Assets, images, and icons',
    group: GenreGroupKind.base,
    description: '画像・アイコンを出す Widget',
  ),
  Genre(
    id: 'async',
    name: 'Async',
    group: GenreGroupKind.base,
    description: '非同期の結果に合わせて組み立てる Widget',
  ),
  Genre(
    id: 'basics',
    name: 'Basics',
    group: GenreGroupKind.base,
    description: 'アプリの骨組みになる基本の Widget',
  ),
  Genre(
    id: 'input',
    name: 'Input',
    group: GenreGroupKind.base,
    description: '入力を受け取る Widget',
  ),
  Genre(
    id: 'interaction',
    name: 'Interaction models',
    group: GenreGroupKind.base,
    description: 'タップ・ドラッグなどの操作に応える Widget',
  ),
  Genre(
    id: 'layout',
    name: 'Layout',
    group: GenreGroupKind.base,
    description: '子を並べ、配置と大きさを決める Widget',
  ),
  Genre(
    id: 'painting',
    name: 'Painting and effects',
    group: GenreGroupKind.base,
    description: '描画と効果をかける Widget',
  ),
  Genre(
    id: 'scrolling',
    name: 'Scrolling',
    group: GenreGroupKind.base,
    description: '中身をスクロールさせる Widget',
  ),
  Genre(
    id: 'styling',
    name: 'Styling',
    group: GenreGroupKind.base,
    description: 'テーマや余白で見た目を整える Widget',
  ),
  Genre(
    id: 'text',
    name: 'Text',
    group: GenreGroupKind.base,
    description: '文字を出し、整える Widget',
  ),
];

# Design System

共通の土台（`nimi-design-base.md`、2026-10-20 に写したもの）から作った。土台と同じ値の表には「土台と同じ」と添え、値や決まりを変えた行だけ理由を書く。

> **要約**
> - 結論: 部品の形と動きは Material 3、色・文字・余白・角丸は自社の土台。アプリの色は瑠璃（ruri）
> - 影響: アプリ自体の UI（一覧・詳細・操作パネル・比較・コード）。収録する Widget の見た目には手を加えない
> - お願い: なし（2026-10-28 オーナー承認）

## 方向と見直し
- 設計言語: **Material 3＋土台の色と文字**（根拠: PRD で Material 3 に決めた。収録する Material の部品となじみ、iOS / Android で同じ見た目にできる。色と文字は自社の土台にそろえ、ほかの自社アプリと印象を合わせる。2026-10-28 オーナーが選択）
- トーン所見: 墨の地に瑠璃をひと色。主役は収録する Widget のプレビューなので、アプリの UI は無彩色で静かにし、色は「触れる場所（スイッチの ON・選択中・主な操作）」にだけ使う。密度は中くらい（操作パネルは1行1プロパティ）。角丸は土台どおり大きめ（カード 20、ボタンはピル形）。文言は短く、ボタンは動詞の言い切り（例:「比較する」「初期状態に戻す」）、説明文はです・ます調
- 題材: Flutter の Widget を、プロパティを付けた／付けないで触って比べる手元の実験室。自分と Flutter を触る人向け。画面の主な仕事は「プロパティを変えて、違いを見る」
- 原則:
  1. **プレビューが主役**: プレビューの地は surface にし、アプリの UI の色や影をプレビューに重ねない。例外は、組み立てた Widget の外枠に引く outline-variant の細い線だけ（Padding のように自分では何も描かない Widget でも、大きさの違いが見えるように。cb_dtl の pv-card）
  2. **付けた／付けないは色だけで示さない**: 比較のラベルは文言（「付けた」「付けない」）とアイコンで示す
  3. **色は触れる場所だけ**: accent（瑠璃）は操作できる部品の状態にだけ使う。山吹はワードマークの印1か所だけ

| 最初の案 | 変えたもの | 理由 |
|---------|-----------|------|
| 土台どおり HIG を基準に、Cupertino の部品で作る | 部品の形と動きは Material 3 | PRD で決めた設計言語。収録する Material の部品と同じ世界で見せたい（オーナーの選択） |
| `ColorScheme.fromSeed(#0175C2)` の自動の配色 | 土台の値を `ColorScheme` に直接入れる | seed から作ると墨の地にならず、ほかの自社アプリと印象がずれる |
| 余白 xs4/s8/m16/l24/xl32（土台の PR #1 の `AppSpacing`） | 土台の `NimiSpacing`（2xs〜3xl） | 土台の名前と段階にそろえる（12・20・40 の段が足りない） |

## デザイントークン

### カラー
土台と同じ（accent だけアプリの色の ruri）。Flutter の名前は土台の「スタックごとの名前」に合わせる。

| トークン名（土台） | Flutter | Light | Dark | 用途 | コントラスト比（どの背景の上で） |
|-----------|------|-------|------|------|------|
| color/canvas | `ColorScheme.surface` | #EFEFF0 | #101012 | 画面の地 | — |
| color/surface | `ColorScheme.surfaceContainer` | #FFFFFF | #1D1D20 | カード・プレビューの地・シート | — |
| color/surface-muted | `NimiColors.surfaceMuted` | #E7E7E9 | #28282C | コードの地・無効の地・チップの地 | — |
| color/ink | `ColorScheme.onSurface` | #18181B | #F3F3F4 | 本文・見出し・アイコン | L 17.72（surface）・15.42（canvas）・14.35（surface-muted）／D 15.16・17.14・13.24 |
| color/ink-secondary | `ColorScheme.onSurfaceVariant` | #5E5E64 | #A6A6AB | 補足の文字（プロパティの説明・型） | L 6.44（surface）・5.60（canvas）・5.21（surface-muted）／D 6.94・7.84・6.06 |
| color/outline | `ColorScheme.outline` | #88888E | #76767C | 部品の境界（図形のみ） | L 3.52（surface）／D 3.73（surface） |
| color/outline-variant | `ColorScheme.outlineVariant` | #DEDEE0 | #2E2E32 | 区切り線（比較の上下の境目） | 基準の対象外 |
| color/accent（ruri） | `ColorScheme.primary` | #1E50A2 | #709DE6 | スイッチの ON・選択中・主な操作 | L 白の文字 7.71・canvas 6.71／D 墨の文字 6.46・surface 6.13 |
| color/on-accent | `ColorScheme.onPrimary` | #FFFFFF | #18181B | accent の上の文字 | 上の行のとおり |
| color/brand | `NimiColors.brand` | #F8B500 | #F8B500 | ワードマークの印だけ | 白い地の上の文字には使わない |
| color/on-brand | `NimiColors.onBrand` | #18181B | #18181B | brand の上の文字 | 9.79 |
| color/brand-text | `NimiColors.brandText` | #8A6500 | #F8B500 | 山吹を文字に使うとき | L 5.33（surface）／D 9.29（surface） |
| color/success | `NimiColors.success` | #1A7A4C | #4CD69A | コピーできた | L 4.65（canvas）／D 9.61（墨の文字） |
| color/warning | `NimiColors.warning` | #A84B08 | #FF9F5A | 注意（非推奨のプロパティなど） | L 白の文字 5.71・canvas 4.97／D 8.29 |
| color/error | `ColorScheme.error` | #B8342A | #FF8A80 | エラー | L 5.13（canvas）／D 7.37 |
| color/on-success・on-warning・on-error | `NimiColors` / `ColorScheme.onError` | #FFFFFF | #18181B | 意味の色の上の文字 | 上の行のとおり |

ruri の値とコントラスト比は土台の「アプリの色」の表から写した。surface-muted の上の ink は、このアプリで足した組（コードの地）として計算した。outline 系は、Material の部品（Divider・OutlinedButton・Switch の枠）が標準で参照するため、土台の対応表の `NimiColors` ではなく `ColorScheme` に置く。

#### 土台との差分（色）
Material 3 の部品が使う役割のうち、土台にないもの。未指定だと `primary` などに落ち、スイッチのつまみが押したときにトラックと同じ色になる・選択中と主な操作が同じ見た目になる（2026-10-28 のレビューで判明）。

| Flutter | Light | Dark | 用途 | コントラスト比 |
|------|-------|------|------|------|
| `ColorScheme.primaryContainer` / `secondaryContainer` | #DCE5F4 | #2A3F66 | スイッチのつまみ（押した・ホバー）、選択中のセグメント・チップ、tonal のボタン | — |
| `ColorScheme.onPrimaryContainer` / `onSecondaryContainer` | #18181B | #F3F3F4 | 上の地の上の文字 | L 13.97／D 9.46 |
| `ColorScheme.inverseSurface` | #18181B | #F3F3F4 | Snackbar の地（ink と同じ） | — |
| `ColorScheme.onInverseSurface` | #F3F3F4 | #18181B | Snackbar の文字 | L 15.16 以上／D 同 |
| `ColorScheme.inversePrimary` | #709DE6 | #1E50A2 | Snackbar のアクションの文字（反対のモードの瑠璃） | L 6.46／D 6.95 |
| `ColorScheme.secondary` | accent と同じ | accent と同じ | 使う場面は今はない | — |
| `ColorScheme.surfaceContainerLowest`〜`High` | surface と同じ | surface と同じ | 土台の surface は1段だけのため | — |

部品の調整: スライダーの値のない側のトラックは `outline`（白の上で 3.52:1。`surfaceContainerHighest` のままだと 1.23:1 で図形の基準に届かない）。AppBar はスクロールしても地を canvas のままにする（`scrolledUnderElevation: 0`）。

### タイポグラフィ
土台と同じ。見出しは Murecho、本文はシステムの書体。文字の拡大に追従させる。Flutter の `TextTheme` への対応は土台のとおり。

| スタイル | 書体 | TextTheme | サイズ | ウェイト | 行間 | 用途 |
|---------|------|----------------|--------|---------|------|------|
| largeTitle | Murecho | displaySmall | 34 | Bold | 44 | 使う場面は今はない |
| title1 | Murecho | headlineMedium | 28 | Bold | 36 | 使う場面は今はない |
| title2 | Murecho | titleLarge | 22 | Bold | 30 | AppBar の題（Widget 名） |
| title3 | Murecho | titleMedium | 20 | SemiBold | 28 | ジャンル名・節の見出し |
| headline | Murecho | labelLarge / titleSmall | 17 | SemiBold | 24 | ボタン・一覧の Widget 名・プロパティ名 |
| body | システム | bodyLarge | 17 | Regular | 26 | 説明文 |
| callout | システム | bodyMedium | 16 | Regular | 24 | 一覧の一行の要約 |
| subheadline | システム | bodySmall | 15 | Regular | 22 | プロパティの一言の説明 |
| footnote | システム | labelMedium | 13 | Regular | 18 | プロパティの型・値の表示 |
| caption1 | システム | labelSmall | 12 | Regular | 16 | 比較のラベル（付けた／付けない） |
| caption2 | システム | `NimiTextStyles.caption2` | 11 | Regular | 14 | 使う場面は今はない |
| **code（土台との差分）** | 等幅のシステム書体（iOS: Menlo、Android: monospace） | `NimiTextStyles.code` | 14 | Regular | 20 | コードの表示 |

code は土台にない。コードの表示に等幅の書体が要るため足した。サイズは callout と footnote の間にし、横に長い行を減らす。

### スペーシング
土台と同じ（`NimiSpacing`）。画面の左右は md（16）。

| トークン | 値 | 用途 |
|---------|-----|------|
| 2xs | 4 | アイコンとラベルの間 |
| xs | 8 | 操作部品とその値の間 |
| sm | 12 | 操作パネルの行と行の間 |
| md | 16 | 画面の左右・カードの内側 |
| lg | 20 | 節と節の間 |
| xl | 24 | プレビューと操作パネルの間 |
| 2xl | 32 | 大きなまとまりの間 |
| 3xl | 40 | 使う場面は今はない |

### 角丸
土台と同じ（`NimiRadius`）。

| トークン | 値 | 用途 |
|---------|-----|------|
| sm | 8 | 型の印・小さなチップ |
| md | 12 | 検索欄・コードの地 |
| lg | 20 | プレビューのカード・シート |
| full | 9999 | ボタン・チップ（ピル形） |

## コンポーネント一覧
最初に要るもの。部品は Material 3 のものを土台の値でテーマにする。見た目は Figma（https://www.figma.com/design/W9DAjjGAmMzNhnCQu0BLo7/Widget-Lab?node-id=3-2。変数はこの文書と同じ名前と値）。2026-10-28 に一覧を2段、詳細を v2 にした（ADR-0004）。

- [ ] App Bar（Material 3 の `AppBar`。題は title2）
- [ ] 検索欄（`TextField`。地は surface、角丸 md）
- [ ] ジャンルのタイル（地は surface、角丸 lg。件数は title2 の accent、ジャンル名は headline、代表の名前は footnote の ink-secondary）
- [ ] 見本つきの行（見本 64×64・地は surface・角丸 md、名前・一行の要約・プロパティ数の印。区切り線は outline-variant）
- [ ] プレビューのカード（地は surface に outline-variant の方眼、角丸 lg、影なし。拡大のピル ×1 / ×2）
- [ ] コードの帯（地は surface-muted、角丸 md、code の文字。変えた行は左に accent の線）
- [ ] プロパティのチップ（選択中は accent、指定中は accent-container、既定は outline の枠。高さ 40・押せる範囲 48）
- [ ] 編集パネル（地は surface、上の角丸 lg。型ごとの操作: 太いスライダーと値の吹き出し・セグメント・ドロップダウン・Alignment の 3×3・大きな色見本・入力欄）
- [ ] 比較の表示（左右の分割と accent の仕切り＋「付けた」「付けない」のラベル）
- [ ] コードの全文のシート（行番号、変えた行は accent-container の地と accent の線、コピーのボタン）
- [ ] 説明のシート（ジャンル・説明・公式ドキュメントを開く）
- [ ] Snackbar（コピーしたことを知らせる）
- [ ] 見た目を持たない Widget の可視化（再ビルドの回数・ログ。形は ui-spec で決める）

## 未決事項
- Murecho をアプリに同梱する方法（使う字に絞るか。見出しは Widget 名の英字が多く、日本語はジャンル名・節の見出しくらい）
- コードの表示の等幅の書体を、同梱するか（システムの書体だと iOS と Android で見た目が変わる）
- 土台との差分は3つ（部品の形と動きを Material 3 にしたこと、code の文字のスタイル、Material 3 の部品が使う色の役割）。土台そのものに足すかはオーナーが決める

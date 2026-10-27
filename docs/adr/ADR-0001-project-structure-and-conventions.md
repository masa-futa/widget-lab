# ADR-0001: プロジェクトの構成と規約

> **要約**
> - 結論: 1パッケージ・機能ごとのフォルダ、Riverpod、標準の Navigator、gen-l10n（説明文は収録データに置く）、Material 3 で作る
> - 影響: このあと作る全画面と、収録する全 Widget の定義の置き方
> - お願い: なし（2026-10-28 オーナー承認）

## ステータス
承認済み（2026-10-28）

## 背景
Widget Lab を `flutter create` から作るにあたり、構成・状態管理・遷移・文言などの規約を決める必要があった。要件は docs/PRD.md（画面は一覧・検索・詳細の3つ、オフラインのみ、日本語のみ、Material 3、ダークモード対応）。flutter-project-setup の規約の既定と、他を選ぶ条件に照らして決めた。

## 決定

| 項目 | 選んだもの | 当たった条件 |
|---|---|---|
| Flutter | 3.47.8（stable の最新、Dart 3.13.7）。`.fvmrc` で固定 | — |
| 識別子・対象 | Widget Lab・org `jp.nimi`（Android `jp.nimi.widget_lab`、iOS `jp.nimi.widgetLab` は flutter create の既定）・iOS 26.0 / Android minSdk 35 | 依頼で指定（otayori にそろえる） |
| 構成 | 1パッケージ。`lib/core/`・`lib/features/{catalog,detail}/{ui,view_model,data}`。収録データは `lib/catalog/<ジャンル>/` | 既定（画面は3つ） |
| 状態 | Riverpod（riverpod_generator）。プロパティの値と比較の状態は Widget ごとの family の Notifier。画面の中だけの一時的な状態は StatefulWidget | 既定。プロパティの値はプレビュー・操作パネル・比較・コードの4か所で共有する |
| 遷移 | 標準の Navigator | 既定（ディープリンク・タブ・ログインなし） |
| モデル | 手書きの不変クラス | 既定（JSON の変換なし） |
| 文言 | UI の文言は gen-l10n の ARB（`lib/l10n/app_ja.arb`）。Widget とプロパティの説明文は収録データ（Dart の定義）に置く | 既定＋例外（説明文は数百件あり、UI の文言ではなく収録の中身のため） |
| 余白 | gap | 既定 |
| テーマ | Material 3（seed color）のライト・ダーク。余白のトークンは `AppSpacing`（ThemeExtension）に手書き | 既定（Figma なし） |
| lint | flutter_lints＋strict-casts・strict-inference・strict-raw-types と追加のルール＋riverpod_lint 3.1.9（`analysis_options.yaml` の `plugins:`） | 既定 |
| 環境 | 設定しない | 環境の区別がなく、通信もない |
| 通信・保存 | 入れない。公式ページを開くための url_launcher のみ。コピーは標準の `Clipboard` | PRD（オフラインのみ。リンクを開くときだけ外へ） |
| テスト | 層ごとの unit・widget。偽物は fake を優先。テスト名は `TC-xx: …` | 既定 |
| 生成物 | `*.g.dart` と `lib/l10n/gen/` をコミットする | 推し量り: CI がまだなく、public で clone した人がそのまま動かせるように |
| 版 | 最新に解けた。例外: build_runner は riverpod_generator 4.0.9 の `build <5.0.0` の制約で 2.16.2 に止まった（最新は 2.17.1） | — |

## 選ばなかった案
| 案 | 選ばなかった理由 |
|---|---|
| melos の複数パッケージ | 画面が少なく、部品を使い回す先もない |
| flutter_hooks | 画面の中だけの一時的な状態が少ない |
| go_router | ディープリンク・タブ・ログインがなく、要る条件に当たらない |
| freezed | JSON の変換がなく、copyWith も少ない |
| 説明文も ARB に置く | 数百件で1ファイルが巨大になり、Widget の定義と説明が離れて足しにくい |
| theme_extensions_builder | トークンが少ない |
| `--dart-define-from-file` | 置く値がない |
| golden テスト | 収録が揃ってから、見た目の崩れを守りたくなったら足す |
| integration_test・patrol | 画面をまたぐ大事な流れがない。patrol は小さい案件には重い |
| 生成物をコミットしない | CI がまだない |

## 結果
- 画面を足すときは `lib/features/<機能>/` に、Widget を足すときは `lib/catalog/<ジャンル>/` に置けばよく、置き場所で迷わない
- 説明文を ARB に置かないため、UI の文言と収録の中身で置き場所が2つになる
- 見直すきっかけ: 画面が増えて構成の条件（おおむね10画面・チームで分ける・部品の使い回し）に当たったとき、CI を入れたとき（生成物のコミット）、riverpod_generator が build 5 に対応したとき（build_runner の版）

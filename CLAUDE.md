# Widget Lab（リポジトリ全体）

UI フレームワークの部品を触って比べるアプリ群。フレームワークごとに別のアプリとして、ディレクトリを分けて置く。

## アプリ
- `flutter/`: Flutter 版（iOS / Android）。作業の前に flutter/CLAUDE.md を読む
- `swiftui/`: SwiftUI 版（iOS）。準備中
- `compose/`: Jetpack Compose 版（Android）。準備中

## 決まり
- 作業するアプリのディレクトリに入り、そのディレクトリの CLAUDE.md に従う。コマンドもそのディレクトリで実行する
- アプリをまたぐ判断は docs/adr/ に、またぐ作業の spec・計画は docs/superpowers/ に置く。アプリの中だけの判断・spec・計画は、そのアプリの docs/ に置く
- ADR の番号は、ルートとアプリごとに別に振る
- 構想: docs/concept/brief.md

## 公開について
- リポジトリは public。署名鍵・ストアの認証情報・`.env` などをコミットしない（ルートと各アプリの `.gitignore` で除外済み）

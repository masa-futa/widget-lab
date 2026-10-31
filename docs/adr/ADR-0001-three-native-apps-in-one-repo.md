# ADR-0001: Flutter / SwiftUI / Jetpack Compose を別のアプリにして、1 つのリポジトリに並べる

> **要約**
> - 結論: SwiftUI 版と Jetpack Compose 版は、Flutter 版に埋め込まず、別のネイティブアプリとして作る。3 つは 1 つのリポジトリの `flutter/`・`swiftui/`・`compose/` に置く
> - 影響: 今の Flutter のプロジェクト一式を `flutter/` に移す。ルートには全体の README・CLAUDE.md・.gitignore・構想・この ADR を置く
> - お願い: なし（2026-10-31 オーナーが選んだ）

## ステータス
承認済み（2026-10-31）

## 背景
Flutter 版（公式 Widget カタログの全 Widget を収録）ができ、SwiftUI と Jetpack Compose のコンポーネントも同じように触って確かめたくなった。

SwiftUI は Apple の OS にある SwiftUI・UIKit の上で、Jetpack Compose は Android の View の仕組みと部品の上で動く。Flutter の PlatformView は、動いている OS の部品を埋め込む仕組みなので、もう一方の OS の部品は描けない。

## 決定
- SwiftUI 版（iOS）と Jetpack Compose 版（Android）は、それぞれ別のネイティブアプリとして作る
- 3 つを 1 つのリポジトリに置き、アプリごとにディレクトリを分ける（`flutter/`・`swiftui/`・`compose/`）
- アプリをまたぐもの（構想・この種の判断・またぐ作業の spec と計画）はルートの `docs/` に、アプリの中だけのものは各アプリの `docs/` に置く。ADR の番号はルートとアプリで別に振る
- 何を収録するかなど、SwiftUI 版・Compose 版の中身は、それぞれ作るときに決める

## 選ばなかった案
- 1 つの Flutter アプリに PlatformView で埋め込み、端末ごとに選べるものを変える（iPhone は Flutter／SwiftUI、Android は Flutter／Compose）: 本物を触れるが、1 台でもう一方の OS の部品は見られない。Flutter・Swift・Kotlin のビルドを 1 つのアプリで抱える
- 1 つのアプリにして、端末で動かないほうはスクリーンショットとコードだけ見せる: 触って確かめるという目的に合わない
- Compose Multiplatform で iOS にも Compose を出す: Android の Jetpack Compose と見た目・動き（文字の描き方・スクロールの感触・一部の部品）が一致しない。Flutter・Swift・Kotlin/Native の 3 つのビルドを抱え、保守が重い。Android で SwiftUI を動かす方法はない（Skip などは SwiftUI のコードを Compose に置き換えるもので、本物ではない）
- アプリごとに別のリポジトリにする: 構想と判断を 1 か所で見られなくなる。1 人で作るので、分ける利点が小さい

## 結果
- 各アプリは、その OS の本物の部品で作れる。プラットフォームをまたぐビルドの仕組みが要らない
- 作る量は、アプリごとにほぼ丸ごと要る（収録の一覧・プロパティの定義・デモの組み立て）
- Flutter のコマンドは `flutter/` で実行するようになる

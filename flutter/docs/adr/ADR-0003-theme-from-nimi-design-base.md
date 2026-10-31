# ADR-0003: テーマを自社のデザインの土台の値で組む

> **要約**
> - 結論: ADR-0001 のテーマの行（Material 3 の seed color＋`AppSpacing`）を置き換え、色・文字・余白・角丸を自社の土台の値で組む
> - 影響: `lib/core/theme/`。画面は `NimiColors`・`NimiSpacing`・`NimiRadius`・`NimiTextStyles` から値を取る
> - お願い: なし（2026-10-28 オーナー承認）

## ステータス
承認済み（2026-10-28）。ADR-0001 の「テーマ」の行を置き換える（ADR-0001 のほかの行はそのまま）

## 背景
ADR-0001 では、Figma がない前提でテーマを `ColorScheme.fromSeed(#0175C2)` と手書きの `AppSpacing`（4/8/16/24/32）にした。その後の design-system の段で、Widget Lab は自社プロダクトに当たり、共通のデザインの土台（`nimi-design-base.md`）があることが分かった。オーナーは「部品の形と動きは Material 3、色と文字は土台」を選んだ（docs/design-system.md）。

## 決定
- `ColorScheme` はコンストラクタで土台の値を直接入れる（seed から作らない）。アプリの色は瑠璃（ruri）
- `ColorScheme` に載らない色・余白・角丸・文字は、`ThemeExtension` の `NimiColors`・`NimiSpacing`・`NimiRadius`・`NimiTextStyles` に置く
- Material 3 の部品が使い、土台にない役割（`primaryContainer`・`secondaryContainer`・inverse 系）は、docs/design-system.md の「土台との差分（色）」の値を入れる
- 見出しの Murecho は、同梱を決めるまでシステムの書体で組む

## 選ばなかった案
| 案 | 選ばなかった理由 |
|---|---|
| ADR-0001 のとおり seed から作る | 墨の地にならず、ほかの自社アプリと印象がずれる |
| 土台どおり HIG を基準に Cupertino の部品で作る | PRD で Material 3 に決めた。収録する Material の部品と同じ世界で見せたい（オーナーの選択） |
| `ColorScheme` の未指定の役割を既定値に任せる | `primary` に落ち、スイッチのつまみが押したときに見えなくなる（2026-10-28 のレビュー） |

## 結果
- 色の値は docs/design-system.md が正本で、`test/core/theme/app_theme_test.dart`（TC-56〜60）が表との一致とコントラストを確かめる
- 土台の値が変わったら、design-system.md・`lib/core/theme/`・テストの3か所を直す

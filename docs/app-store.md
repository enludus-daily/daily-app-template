# App Store 提出の準備（下書き）

> 毎日のセッションが下書きを書き、本人が確かめて App Store Connect に入力・提出する。

| 項目 | 内容 |
|---|---|
| Bundle ID | com.enludus.daily.___ |
| アプリ名の候補（30 文字以内） | 1. / 2. / 3. |
| サブタイトル（30 文字以内） | |
| カテゴリ | |
| キーワード（100 文字以内、カンマ区切り） | |
| サポート URL | https://github.com/enludus-daily/___/issues |
| 年齢区分の答え | （暴力・ギャンブル・Web 閲覧などの有無） |
| 輸出コンプライアンス | `ITSAppUsesNonExemptEncryption = NO`（標準の暗号だけ） |

## 説明（4000 文字以内）

## App プライバシーの答え（下書き。申告は本人）

- データの収集：**なし**（根拠：通信しない、解析・広告 SDK なし、保存は端末の UserDefaults だけ）
- トラッキング：なし
- Privacy manifest：`App/Resources/PrivacyInfo.xcprivacy`（UserDefaults: CA92.1）

## スクリーンショット

CI の artifact `screenshots`（iPhone 17 Pro Max = 6.9 インチ）。足りない画面は本人と相談。

## 本人がすること

- [ ] アプリ名を決め、App Store Connect の仮の名前を変える
- [ ] TestFlight で動作を確かめる
- [ ] App プライバシーを申告する
- [ ] スクリーンショット・説明を確かめる
- [ ] 審査に提出する

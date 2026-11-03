# CLAUDE.md（enludus-daily のアプリ）

このリポジトリは、enludus-daily で毎日1本作る iOS アプリ（SwiftUI）の1つ。**public**。
手順は `docs/daily-runbook.md`、開発の考え方は `.claude/skills/`（dev-lifecycle / dev-judgment / dev-workflow）。

## スキルの読み替え（このリポジトリでは、ここが優先）

- **Vault（personal-knowledge）は使わない。** セッションに付けない方針。スキルの「Vault を読む・更新する」は飛ばし、報告には「Vault: 対象外（daily のセッションには付けない）」と書く。
- **個人のリポジトリは付けない。** 付けてよいのは enludus-daily の `daily-ideas`、`daily-app-template`（読むだけ）、その日のアプリのリポジトリだけ。
- **dev-lifecycle 4 のあとで本人に戻す、は省く。** 「課題を探して作り、TestFlight まで出す」ことは本人が前もって承認している（2026-11-03）。ただし下の「止まる条件」に当たったら止める。
- **main への直接 push を許す**（1人で作る毎日のアプリのため）。ただし push の前に必ず `scripts/preflight-push.sh` を通す（pre-push フック）。

## してはいけないこと

- 審査への提出、App プライバシーの申告、App Store Connect の設定の変更（本人が行う）
- `git push --no-verify`、フック・検査・上限の無効化、`DAILY_GUARD_DISABLED` などの Variables / Secrets の変更
- daily-actions・テンプレート・ほかのアプリのリポジトリへの push
- 秘密情報・個人情報をコード・コミット・Issue・ログに書くこと（作者のメールアドレスは `noreply@anthropic.com` のまま）
- 外部の依存（SwiftPM のパッケージ）を足すこと。要るなら止めて本人に戻す
- サーバー・ログイン・広告・トラッキング・解析 SDK・個人データの収集。データは端末の中だけ（プライバシーの申告を「収集なし」に保つため）
- 標準の HTTPS 以外の暗号の実装（輸出規制の申告が変わる。`ITSAppUsesNonExemptEncryption` は NO のまま）

## 上限と止まる条件

| | 上限 | どこで守るか |
|---|---|---|
| アプリのリポジトリへの push | 1日 10 回 | `scripts/preflight-push.sh`（pre-push フック） |
| CI の実行 | 1日 12 回、連続 3 回失敗で停止 | daily-actions@v1 の guard |
| TestFlight へのアップロード | 1日 3 回、連続 2 回失敗で停止 | daily-actions@v1 の guard |
| アプリのリポジトリの作成 | 1日 2 回、連続 2 回失敗で停止 | daily-ideas の `create-app-repo.yml`（作成は Actions だけが行う） |

次のどれかに当たったら、**直すのをやめて**、daily-ideas の今日の Issue に `needs-human` を付けて、状況（何を試したか・エラーの要点・次に本人が見るもの）を書いて終える。
- 同じ失敗（エラーの要点が同じ）が **2 回** 続いた
- 上限に達した（guard の `DAILY_LIMIT` / `CONSECUTIVE_FAILURES`）
- 署名・証明書・App Store Connect の権限のエラー（`docs/signing.md` は daily-actions にある）
- 空いている枠（`daily-ideas/slots.json`）がない
- 検査（scan）が検出し、誤検出かどうか自分で決めきれない

## ビルドとテスト

Linux のセッションでは Xcode が使えない。ビルドとテストは GitHub Actions（`.github/workflows/ci.yml` → daily-actions@v1）。
- push → CI の結果を `gh api repos/enludus-daily/<repo>/actions/runs` で確かめる。失敗したらログを読んで直す
- テストは振る舞いを書く（`Tests/`、Swift Testing）。画面から処理を切り離してテストできる形にする
- 手元でできる確認：`scripts/scan-sensitive.sh .`、`python3 -c "import yaml; yaml.safe_load(open('project.yml'))"`

## 状態の言葉

「CI 通過（run の URL）」「TestFlight にアップロードした（ビルド番号）」「処理状況は未確認」を区別して書く。実行していない確認を通ったことにしない。

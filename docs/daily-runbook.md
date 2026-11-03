# 毎日の手順（22:00 JST に新しいセッションで実行）

目標：**課題を1つ見つけ、小さな iOS アプリを作り、TestFlight に上げ、提出の直前まで整える。** 提出と App プライバシーの申告は本人が行う。
迷ったら `.claude/skills/dev-judgment`、考える段階は `.claude/skills/dev-lifecycle`、実装の始めと終わりは `.claude/skills/dev-workflow`。この手順と `CLAUDE.md` の読み替えが優先。

## 0. 準備（10 分以内）

1. `enludus-daily/daily-ideas` は予約実行の設定で最初から付いている（無ければ `add_repo` で push 付きで付ける）。clone して使う。テンプレートは付けずに `git clone --depth 1 https://github.com/enludus-daily/daily-app-template` で読む（public）。
   **Vault・個人のリポジトリ・daily-actions は付けない。** daily-actions（CI・ガード・検査）を直すのは本人が始める整備用のセッションだけ。
2. `TZ=Asia/Tokyo date +%F` を今日の日付にする。daily-ideas に今日の Issue（ラベル `daily`）がすでにあれば、そこから続ける（二重に作らない）。
3. daily-ideas に今日の Issue を作る：タイトル `YYYY-MM-DD: （作るものが決まったら書き換え）`、ラベル `daily`、`building`。

## 1〜4. 課題を探して、作るものを決める（30 分以内）

dev-lifecycle の 1〜4 を **短く**（各数行）行い、今日の Issue に書く。
- 材料は、daily-ideas の open の `idea` Issue（本人や他の人が書いたもの。古い順に優先）。無ければ Web で探す（困りごとの声、既存アプリのレビューの不満など）。出典の URL を書く。
- 条件：**1 日で作れる**、端末の中だけで完結、ログイン・サーバー・課金なし、個人データを集めない、既存の有名アプリ・ゲームの再現ではない。
- 書くこと：だれの・どんな場面の困りごとか／証拠と強さ／最小の形（画面 1〜3 枚）／作らないもの／見直す条件。
- 使った `idea` Issue には、今日の Issue へのリンクをコメントし、ラベル `used` を付ける。

## 5. 枠（Bundle ID）を確保する

`daily-ideas/slots.json` で、`status: "free"` の最初の枠を `building` にし、`repo` と `date` を書いて daily-ideas の main に push する。
**空きがなければ**：TestFlight はせず、CI でのビルドとテストまでにする。今日の Issue に `needs-human`（「枠を足してほしい」）を付ける。

## 6. リポジトリを作る

名前：`app-YYYYMMDD-<英小文字とハイフンの短い名前>`（例 `app-20261104-water-log`）。public。
1. **作成は daily-ideas の Actions に頼む**（セッションは組織向けの API を呼べない。トークンも持たない）：
   `gh api -X POST repos/enludus-daily/daily-ideas/actions/workflows/create-app-repo.yml/dispatches -f ref=main -f 'inputs[name]=<名前>' -f 'inputs[description]=<一文>'`
   - `gh api repos/enludus-daily/daily-ideas/actions/workflows/create-app-repo.yml/runs?per_page=1` で、その実行が `success` になるまで待つ（数十秒）。
   - 失敗したら、ログの要点を今日の Issue に書いて `needs-human` にする（名前を変えて何度も試さない。作成は1日2回まで）。
   - `repos/.../generate` などで自分で作ろうとしない。
2. `add_repo`（push）で付けて clone し、`scripts/new-app.sh --name <型名> --display <表示名> --slot <枠>` を実行する。
3. コミットの作者を本人にする（最初のコミットの作者＝トークンの持ち主＝本人）：
   `git config user.name "$(git log --reverse --format=%an | head -1)" && git config user.email "$(git log --reverse --format=%ae | head -1)"`

## 7〜9. 形を作る → 実装 → テスト

- 画面は SwiftUI。処理は画面から切り離し（`Tally.swift` の例）、`Tests/` に振る舞いのテストを書く。
- アイコン：`python3 scripts/make-icon.py --bg ... --fg ... --glyph ...`（1024×1024、透過なし）。
- UserDefaults 以外の required reason API を使ったら、`App/Resources/PrivacyInfo.xcprivacy` を更新する。
- README.md を、その日のアプリの説明に書き換える（何を・だれの・どう使うか・作らなかったもの）。
- push（pre-push で検査と上限）→ CI を待つ → 失敗はログを読んで直す。**同じ失敗が 2 回で止める。**

## 10〜11. TestFlight

1. CI が main で通ったら：`gh api -X POST repos/enludus-daily/<repo>/actions/workflows/testflight.yml/dispatches -f ref=main`
2. 実行を待ち、結果を確かめる。署名・権限のエラーなら直そうとせず止める（daily-actions の `docs/signing.md`）。
3. 成功したら `slots.json` の枠を `testflight` にする。

## 12. 提出の直前まで

`docs/app-store.md` を埋める：アプリ名の候補（3 つ、30 文字以内）、サブタイトル、説明、キーワード、カテゴリ、年齢区分の答え、App プライバシーの答えの下書き（「データの収集なし」の根拠）、サポート URL（リポジトリの Issues）、スクリーンショット（CI の artifact `screenshots`）。

## 終わりの報告（今日の Issue にコメント）

```
状態: ready-for-review | needs-human（理由）
アプリ: <repo の URL> / Bundle ID com.enludus.daily.<枠>
CI: <run の URL> 成功/失敗
TestFlight: ビルド <番号> をアップロードした（処理状況は未確認）/ 未実施（理由）
本人がすること: アプリ名の決定・App Store Connect での名前の変更、App プライバシーの申告、スクリーンショットの確認、審査への提出
判断: <AI が決めたこと> — <理由>
未実施: <何を>（<理由>）
回数: push <n>/10、CI <n>/12、TestFlight <n>/3
Vault: 対象外（daily のセッションには付けない）
```
ラベルを `ready-for-review` か `needs-human` にし、`building` を外す。

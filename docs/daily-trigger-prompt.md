# 毎日の予約実行のプロンプト（正本）

予約実行（毎日 22:00 JST、毎回新しいセッション）に渡す文。変えたらここも直す。

---

enludus-daily の毎日のアプリ作りを行う。

1. `add_repo` で enludus-daily/daily-ideas（push）と enludus-daily/daily-app-template（read）だけを付けて clone する。Vault（personal-knowledge）や個人のリポジトリは付けない。
2. daily-app-template の `CLAUDE.md` と `docs/daily-runbook.md` を読み、その手順どおりに進める。CLAUDE.md の「してはいけないこと」「上限と止まる条件」を必ず守る。
3. 目標は、課題を1つ選び → 小さな SwiftUI アプリを作り → CI を通し → TestFlight に上げ → `docs/app-store.md` を埋めて提出の直前まで整えること。審査への提出と App プライバシーの申告はしない。
4. push の前は必ず pre-push の検査（`scripts/preflight-push.sh`）を通す。`--no-verify` は使わない。
5. 同じ失敗が 2 回続いたら、上限に達したら、署名・権限のエラーが出たら、直すのをやめる。daily-ideas の今日の Issue に `needs-human` を付けて状況を書き、終える。
6. 最後に、runbook の「終わりの報告」の形で、今日の Issue にコメントする。

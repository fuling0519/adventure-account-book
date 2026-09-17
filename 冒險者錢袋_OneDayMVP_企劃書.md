# 🗺️ 冒險者錢袋 — One-Day MVP 企劃書

> 個人記帳 App ｜ 輕 RPG 遊戲化 ｜ Flutter × SQLite ｜ 完全離線

| 項目 | 內容 |
|---|---|
| 專案類型 | 個人記帳 / 輕 RPG 遊戲化 |
| 平台 | Android / iOS（Flutter） |
| 資料儲存 | 本地端 SQLite |
| 後端 / 網路 / 登入 | 無 |
| 開發方式 | AI Agent 輔助開發 |
| 目標時程 | 1 天 |
| 成功定義 | 做出「真的能記帳」，但視覺像輕鬆冒險遊戲的 App |

---

## 1. 專案定位

把傳統記帳包裝成「冒險者管理自己的旅費與資源」：

- 🗺️ 探索世界 → 首頁
- 🎒 管理背包 → 財務總覽
- 📜 冒險紀錄 → 交易列表
- 💰 收集與消耗金幣 → 收入／支出

**核心原則：RPG 只是視覺與互動語言，不得降低記帳資料本身的清晰度。**

一句話總結取捨：

> 資料庫是蛋糕 🎂，RPG 是糖霜。

---

## 2. MVP 範圍

### 2.1 必須完成

| 功能 | 說明 |
|---|---|
| 新增收入 | 金額、分類、日期、備註 |
| 新增支出 | 金額、分類、日期、備註 |
| 編輯帳目 | 修改既有紀錄 |
| 刪除帳目 | 刪除既有紀錄 |
| 帳目列表 | 查看歷史紀錄 |
| 本月統計 | 收入、支出、結餘 |
| 分類統計 | 各類別支出佔比 |
| 本地資料庫 | App 關閉後資料仍保留 |
| RPG UI | 地圖、背包、任務等視覺語言 |
| 空狀態 | 尚無資料時提供引導 |

### 2.2 第一版不做

```text
❌ 登入 / 帳號系統       ❌ 雲端同步 / 多裝置同步
❌ AI 財務分析           ❌ 銀行 API
❌ CSV 匯入 / 匯出       ❌ 複雜預算系統
❌ 通知                  ❌ 社交功能
❌ 真正的 RPG 戰鬥       ❌ 經驗值 / 等級計算
❌ 道具商城
```

> 只有一天。不要讓 Agent 明天還在寫史萊姆戰鬥系統。

---

## 3. 技術架構

```text
Flutter App
│
├── Presentation      Screens / Widgets / Theme
├── Application       Transaction / Statistics / Category Service
├── Data              Database / Models / Repositories
└── Local Database    SQLite
```

### 選型

| 層 | 選擇 | 負責 |
|---|---|---|
| UI | Flutter | UI、Navigation、Animation |
| 狀態管理 | **Riverpod** | transactions / statistics / categories / settings |
| 資料庫 | **SQLite（sqflite）** | 帳目、分類 |

第一版**不引入**：Firebase、Supabase、REST API、Server、Cloud Database。

資料流：

```text
UI → Provider / Riverpod → Repository → SQLite
```

---

## 4. Database Schema

### transactions

```text
id
type            income | expense
amount
category_id
date
note
created_at
updated_at
```

**欄位驗證規則：**

| 欄位 | 規則 |
|---|---|
| amount | 必填，> 0（不可為 0 或負數） |
| date | 必填，不可留空 |
| category_id | 必填，需對應現有分類 |
| type | 必填，僅能是 `income` 或 `expense` |
| note | 選填 |

### categories

```text
id
name
icon
type
```

**預設分類與 icon 對照表（一次列完，不留給 Agent 自己挑）：**

| category_id | 名稱 | icon | type |
|---|---|---|---|
| food | 飲食 | 🍜 | expense |
| transport | 交通 | 🚌 | expense |
| shopping | 購物 | 🛍️ | expense |
| entertainment | 娛樂 | 🎮 | expense |
| housing | 居住 | 🏠 | expense |
| health | 健康 | ❤️ | expense |
| salary | 薪資 | 💰 | income |
| other | 其他 | 📦 | expense |

全部統一使用 Material Icons 或同一套自訂 icon set，不混搭。

---

## 5. Information Architecture

全 App 控制在 **4 個區域**。

```text
                    App
                     │
       ┌─────────────┼─────────────┐
       ↓             ↓             ↓
     🗺️ 地圖        🎒 背包        📜 冒險紀錄
       │             │             │
      首頁         財務總覽        帳目列表
       │
       └────── ＋ 新增帳目（浮動按鈕）
```

```text
┌───────────────────────────┐
│           Page            │
├───────────────────────────┤
│  🗺️        🎒        📜    │
│  地圖       背包       紀錄  │
└───────────────────────────┘
```

**App 開啟時預設停在「🗺️ 地圖」頁**（首頁），確保每次開啟體驗一致。

---

## 6. 頁面規格

### 6.1 🗺️ 首頁：冒險地圖

```text
☀️ 今日日期
「今日冒險旅程」

        🏡
       /
    🌳──🌳
         \
          🏰

💰 本月結餘
$12,580

████████░░
本月財務旅程 78%
```

**進度條公式（明確定義，避免 Agent 自行發明邏輯）：**

```text
進度 = 本月支出 ÷ 本月收入
（若本月收入為 0，進度顯示 0%）
```

若想改成其他邏輯（例如「距離月底剩餘天數」），需在此明確指定，不可留給 Agent 自行決定。

⚠️ **關鍵取捨：地圖是裝飾性 UI。** 不做可拖曳、可探索的 RPG 地圖，一張漂亮的固定地圖即可。

### 6.2 🎒 背包：財務總覽

```text
🎒 冒險者背包

💰 本月收入    $30,000
🪙 本月支出    $17,420
🏕️ 本月結餘    $12,580

🍜 飲食        $5,280
🛍️ 購物        $3,420
🚌 交通        $1,800
🎮 娛樂        $1,200
```

不建立物品系統。背包 = 財務 Dashboard 的 RPG 化名稱。

### 6.3 📜 冒險紀錄：交易列表

```text
📜 冒險紀錄

今天
🍜 午餐              -120
🚌 公車               -30

昨天
🎮 遊戲              -890
💰 薪資           +30,000
```

- 收入 `+` / 支出 `-`，以顏色區分
- **列表範圍：顯示全部歷史紀錄，由新到舊排序**（不限本月）；「本月統計」另在 §6.5 呈現，兩者邏輯各自獨立，不互相影響
- 點擊紀錄 → 查看 → 編輯 → 刪除
- **刪除需二次確認**：彈出「確定要刪除這筆冒險紀錄嗎？」Dialog，避免手滑誤刪

### 6.4 ➕ 新增帳目（最重要的操作）

按 `＋` 開啟 Bottom Sheet 或 Dialog：

```text
新增冒險紀錄

[ 支出 ] [ 收入 ]

金額      $ 120

類別
🍜 飲食   🚌 交通   🛍️ 購物
🎮 娛樂   🏠 生活   ❤️ 其他

日期      2026/09/17
備註      午餐

[ 完成冒險 ]
```

送出流程：

```text
＋120 → 小金幣動畫 → 資料庫更新 → 首頁數字更新
```

### 6.5 📊 統計

```text
本月
收入 $30,000 ／ 支出 $17,420 ／ 結餘 $12,580

分類
🍜 飲食 30% ｜ 🛍️ 購物 20% ｜ 🚌 交通 10%
🎮 娛樂  7% ｜ 🏠 其他 33%
```

Pie Chart 或 Bar Chart 皆可。**圖表要服務資料**，不要做成魔法召喚陣。

---

## 7. Visual Design System

### 關鍵字

> Light Fantasy × Cozy Adventure × Modern Mobile UI
> 低飽和、霧面、安靜；圓潤、輕盈、大量留白

### 色彩

| 用途 | 色系 |
|---|---|
| Background | 奶油白 |
| Primary | 天空藍 |
| Secondary | 鼠尾草綠 |
| Accent | 蜂蜜黃 |
| Income | 柔和綠 |
| Expense | 柔和珊瑚 |
| Text | 暖灰 |
| Border | 淺米灰 |

### 禁止

```text
❌ 大面積黑色
❌ 高飽和霓虹色
❌ 金色滿版
❌ 過度厚重的石板 UI
❌ 像 MMORPG HUD 一樣塞滿資訊
```

### 元件

| 元件 | 規範 |
|---|---|
| Card | 圓角 16–20px，陰影極淡 |
| Button | 大圓角、文字清楚 |
| Icon | 統一使用 Material Icons 或單一自訂 icon set |
| 數字 | 大、粗、清楚 |
| 標題 | 略帶冒險感（圓體／手寫感） |
| 正文 | 維持現代 App 的可讀性 |

> Icon 不要從六個不同 icon pack 各抓一隻，否則會變成「勇者從六款遊戲湊裝備」。

---

## 8. Animation（只做這 4 個）

1. **新增帳目** — 金幣飛入錢袋
2. **Dashboard 數字** — Count-up（`$0 → $120`）
3. **Navigation** — 頁面淡入／滑動
4. **Toast** — `✨ 冒險紀錄已保存`

其餘全部不做。

---

## 9. Project Structure

```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── theme.dart
├── models/
│   ├── transaction.dart
│   └── category.dart
├── database/
│   ├── database.dart
│   └── transaction_dao.dart
├── repositories/
│   └── transaction_repository.dart
├── providers/
│   ├── transaction_provider.dart
│   └── statistics_provider.dart
├── screens/
│   ├── map/
│   ├── backpack/
│   ├── journal/
│   └── transaction/
├── widgets/
│   ├── transaction_card.dart
│   ├── money_display.dart
│   ├── category_chip.dart
│   └── adventure_button.dart
└── utils/
    └── formatters.dart
```

---

## 10. Agent 開發流程（逐段驗收）

| Phase | 任務 |
|---|---|
| 1. Setup | Flutter project、Theme、Navigation、SQLite、Riverpod |
| 2. Database | Transaction / Category model、CRUD、Repository |
| 3. Core UI | Home、Journal、Add Transaction、Edit Transaction |
| 4. Statistics | Monthly summary、Category summary、Charts |
| 5. RPG UI | Map、Backpack、Adventure styling、Animations、Empty states |
| 6. QA | 新增／編輯／刪除／重啟保存／統計正確／UI overflow |

> 💡 選配測試（時間允許再做）：**跨月邊界**——例如 9/30 記一筆帳，隔天進入 10 月後，該筆帳是否仍正確歸屬在 9 月的統計中。記帳 App 常見的 bug 來源，一天專案可視時間決定是否納入。

---

## 11. Definition of Done

### 資料
- [ ] 可以新增收入
- [ ] 可以新增支出
- [ ] 可以修改
- [ ] 可以刪除（需二次確認 Dialog）
- [ ] App 重啟後資料仍存在
- [ ] 欄位驗證生效（金額 > 0、日期必填）

### 統計
- [ ] 收入計算正確
- [ ] 支出計算正確
- [ ] 結餘計算正確
- [ ] 分類統計正確

### UI
- [ ] 首頁完成
- [ ] 背包完成
- [ ] 冒險紀錄完成
- [ ] 新增帳目完成
- [ ] RPG 視覺一致
- [ ] 沒有 Overflow
- [ ] 沒有明顯 UI Bug

### 體驗
- [ ] 打開 App 不需登入
- [ ] 三秒內理解怎麼新增帳目
- [ ] 新增一筆帳不超過幾個操作
- [ ] 完全離線可使用

---

## 12. 砍功能原則

時間不夠時，**依序往下砍**：

```text
RPG 動畫 → 地圖互動 → 成就 → 任務 → 複雜統計
```

**絕對不能砍：**

```text
新增帳目 ／ 編輯 ／ 刪除 ／ SQLite ／ 統計
```

---

## 13. 驗收場景

App 打開後長這樣：

```text
       ☀️ 我的冒險

    🏡────🌳────🏰

       本月結餘
       $12,580
     ████████░░

 ─────────────────
   🍜 午餐       -120
   🚌 公車        -30
   🎮 遊戲       -890

             ＋

 🗺️        🎒        📜
地圖       背包       紀錄
```

按 `＋` → 支出 `$150` → 🍰 甜點 → 「完成冒險」
→ 寫入 SQLite → 回首頁 → **$12,580 → $12,430**
→ 關閉 App、重新開啟 → **那筆 $150 還在。**

這樣就算成功。

其餘的世界地圖、寵物夥伴、成就、裝備、季節活動，都是第二天以後才長出來的樹枝。

**第一天，只需要讓這棵樹活著。**

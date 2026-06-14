# LitRadar HarmonyOS

生物医学文献追踪系统 — 鸿蒙PC原生版。

**M1: Python 后端 + ArkTS 前端 | M2: 纯原生 ArkTS 引擎，零后端依赖**

---

## 版本

| 版本 | 分支 | 说明 |
|------|------|------|
| **M2 (当前)** | `main` | 纯 ArkTS 原生引擎，直连 PubMed/Europe PMC，零外部依赖 |
| M1 | [`m1-python-backend`](https://github.com/fastbiography-hue/litradar-harmonyos/tree/m1) | Python Flask 后端 + ArkTS 前端 |

---

## M2 架构（纯原生）

```
ArkTS UI  →  FetchEngine（PubMed + Europe PMC 直连）
         →  ScoreEngine（去重 + 0-10 评分）
         →  ConfigService（本地 Preferences 配置）
         →  本地 RDB（主存储，不在是缓存）
         ↕  SchedulerService（后台定时抓取）
         ↕  NotifyService（鸿蒙通知中心）
```

**零后端原则**：不再依赖 Python/Flask，所有功能在 ArkTS 原生层实现。

---

## 项目结构

```
litradar-harmonyos-mvp/
├── backend/                              # Python 后端 (M1 保留，M2 不再需要)
│   ├── litradar.py
│   ├── config.yaml
│   └── requirements.txt
│
└── harmonyos_app/                        # ArkTS 鸿蒙工程
    ├── build-profile.json5               # API 23 (6.1.0)
    ├── hvigorfile.ts
    ├── AppScope/
    ├── hvigor/
    └── entry/src/main/ets/
        ├── entryability/EntryAbility.ets
        ├── model/PaperModel.ets          # 数据模型 + API 映射
        ├── engine/                        # M2 新增：原生引擎
        │   ├── FetchEngine.ets            #   PubMed + Europe PMC 直连
        │   └── ScoreEngine.ets            #   去重 (Jaccard) + 评分 (0-10)
        ├── service/
        │   ├── ApiService.ets             #   M1 HTTP 客户端 (M2 保留未用)
        │   ├── ConfigService.ets          #   M2 新增：本地配置持久化
        │   ├── DbService.ets              #   本地 RDB 读写
        │   ├── SchedulerService.ets       #   M2 新增：后台定时任务
        │   └── NotifyService.ets          #   M2 新增：通知中心推送
        ├── worker/LitRadarWorker.ets      #   M2 新增：后台 Worker
        └── pages/
            ├── Index.ets                  #   三栏总布局
            ├── QueryPanel.ets             #   左栏：检索策略
            ├── PaperList.ets              #   中栏：文献列表
            └── PaperDetail.ets            #   右栏：文献详情
```

---

## 快速启动

### M2 方式（推荐，零后端）

直接用 DevEco Studio 打开 `harmonyos_app/`，Build → Run 即可。首次启动自动写入默认配置（3 组预设检索策略），点击"立即抓取"直接从 PubMed/Europe PMC 拉取文献。

### M1 方式（需要 Python）

```bash
cd backend
pip install -r requirements.txt
python litradar.py serve --host 0.0.0.0 --port 7749
```

然后修改 `PaperModel.ets` 中的 `API_BASE` 指向服务器地址。

---

## M2 引擎能力

| 引擎 | 功能 | 对标 Python |
|------|------|------------|
| `FetchEngine.fetchPubMed()` | NCBI E-utilities esearch → efetch → JSON 解析 | `fetch_pubmed()` |
| `FetchEngine.fetchEuropePMC()` | Europe PMC REST API, cursorMark 翻页 | `fetch_europe_pmc()` |
| `ScoreEngine.deduplicatePapers()` | DOI > PMID > Jaccard(≥0.85) 三级去重 | `deduplicate()` |
| `ScoreEngine.scorePapers()` | 标题+6/摘要+3/MeSH+1/期刊+1/年份+0.5/引用+0.5 | `score_papers()` |

---

## 技术栈

| 层 | M2 | M1 |
|----|-----|-----|
| 检索引擎 | ArkTS FetchEngine (直连 API) | Python BioPython + paperscraper |
| 评分引擎 | ArkTS ScoreEngine (纯算法) | Python score_papers() |
| 配置存储 | @ohos.data.preferences | config.yaml |
| 数据存储 | @ohos.data.relationalStore (RDB) | SQLite (Python) |
| 通知 | @ohos.notificationManager | plyer (Python) |
| 调度 | @ohos.WorkScheduler | APScheduler (Python) |

---

## M2 待完成（M3 迭代）

- [ ] T-04 QueryEditor：可视化编辑检索策略
- [ ] T-08 PDF 阅读器：WebView 内嵌 PMC PDF
- [ ] T-09 文献笔记 + 标签
- [ ] T-10 BibTeX/引用导出
- [ ] T-11 全文搜索栏
- [ ] T-12 Zotero 账号同步

---

## License

MIT

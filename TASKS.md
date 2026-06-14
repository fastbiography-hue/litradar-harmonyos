# TASKS.md — 当前可执行任务

## 状态说明
`completed` / `in_progress` / `pending` / `planned`

## M2 P0（消灭后端依赖）

| 任务 | 名称 | 状态 |
|------|------|:--:|
| M2-T01 | ScoreEngine 去重+评分 | completed |
| M2-T03 | ConfigService 原生查询配置 | completed |
| M2-T02 | FetchEngine PubMed/Europe PMC 直连 | completed |
| M2-T04 | NativeRunFlow 原生抓取流程 | pending |

### 执行顺序
M2-T03 → M2-T02 → M2-T04

## M3 P0（学术知识中枢）

| 任务 | 名称 | 状态 |
|------|------|:--:|
| M3-T01 | AiService 可插拔 AI 接口 | pending |
| M3-T02 | ChineseSearchTranslator AI 检索式生成 | pending |
| M3-T03 | AiAbstractParser AI 摘要解析 | pending |
| M3-T04 | CitationExport 12 种引用格式 | pending |
| M3-T05 | KnowledgeNotes Markdown 知识笔记 | pending |

### 执行顺序
M3-T01 → M3-T02 → M3-T03 → M3-T04 → M3-T05

## M3 P1/P2（已规划，不强制实现）

| 任务 | 名称 | 状态 |
|------|------|:--:|
| M3-T06 | KnowledgeGraph 知识图谱 | planned |
| M3-T07 | SharePanel 分享面板入库 | planned |
| M3-T08 | DesktopWidget 桌面小组件 | planned |
| M3-T09 | WeeklyDigest AI 周报 | planned |
| M3-T10 | FulltextTranslation PMC 全文翻译 | planned |
| M3-T11 | DistributedReading 分布式阅读 | planned |
| M3-T12 | PenAnnotationOCR 手写批注 | planned |
| M3-T13 | SemanticScholarGraph 引用图谱 | planned |
| M3-T14 | PanguLocalAI 盘古端侧 AI | planned |
| M3-T15 | ZoteroGroups 群组协作 | planned |

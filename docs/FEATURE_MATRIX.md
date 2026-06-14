# Feature Matrix

| 模块 | 功能 | 状态 | UI入口 | 核心文件 | 构建通过 | 备注 |
|---|---|---|---|---|---|---|
| **M2** | | | | | | |
| M2 | ConfigService 本地配置 | done | 首次启动自动写入 | ConfigService.ets | yes | |
| M2 | FetchEngine PubMed | done | 搜索框/"更新订阅"按钮 | FetchEngine.ets | yes | ESearch+ESummary |
| M2 | FetchEngine Europe PMC | done | 同上 | FetchEngine.ets | yes | cursorMark翻页 |
| M2 | ScoreEngine 去重+评分 | done | fetch流水线 | ScoreEngine.ets | yes | DOI/PMID/Jaccard |
| M2 | DbService 本地RDB | done | fetch流水线 | DbService.ets | yes | upsert+query |
| M2 | NativeRunFlow | done | "更新订阅"按钮 | Index.ets | yes | 零/api/run引用 |
| M2 | 自由搜索 | done | 工具栏搜索框 | Index.ets | yes | 任意关键词 |
| M2 | 检索策略管理 | done | QueryPanel +/✎/✕ | QueryPanel.ets | yes | 新增/编辑/删除 |
| M2 | 三栏文献浏览 | done | 主界面 | Index.ets | yes | 评分色标 |
| M2 | 空/加载/错误状态 | done | 中栏+右栏 | common/*.ets | yes | |
| **M3** | | | | | | |
| M3 | AiService 可插拔AI | done | 引擎层 | AiService.ets | yes | 5 providers |
| M3 | AI Provider 设置 | done | ⚙ 设置面板 | SettingsPanel.ets | yes | API Key输入+开关 |
| M3 | AI 摘要解析 | done | 🤖 AI解析按钮 | PaperDetail.ets | yes | 需API Key |
| M3 | AI 检索式生成 | done | AI检索按钮 | SearchTranslatorPanel.ets | yes | 中文→PubMed MeSH |
| M3 | 12种引用格式 | done | 📋引用导出按钮 | CitationExportEngine.ets | yes | Grid选择器 |
| M3 | PDF 阅读 | done | 📄 PDF按钮 | PaperDetail.ets | yes | OA+PMCID才有 |
| M3 | 文献笔记 | partial | 📝 笔记按钮 | PaperDetail.ets | yes | 仅内存,不持久化 |
| M3 | 文献分类Collections | partial | 左栏下方 | CollectionsPanel.ets | yes | 硬编码3个假分类 |
| M3 | KnowledgeNotes WikiLink | partial | 无独立页面 | WikiLinkEngine.ets | yes | 引擎有,UI无入口 |
| M3 | WeeklyDigest AI周报 | missing | 无 | WeeklyDigestEngine.ets | yes | 引擎未接入UI |
| M3 | FulltextTranslation | missing | 无 | FulltextTranslationEngine.ets | yes | 引擎未接入UI |
| M3 | KnowledgeGraph | missing | 无 | KnowledgeGraphEngine.ets | yes | 引擎未接入UI |
| **M4** | | | | | | |
| M4 | DesignSystem tokens | done | styles/ | DesignTokens.ets | yes | |
| M4 | TopToolbar | done | 工具栏 | TopToolbar.ets | yes | 搜索+按钮 |
| **M5** | | | | | | |
| M5 | ReadingContinuation | partial | 无UI | ReadingContinuationService.ets | yes | 服务有,UI无入口 |
| M5 | ShareImport parser | done | 无UI(纯引擎) | IdentifierParser.ets | yes | DOI/PMID识别 |
| M5 | NotificationService | partial | 无UI | NotificationService.ets | yes | 服务有,UI无入口 |
| M5 | SendToDevice | partial | 无UI | SendToDeviceService.ets | yes | 服务有,UI无入口 |
| M5 | DistributedState | planned | 无 | DistributedStateService.ets | yes | 仅接口 |
| M5 | WatchCompanion | planned | 无 | WatchCompanionService.ets | yes | 仅接口 |
| M5 | LocalAIAdapter | planned | 无 | LocalAiAdapter.ets | yes | 返回unavailable |
| M5 | CloudBackupAdapter | planned | 无 | CloudBackupAdapter.ets | yes | 仅接口 |

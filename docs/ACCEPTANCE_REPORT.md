# Acceptance Report — LitRadar HarmonyOS

## 1. 当前真实完成的功能 (done)

| 功能 | 验证 |
|------|------|
| 纯原生 PubMed + Europe PMC 抓取 | Index.ets → FetchEngine.fetchAll() |
| ScoreEngine 去重+0-10评分 | Index.ets → deduplicatePapers + scorePapers |
| 本地 RDB 存储 | Index.ets → DbService.upsertPapers + queryPapers |
| 自由搜索任意关键词 | TopToolbar 搜索框 → onSearch |
| 检索策略新增/编辑/删除 | QueryPanel +/✎/✕ 按钮 |
| 三栏文献浏览 | 左QueryPanel+Collections / 中PaperList / 右PaperDetail |
| AI Provider 配置 | ⚙ 设置面板 |
| AI 摘要结构化解析 | 🤖 AI解析按钮 |
| 12种引用格式导出 | 📋 引用导出 → Grid选择器 |
| PMC PDF 打开 | 📄 PDF 按钮 (OA+PMCID) |
| AI 中文检索式生成 | AI检索 → SearchTranslatorPanel |
| 空/加载/错误状态组件 | EmptyState/LoadingState/ErrorState |
| 设计系统 tokens | styles/DesignTokens.ets |

## 2. 当前 partial 的功能

| 功能 | 缺失 |
|------|------|
| 文献笔记 | 仅内存存储,App重启丢失 |
| 文献分类Collections | 硬编码3个假分类,不连接DbService |
| AI解析结果 | 无缓存,每次重新请求 |
| 引用文本 | 无法一键复制到剪贴板 |
| KnowledgeNotes WikiLink | 引擎存在,无笔记管理页面 |
| M5 生态服务 | 服务存在,UI全无入口 |

## 3. 当前 missing 的功能

- WeeklyDigest AI周报 (引擎有,UI无)
- FulltextTranslation 全文翻译 (引擎有,UI无)
- KnowledgeGraph 知识图谱可视化
- 后台定时自动抓取
- 桌面小组件
- 分布式接力阅读
- 手表端
- Zotero 同步
- 云备份

## 4. 当前 broken 的功能

无 (所有已接入UI的功能构建通过)

## 5. 构建结果

check.sh ✅ | hvigor ⏳ (需DevEco Studio验证)

## 6. 是否仍依赖 Python backend

否。ApiService.ets 保留旧代码但从未被任何页面 import。`backend/` 仅作文档参考。

## 7. 是否可以进入下一阶段

可以。M2+M3核心功能完整,UI可交互。优先补partial功能(笔记持久化/Collections连接/引用复制)。

## 8. 下一步建议任务

1. 笔记持久化到Preferences或RDB
2. Collections连接到实际文献数据
3. 引用文本一键复制
4. WeeklyDigest接入UI

# TASKS.md — M2 当前可执行任务

## 任务状态说明
- `pending` — 可领取
- `in_progress` — 执行中
- `completed` — 已完成

---

## P0 任务（必须完成）

### M2-T01: ScoreEngine 完善
- **状态**: completed
- **文件**: `docs/tasks/M2-T01-score-engine.md`
- **目标**: 完善去重/评分的边界情况和性能
- **约束**: 只改 `engine/ScoreEngine.ets` 和测试相关文件

### M2-T02: FetchEngine 完善
- **状态**: pending
- **文件**: `docs/tasks/M2-T02-fetch-engine.md`
- **目标**: 完善 PubMed/Europe PMC 解析和错误处理
- **约束**: 只改 `engine/FetchEngine.ets`

### M2-T03: ConfigService 完善
- **状态**: completed
- **文件**: `docs/tasks/M2-T03-config-service.md`
- **目标**: 完善检索策略增删改查和默认值
- **约束**: 只改 `service/ConfigService.ets`

---

## 等待添加的任务

以下任务尚未编写详细规格，暂不可执行：
- T-04 QueryEditor
- T-08 PDF 阅读器
- T-09 笔记+标签
- T-10 导出
- T-11 全文搜索
- T-12 Zotero 同步

---

## 任务执行规则

1. 一次只做一个
2. 修改文件数 ≤ 3（除非任务规格明确允许更多）
3. 完成后更新此表状态
4. 完成后输出：修改文件、验证方式、风险

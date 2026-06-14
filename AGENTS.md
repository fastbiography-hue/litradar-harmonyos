# AGENTS.md

本项目使用 Claude Code 作为 AI 编程助手。

## 前置要求

执行任何任务前，Claude Code 必须读取：
- `CLAUDE.md` — 主指令
- `README.md` — 项目概述
- `ARCHITECTURE.md` — 架构边界
- `ROADMAP.md` — 路线图
- `TASKS.md` — 任务列表

## 任务流程

1. 从 `TASKS.md` 找 `pending` 任务
2. 读 `docs/tasks/<任务ID>.md` 了解详细规格
3. 设为 `in_progress`
4. 执行（只改允许的文件）
5. 验证
6. 设为 `completed`，输出结果

## 约束

参见 `CLAUDE.md` 和 `ARCHITECTURE.md` 中的完整规则。

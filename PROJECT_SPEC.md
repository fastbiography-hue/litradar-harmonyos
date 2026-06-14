# LitRadar HarmonyOS — 项目规格书

## 项目定位

LitRadar 是一个 HarmonyOS ArkTS 原生学术文献发现、管理、分析与知识中枢工具。
它不是 Zotero 的简单复制，而是面向中文科研用户的**主动式文献雷达系统**。

## 总体目标

| 阶段 | 目标 |
|------|------|
| **M2** | 消灭 Python 后端，完成纯 HarmonyOS 原生文献抓取、去重、评分、排序、入库、展示 |
| **M3** | 升级为学术知识中枢，加入 AI 检索辅助、AI 摘要解析、多格式引用导出、Markdown 知识笔记、双向链接、知识图谱和鸿蒙生态能力 |

## 技术边界

1. HarmonyOS ArkTS 原生
2. 零后端（backend/ 仅作旧逻辑参考）
3. 不新增运行时第三方 npm 依赖（`@ohos.*` 系统 API 除外）
4. API Key 只能由用户在设置页配置，保存在本地 Preferences 中
5. 所有 AI 后端必须走统一 `AiService` 接口
6. 所有网络失败必须 graceful fallback，App 不崩溃
7. 所有新功能必须可关闭
8. 所有任务必须可构建、可回滚、可验收

## 目录边界

```
harmonyos_app/entry/src/main/ets/
├── pages/          — 页面容器（UI + 事件协调，不写业务逻辑）
├── components/     — 可复用 UI 组件（纯展示）
├── models/         — 数据模型
├── services/       — 配置、数据库、HTTP、系统能力封装
├── engines/        — 抓取、评分、去重、AI、引用导出、知识图谱算法
├── entryability/   — Ability 入口（仅窗口初始化）
└── worker/         — 后台 Worker

backend/            — M1 Python 旧代码，只读参考，不作为运行时依赖
docs/tasks/         — 任务卡
```

## 开发流程

1. 一次只做一个任务
2. 每个任务完成后：`check.sh` → `hvigorw assembleHap` → `git commit`
3. 构建失败只能修当前任务引入的问题
4. 不允许大规模重构（一次改 3+ 文件需说明理由）
5. 不确定的 HarmonyOS API 先做接口抽象 + 占位实现
6. 任何无法确认的系统能力写入 `docs/risks.md`

## 验收标准

- [ ] M2 全部 P0 任务完成且构建通过
- [ ] App 不依赖 Python 后端可独立运行
- [ ] FetchEngine 直连 PubMed + Europe PMC 返回 ≥ 50 篇
- [ ] ScoreEngine 评分与 Python 偏差 ≤ 0.1
- [ ] ConfigService 支持增删改查 query profiles
- [ ] 首次安装自动写入默认配置

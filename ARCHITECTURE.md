# ARCHITECTURE.md — LitRadar 架构边界

## 分层

```
pages/          — UI 页面（只做渲染，不写业务逻辑）
components/     — 可复用 UI 组件（纯展示，不含数据请求）
services/       — 数据服务层（配置、数据库、HTTP、通知、调度）
engines/        — 计算引擎层（评分、去重、抓取）
model/          — 数据模型
worker/         — 后台 Worker
entryability/   — Ability 入口（仅窗口初始化）
```

## 规则

### pages/ 只能做
- ArkUI 组件声明
- `@State` / `@Link` / `@Prop` 状态管理
- 调用 services 层的函数
- 调用 engines 层的纯函数

### pages/ 不能做
- 直接操作数据库
- 直接发起 HTTP 请求
- 包含评分/去重算法

### services/ 只能做
- ConfigService: 读写 Preferences
- DbService: RDB CRUD（保持 papers 表 schema 不变）
- ApiService: HTTP 请求（M1 遗留，M2 不再使用）
- SchedulerService: 定时任务注册/取消
- NotifyService: 系统通知发布

### engines/ 只能做
- ScoreEngine: 去重、评分（纯函数，无副作用）
- FetchEngine: 外部 API 直连（只返回 Paper[]，不存库）

### 禁止
- 把所有逻辑堆进 `Index.ets`
- 在 pages 里写 SQL
- 在 engines 里操作 UI 状态
- 修改 `backend/` 目录

## 数据流

```
用户操作 → pages/Index.ets (事件处理)
         → engines/FetchEngine.fetchAll() (拉取)
         → engines/ScoreEngine.scorePapers() (评分)
         → services/DbService.upsertPapers() (入库)
         → services/DbService.queryPapers() (读取)
         → pages/PaperList.ets (渲染)
```

## backend/ 状态

`backend/` 目录包含 M1 阶段的 Python 代码，仅供理解原始算法逻辑参考。
**不允许修改、不允许新增依赖、不允许作为运行时组件。**

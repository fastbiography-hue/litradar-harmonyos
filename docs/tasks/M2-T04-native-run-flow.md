# M2-T04: NativeRunFlow — 原生抓取流程

## 目标
把"立即抓取"按钮从旧 Python `/api/run` 切换到 ArkTS 原生流程。

## 允许修改
- `pages/Index.ets`
- `TASKS.md`

## 禁止修改
- `backend/`
- 不再调用任何 Python API

## 流程
1. 用户选择 query profile
2. 点击"立即抓取"
3. ConfigService 读取 profile
4. FetchEngine 拉取 PubMed + Europe PMC
5. ScoreEngine 去重、评分、排序
6. DbService upsert 到本地 RDB
7. UI 刷新列表
8. 文献详情可正常打开

## 验收标准
- [ ] 不导入 ApiService
- [ ] 不调用任何 `/api/*` 端点
- [ ] 抓取成功 → 列表刷新 → 详情可查看
- [ ] 抓取失败 → Toast 错误提示

## Commit
`feat(native-run): replace backend run flow with native pipeline`

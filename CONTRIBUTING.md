# CONTRIBUTING.md

## 开发环境

- DevEco Studio (API 23 / 6.1.0)
- HarmonyOS PC 设备或模拟器

## 提交规范

- 一个 commit 只做一个任务
- commit message 格式: `T-XX: 简短描述`
- 不提交构建产物（`build/`, `.hvigor/`, `oh_modules/`）

## 代码规范

- 只使用 `@ohos.*` 系统 API
- 字段名 camelCase（ArkTS 限制）
- 数据模型在 `model/PaperModel.ets`
- 数据库操作在 `service/DbService.ets`
- 页面组件不写业务逻辑

## 不能提交的内容

- API Key、密码、证书
- 构建产物（`.hap`, `.hsp`）
- `local.properties`
- `oh-package-lock.json5`

## 发布流程

1. 任务完成 → 更新 `TASKS.md`
2. 本地验证通过 → DevEco Studio Build
3. commit → push
4. 里程碑完成 → 打 tag → 创建 Release

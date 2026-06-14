# HarmonyOS ArkTS 编码规则

## 模块导入

```typescript
// ✅ 正确
import http from '@ohos.net.http'
import relationalStore from '@ohos.data.relationalStore'
import promptAction from '@ohos.promptAction'

// ❌ 禁止
import axios from 'axios'
import lodash from 'lodash'
```

## 字段访问

```typescript
// ✅ ArkTS 严格模式只允许点号
paper.title
paper.relevanceScore

// ❌ 括号索引不允许
paper['Title']
```

## 异常处理

```typescript
// ✅ 必须 try-catch
async function fetchData(): Promise<Result> {
  try {
    const res = await http.request(...)
    return res
  } catch (e) {
    console.error('fetch failed:', (e as Error).message)
    return defaultValue
  }
}

// ❌ 不允许无 catch 的 try-finally
```

## 数据库操作

```typescript
// ✅ RdbPredicates 列名不带 SQL 双引号
predicates.equalTo('Query Tag', value)

// ❌ 不要多套一层引号
predicates.equalTo('"Query Tag"', value)
```

## @Entry 规则

```typescript
// ✅ main_pages.json 只列有 @Entry 的独立页面
// main_pages.json: ["pages/Index"]

// ❌ 嵌入组件不要加 @Entry 和列入 main_pages.json
// QueryPanel, PaperList, PaperDetail 无 @Entry
```

## throw 规则

```typescript
// ✅
throw new Error('message')

// ❌
throw 'message'
throw e  // 不能 re-throw 任意类型
```

## 返回类型

```typescript
// ✅ 显式声明
async function load(): Promise<void> { ... }

// ❌ 隐式推断可能编译失败
async function load() { ... }
```

## deprecated API

```typescript
// ⚠️ getContext(this) 已标记 deprecated
// 目前仍可使用，M3 迁移到新 API
```

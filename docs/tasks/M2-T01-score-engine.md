# M2-T01: ScoreEngine 完善

## 目标
完善 ArkTS 版 ScoreEngine：去重边界情况、评分精度对齐 Python、排序输出。

## 背景
ScoreEngine 已实现基础功能（Jaccard 去重 + 0-10 评分），需要：
1. 处理空标题/空作者等边界输入
2. 验证评分与 Python `score_papers()` 偏差 ≤ 0.1
3. 确保排序稳定

## 允许修改的文件
- `entry/src/main/ets/engine/ScoreEngine.ets`

## 禁止修改的文件
- `pages/` 所有文件（不允许改 UI）
- `engine/FetchEngine.ets`
- `service/` 所有文件
- `backend/` 所有文件

## 输入
```typescript
papers: Paper[]       // 含空字段的文献列表
keywords: string[]    // 评分关键词
```

## 输出
```typescript
Paper[]  // 去重后、按 relevanceScore 降序排列
```

## 验收标准
- [ ] 空 title 不崩溃，返回空字符串
- [ ] 空 abstract 不影响评分
- [ ] DOI 大小写去重正确（"10.1234/A" vs "10.1234/a"）
- [ ] PMID 精确匹配去重
- [ ] Jaccard ≥ 0.85 判定重复（标题仅标点差异）
- [ ] 评分上限 10.0，下限 0.0
- [ ] 高影响期刊列表与 Python 一致
- [ ] 排序稳定（同分文献保持输入顺序）

## 风险
无。ScoreEngine 是纯函数，无外部依赖，不影响其他模块。

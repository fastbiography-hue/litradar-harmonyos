# M3-T02: ChineseSearchTranslator — AI 检索式生成

## 目标
中文科研问题 → 专业英文检索式 / MeSH / PubMed query 的 AI 辅助生成。

## 允许修改
- `engines/SearchTranslator.ets`
- `models/SearchTranslationModel.ets`
- `components/SearchTranslatorPanel.ets`
- `pages/Index.ets` 最小接入

## 输入
`长读长测序 单倍型分型 阿尔茨海默病 APOE风险`

## 输出
englishKeywords, meshTerms, pubmedQuery, europePmcQuery, explanation, warnings

## 要求
- [ ] 调用 AiService
- [ ] 无 API Key 时显示可读错误
- [ ] 生成结果可编辑
- [ ] 用户确认后保存为 query profile
- [ ] 不自动执行检索

## Commit
`feat(search): add AI Chinese query translator`

# M3-T03: AiAbstractParser — AI 摘要结构化解析

## 目标
选中文献后用 AI 解析摘要，输出结构化学术解读。

## 允许修改
- `engines/AbstractParser.ets`
- `models/AbstractAnalysisModel.ets`
- `components/AbstractAnalysisPanel.ets`
- `components/PaperDetail.ets` 最小接入

## 输出字段
researchQuestion, methods, mainFindings, limitations, relevanceScore, relevanceReason, keywords, studyType

## 要求
- [ ] 调用 AiService
- [ ] 无 abstract 时不崩溃
- [ ] 无 API Key 时显示配置提示
- [ ] 结果可缓存到本地

## Commit
`feat(ai): add structured abstract analysis`

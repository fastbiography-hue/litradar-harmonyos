# M3-T04: CitationExport — 12 种引用格式导出

## 目标
实现 GB/T 7714 / APA 7 / Vancouver / IEEE / MLA / Chicago / Harvard / BibTeX / RIS / CSL-JSON / Word / Markdown 导出。

## 允许修改
- `engines/CitationExportEngine.ets`
- `models/CitationModel.ets`
- `components/CitationExportPanel.ets`
- `components/PaperDetail.ets` 最小接入

## 要求
- [ ] 单篇 + 批量导出
- [ ] 复制到剪贴板
- [ ] 字段缺失不崩溃
- [ ] 引用格式函数为纯函数

## Commit
`feat(citation): add multi-format citation export`

// models/SearchTranslationModel.ets
// M3-T02: AI 中文检索式翻译结果模型

export interface SearchTranslationResult {
  originalChinese: string
  englishKeywords: string[]
  meshTerms: string[]
  pubmedQuery: string
  europePmcQuery: string
  explanation: string
  warnings: string[]
  createdAt: number
}

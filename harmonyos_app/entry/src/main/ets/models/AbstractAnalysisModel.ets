// models/AbstractAnalysisModel.ets
// M3-T03: AI 摘要结构化解析结果模型

export interface AbstractAnalysis {
  paperId: string
  researchQuestion: string
  methods: string
  mainFindings: string
  limitations: string
  relevanceScore: number
  relevanceReason: string
  keywords: string[]
  studyType: string
  clinicalValue: string
  mechanismValue: string
  createdAt: number
  updatedAt: number
}

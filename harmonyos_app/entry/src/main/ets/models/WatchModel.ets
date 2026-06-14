// models/WatchModel.ets — M4-T06: 手表端数据模型
export interface WatchTopPaper {
  title: string
  relevanceScore: number
  journal: string
}

export interface WatchDigest {
  generatedAt: number
  summary: string
  newPaperCount: number
}

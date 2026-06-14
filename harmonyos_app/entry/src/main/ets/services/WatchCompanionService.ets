// services/WatchCompanionService.ets — M4-T06: 手表伴侣数据服务
import type { Paper } from '../model/PaperModel'
import type { WatchTopPaper } from '../models/WatchModel'

export function getWatchTopPapers(papers: Paper[], topN: number = 3): WatchTopPaper[] {
  return papers
    .filter((p: Paper) => p.relevanceScore >= 5)
    .sort((a: Paper, b: Paper) => b.relevanceScore - a.relevanceScore)
    .slice(0, topN)
    .map((p: Paper): WatchTopPaper => ({
      title: (p.title || '').substring(0, 60),
      relevanceScore: p.relevanceScore,
      journal: p.journal || ''
    }))
}

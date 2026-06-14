// services/WidgetDataService.ets
// M3-T09: 桌面小组件数据服务
import type { Paper } from '../model/PaperModel'

export interface WidgetPaper {
  title: string
  firstAuthor: string
  journal: string
  relevanceScore: number
}

/**
 * Get top N high-scoring papers for desktop widget display.
 * Returns synchronously from a pre-fetched list.
 */
export function getTopPapersForWidget(papers: Paper[], topN: number = 3): WidgetPaper[] {
  return papers
    .filter((p: Paper) => p.relevanceScore >= 5)
    .sort((a: Paper, b: Paper) => b.relevanceScore - a.relevanceScore)
    .slice(0, topN)
    .map((p: Paper): WidgetPaper => ({
      title: p.title || '',
      firstAuthor: p.firstAuthor || '',
      journal: p.journal || '',
      relevanceScore: p.relevanceScore
    }))
}

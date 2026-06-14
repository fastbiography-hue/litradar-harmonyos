// worker/LitRadarWorker.ets
import WorkSchedulerExtensionAbility from '@ohos.WorkSchedulerExtensionAbility'
import { getConfig } from '../service/ConfigService'
import { upsertPapersDB } from '../service/DbService'
import { fetchAll } from '../engine/FetchEngine'
import { deduplicatePapers, scorePapers } from '../engine/ScoreEngine'
import type { Paper } from '../model/PaperModel'

export default class LitRadarWorker extends WorkSchedulerExtensionAbility {
  onWorkStart(workInfo: object): void {
    this.doWork().then(() => {
      // Work done
    }).catch((e: Error) => {
      console.error('[LitRadarWorker] work failed:', e.message)
    })
  }

  onWorkStop(workInfo: object): void {
    console.info('[LitRadarWorker] work stopped')
  }

  private async doWork(): Promise<void> {
    try {
      const cfg = await getConfig(this.context)
      let allPapers: Paper[] = []
      for (const q of cfg.queries) {
        if (!q.alertOnNew) continue
        try {
          const batch = await fetchAll(q.query, q.sources, q.dateFrom, cfg.maxResultsPerSource, cfg.ncbiApiKey)
          for (const p of batch) {
            p.queryTag = q.name
          }
          allPapers = allPapers.concat(batch)
        } catch (e) {
          console.error(`[LitRadarWorker] fetch failed for ${q.name}:`, (e as Error).message)
        }
      }
      if (allPapers.length > 0) {
        allPapers = deduplicatePapers(allPapers)
        allPapers = scorePapers(allPapers, cfg.scoreKeywords)
        await upsertPapersDB(this.context, allPapers)
        const highScoreCount = allPapers.filter((p: Paper) => p.relevanceScore >= 7).length
        console.info(`[LitRadarWorker] fetched ${allPapers.length} papers, ${highScoreCount} high-score`)
      }
    } catch (e) {
      console.error('[LitRadarWorker] doWork failed:', (e as Error).message)
    }
  }
}

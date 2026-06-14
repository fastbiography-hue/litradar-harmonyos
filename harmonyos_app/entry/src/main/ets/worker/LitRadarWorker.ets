// worker/LitRadarWorker.ets
import WorkSchedulerExtensionAbility from '@ohos.WorkSchedulerExtensionAbility'
import { init, getEnabledProfiles } from '../service/ConfigService'
import { upsertPapers } from '../service/DbService'
import { fetchAll } from '../engine/FetchEngine'
import { deduplicatePapers, scorePapers } from '../engine/ScoreEngine'
import type { Paper } from '../model/PaperModel'
import type { QueryProfile } from '../models/QueryProfile'

export default class LitRadarWorker extends WorkSchedulerExtensionAbility {
  onWorkStart(workInfo: object): void {
    this.doWork().then(() => {}).catch((e: Error) => {
      console.error('[LitRadarWorker] work failed:', e.message)
    })
  }

  onWorkStop(workInfo: object): void {
    console.info('[LitRadarWorker] work stopped')
  }

  private async doWork(): Promise<void> {
    try {
      init(this.context)
      const profiles: QueryProfile[] = await getEnabledProfiles()
      let allPapers: Paper[] = []
      for (const profile of profiles) {
        if (!profile.enabled) continue
        try {
          const batch: Paper[] = await fetchAll(profile, 20)
          allPapers = allPapers.concat(batch)
        } catch (e) {
          console.error(`[LitRadarWorker] fetch failed for ${profile.name}:`, (e as Error).message)
        }
      }
      if (allPapers.length > 0) {
        allPapers = deduplicatePapers(allPapers)
        const keywords: string[] = profiles.flatMap((p: QueryProfile) => p.keywords)
        allPapers = scorePapers(allPapers, keywords)
        await upsertPapers(this.context, allPapers)
      }
    } catch (e) {
      console.error('[LitRadarWorker] doWork failed:', (e as Error).message)
    }
  }
}

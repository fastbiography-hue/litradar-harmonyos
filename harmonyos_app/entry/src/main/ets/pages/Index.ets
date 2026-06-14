// pages/Index.ets — M2: 纯原生引擎，不依赖 Python 后端
import { Paper, QueryConfig, AppState } from '../model/PaperModel'
import { upsertPapers, queryPapers } from '../service/DbService'
import { getConfig } from '../service/ConfigService'
import type { AppConfig, QueryConfig as CfgQuery } from '../service/ConfigService'
import { fetchAll } from '../engine/FetchEngine'
import { deduplicatePapers, scorePapers } from '../engine/ScoreEngine'
import QueryPanel from './QueryPanel'
import PaperList from './PaperList'
import PaperDetail from './PaperDetail'
import common from '@ohos.app.ability.common'
import promptAction from '@ohos.promptAction'

interface StatsInfo {
  total: number
  oa: number
  downloaded: number
  highRelevance: number
}

@Entry
@Component
struct Index {
  @State queries: QueryConfig[] = []
  @State papers: Paper[] = []
  @State selectedQuery: string = ''
  @State selectedPaper: Paper | null = null
  @State isLoading: boolean = false
  @State stats: StatsInfo = { total: 0, oa: 0, downloaded: 0, highRelevance: 0 }

  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  private appConfig: AppConfig | null = null

  async aboutToAppear(): Promise<void> {
    try {
      this.appConfig = await getConfig(this.context)
      this.loadQueriesFromConfig()
      this.papers = await queryPapers(this.context, null, 200)
      this.computeStats()
    } catch (e) {
      console.error('[Index] aboutToAppear failed:', (e as Error).message)
    }
  }

  loadQueriesFromConfig(): void {
    if (!this.appConfig) return
    this.queries = this.appConfig.queries.map((q: CfgQuery): QueryConfig => ({
      name: q.name,
      query: q.query
    }))
  }

  computeStats(): void {
    let oa = 0
    let high = 0
    for (const p of this.papers) {
      if (p.isOA === 'Yes') oa++
      if (p.relevanceScore >= 7) high++
    }
    this.stats = { total: this.papers.length, oa: oa, downloaded: 0, highRelevance: high }
  }

  async onQuerySelected(queryName: string): Promise<void> {
    this.selectedQuery = queryName
    this.selectedPaper = null
    this.isLoading = true
    try {
      this.papers = await queryPapers(this.context, queryName === '' ? null : queryName, 200)
    } catch (e) {
      console.error('[Index] onQuerySelected failed:', (e as Error).message)
    } finally {
      this.isLoading = false
      this.computeStats()
    }
  }

  async onRunClicked(): Promise<void> {
    if (!this.appConfig) {
      promptAction.showToast({ message: '配置加载失败，请重启 App', duration: 3000 })
      return
    }
    const cfg = this.appConfig
    const queryName = this.selectedQuery === '' ? null : this.selectedQuery
    const targets: CfgQuery[] = queryName
      ? cfg.queries.filter((q: CfgQuery) => q.name === queryName)
      : cfg.queries

    if (targets.length === 0) {
      promptAction.showToast({ message: '没有匹配的检索策略', duration: 3000 })
      return
    }

    this.isLoading = true
    promptAction.showToast({ message: '正在抓取文献，约需 30-120 秒...', duration: 5000 })

    try {
      let allPapers: Paper[] = []
      let sourceErrors: string[] = []
      for (const q of targets) {
        try {
          const batch = await fetchAll(q.query, q.sources, q.dateFrom, cfg.maxResultsPerSource, cfg.ncbiApiKey)
          for (const p of batch) {
            p.queryTag = q.name
          }
          allPapers = allPapers.concat(batch)
          console.info(`[Index] ${q.name}: ${batch.length} papers`)
        } catch (e) {
          sourceErrors.push(`${q.name}: ${(e as Error).message}`)
        }
      }

      if (allPapers.length === 0 && sourceErrors.length > 0) {
        promptAction.showToast({ message: `网络请求失败: ${sourceErrors[0]}`, duration: 5000 })
      }

      allPapers = deduplicatePapers(allPapers)
      allPapers = scorePapers(allPapers, cfg.scoreKeywords)

      // Try to store to DB (non-blocking if fails)
      try {
        await upsertPapers(this.context, allPapers)
      } catch (dbErr) {
        console.error('[Index] upsertPapers failed:', (dbErr as Error).message)
      }

      // Use fetched+scored papers directly for immediate display
      if (queryName) {
        this.papers = allPapers.filter((p: Paper) => p.queryTag === queryName)
      } else {
        this.papers = allPapers
      }
      this.computeStats()

      promptAction.showToast({
        message: `完成：发现 ${allPapers.length} 篇`,
        duration: 4000
      })
    } catch (e) {
      promptAction.showToast({ message: `抓取失败: ${(e as Error).message}`, duration: 4000 })
    } finally {
      this.isLoading = false
    }
  }

  build() {
    Column() {
      Row() {
        Text('LitRadar')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2F5496')
          .margin({ left: 16 })

        Blank()

        Text(`共 ${this.stats.total} 篇 | OA: ${this.stats.oa} | 高分: ${this.stats.highRelevance}`)
          .fontSize(13)
          .fontColor('#666666')
          .margin({ right: 16 })

        Button(this.isLoading ? '抓取中...' : '立即抓取')
          .enabled(!this.isLoading)
          .backgroundColor('#2F5496')
          .fontColor(Color.White)
          .height(32)
          .margin({ right: 16 })
          .onClick(() => this.onRunClicked())
      }
      .width('100%')
      .height(56)
      .backgroundColor('#F0F4FF')
      .border({ width: { bottom: 1 }, color: '#D0D9F0' })

      Row() {
        QueryPanel({
          queries: $queries,
          selectedQuery: $selectedQuery,
          onQuerySelected: (name: string) => this.onQuerySelected(name)
        })
        .width(220)
        .height('100%')

        Divider().vertical(true).strokeWidth(1).color('#E0E0E0')

        PaperList({
          papers: $papers,
          selectedPaper: $selectedPaper,
          isLoading: $isLoading
        })
        .flexGrow(1.2)
        .height('100%')

        Divider().vertical(true).strokeWidth(1).color('#E0E0E0')

        PaperDetail({
          paper: $selectedPaper
        })
        .flexGrow(1)
        .height('100%')
      }
      .width('100%')
      .flexGrow(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}

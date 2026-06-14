// pages/Index.ets — M2: 纯原生引擎，ConfigService + FetchEngine + ScoreEngine
import { Paper, QueryConfig } from '../model/PaperModel'
import { upsertPapers, queryPapers } from '../service/DbService'
import { init, initDefaultProfiles, getProfiles } from '../service/ConfigService'
import type { QueryProfile } from '../models/QueryProfile'
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
  private profiles: QueryProfile[] = []

  async aboutToAppear(): Promise<void> {
    try {
      await init(this.context)
      await initDefaultProfiles()
      this.profiles = await getProfiles()
      this.loadQueriesFromProfiles()
      this.papers = await queryPapers(this.context, null, 200)
      this.computeStats()
    } catch (e) {
      console.error('[Index] aboutToAppear failed:', (e as Error).message)
    }
  }

  loadQueriesFromProfiles(): void {
    this.queries = this.profiles
      .filter((p: QueryProfile) => p.enabled)
      .map((p: QueryProfile): QueryConfig => ({
        name: p.name,
        query: p.pubmedQuery
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
    const queryName = this.selectedQuery === '' ? null : this.selectedQuery
    const targets: QueryProfile[] = queryName
      ? this.profiles.filter((p: QueryProfile) => p.name === queryName)
      : this.profiles.filter((p: QueryProfile) => p.enabled)

    if (targets.length === 0) {
      promptAction.showToast({ message: '没有匹配的检索策略', duration: 3000 })
      return
    }

    this.isLoading = true
    promptAction.showToast({ message: '正在抓取文献，约需 30-120 秒...', duration: 5000 })

    try {
      let allPapers: Paper[] = []
      let sourceErrors: string[] = []
      for (const profile of targets) {
        try {
          const batch = await fetchAll(profile, 100)
          allPapers = allPapers.concat(batch)
          console.info(`[Index] ${profile.name}: ${batch.length} papers`)
        } catch (e) {
          sourceErrors.push(`${profile.name}: ${(e as Error).message}`)
        }
      }

      if (allPapers.length === 0 && sourceErrors.length > 0) {
        promptAction.showToast({ message: `网络请求失败: ${sourceErrors[0]}`, duration: 5000 })
      }

      allPapers = deduplicatePapers(allPapers)
      allPapers = scorePapers(allPapers, this.profiles.flatMap((p: QueryProfile) => p.keywords))

      try {
        await upsertPapers(this.context, allPapers)
      } catch (dbErr) {
        console.error('[Index] upsertPapers failed:', (dbErr as Error).message)
      }

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

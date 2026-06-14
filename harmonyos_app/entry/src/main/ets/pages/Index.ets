// pages/Index.ets — M4: M2/M3 功能 + M4 组件
import { Paper, QueryConfig } from '../model/PaperModel'
import { upsertPapers, queryPapers } from '../service/DbService'
import { init, initDefaultProfiles, getProfiles } from '../service/ConfigService'
import type { QueryProfile } from '../models/QueryProfile'
import { fetchAll } from '../engine/FetchEngine'
import { deduplicatePapers, scorePapers } from '../engine/ScoreEngine'
import QueryPanel from './QueryPanel'
import PaperList from './PaperList'
import PaperDetail from './PaperDetail'
import TopToolbar from '../components/TopToolbar'
import EmptyState from '../components/common/EmptyState'
import LoadingState from '../components/common/LoadingState'
import ErrorState from '../components/common/ErrorState'
import common from '@ohos.app.ability.common'
import promptAction from '@ohos.promptAction'

interface StatsInfo { total: number; oa: number; downloaded: number; highRelevance: number }

@Entry
@Component
struct Index {
  @State queries: QueryConfig[] = []
  @State papers: Paper[] = []
  @State selectedQuery: string = ''
  @State selectedPaper: Paper | null = null
  @State isLoading: boolean = false
  @State stats: StatsInfo = { total: 0, oa: 0, downloaded: 0, highRelevance: 0 }
  @State fetchError: string = ''

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
    } catch (e) { this.fetchError = (e as Error).message }
  }

  loadQueriesFromProfiles(): void {
    this.queries = this.profiles.filter((p: QueryProfile) => p.enabled)
      .map((p: QueryProfile): QueryConfig => ({ name: p.name, query: p.pubmedQuery }))
  }

  computeStats(): void {
    let oa = 0; let high = 0
    for (const p of this.papers) { if (p.isOA === 'Yes') oa++; if (p.relevanceScore >= 7) high++ }
    this.stats = { total: this.papers.length, oa, downloaded: 0, highRelevance: high }
  }

  async onQuerySelected(queryName: string): Promise<void> {
    this.selectedQuery = queryName; this.selectedPaper = null; this.isLoading = true
    try { this.papers = await queryPapers(this.context, queryName === '' ? null : queryName, 200) }
    catch (e) { console.error('[Index] onQuerySelected:', (e as Error).message) }
    finally { this.isLoading = false; this.computeStats() }
  }

  async onRunClicked(): Promise<void> {
    this.fetchError = ''
    const queryName = this.selectedQuery === '' ? null : this.selectedQuery
    const targets: QueryProfile[] = queryName
      ? this.profiles.filter((p: QueryProfile) => p.name === queryName)
      : this.profiles.filter((p: QueryProfile) => p.enabled)
    if (targets.length === 0) { promptAction.showToast({ message: '无检索策略', duration: 3000 }); return }
    this.isLoading = true
    promptAction.showToast({ message: '正在抓取，约 30-120 秒...', duration: 5000 })
    try {
      let allPapers: Paper[] = []; let errs: string[] = []
      for (const profile of targets) {
        try { allPapers = allPapers.concat(await fetchAll(profile, 100)) }
        catch (e) { errs.push(`${profile.name}: ${(e as Error).message}`) }
      }
      if (allPapers.length === 0 && errs.length > 0) { this.fetchError = errs[0]; this.isLoading = false; return }
      allPapers = deduplicatePapers(allPapers)
      allPapers = scorePapers(allPapers, this.profiles.flatMap((p: QueryProfile) => p.keywords))
      try { await upsertPapers(this.context, allPapers) } catch (dbErr) { console.error('[Index] upsert:', (dbErr as Error).message) }
      this.papers = queryName ? allPapers.filter((p: Paper) => p.queryTag === queryName) : allPapers
      this.computeStats()
      promptAction.showToast({ message: `完成：${allPapers.length} 篇`, duration: 4000 })
    } catch (e) { this.fetchError = (e as Error).message }
    finally { this.isLoading = false }
  }

  async onSearch(rawQuery: string): Promise<void> {
    this.fetchError = ''; this.isLoading = true; this.selectedQuery = ''
    const tempProfile: QueryProfile = {
      id: 'search', name: rawQuery.substring(0, 30), enabled: true,
      keywords: rawQuery.split(/\s+/).filter((w: string) => w.length > 2),
      pubmedQuery: rawQuery, europePmcQuery: rawQuery,
      createdAt: 0, updatedAt: 0
    }
    try {
      let papers: Paper[] = await fetchAll(tempProfile, 40)
      if (papers.length === 0) { this.fetchError = '未找到结果，尝试更具体的关键词'; this.isLoading = false; return }
      papers = deduplicatePapers(papers)
      papers = scorePapers(papers, tempProfile.keywords)
      try { await upsertPapers(this.context, papers) } catch (dbErr) { console.error('[Index] upsert:', (dbErr as Error).message) }
      this.papers = papers; this.computeStats()
    } catch (e) { this.fetchError = (e as Error).message }
    finally { this.isLoading = false }
  }

  build() {
    Column() {
      TopToolbar({
        statsTotal: this.stats.total, statsOA: this.stats.oa, statsHigh: this.stats.highRelevance,
        isLoading: this.isLoading, onRunClick: () => this.onRunClicked(),
        onSearch: (q: string) => this.onSearch(q)
      })
      Row() {
        QueryPanel({ queries: $queries, selectedQuery: $selectedQuery, onQuerySelected: (n: string) => this.onQuerySelected(n) })
          .width(220).height('100%')
        Divider().vertical(true).strokeWidth(1).color('#E0E0E0')
        Column() {
          if (this.isLoading) { LoadingState({ message: '正在抓取...' }) }
          else if (this.fetchError) { ErrorState({ message: this.fetchError, onRetry: () => this.onRunClicked() }) }
          else if (this.papers.length === 0) { EmptyState({ message: '暂无文献，点击"立即抓取"开始' }) }
          else { PaperList({ papers: $papers, selectedPaper: $selectedPaper, isLoading: $isLoading }) }
        }.flexGrow(1.2).height('100%')
        Divider().vertical(true).strokeWidth(1).color('#E0E0E0')
        Column() {
          if (!this.selectedPaper) { EmptyState({ message: '← 点击文献查看详情' }) }
          else { PaperDetail({ paper: $selectedPaper }) }
        }.flexGrow(1).height('100%')
      }.width('100%').flexGrow(1)
    }.width('100%').height('100%').backgroundColor('#FFFFFF')
  }
}

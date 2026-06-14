// pages/Index.ets — M4 专业桌面工作台
import { Paper, QueryConfig } from '../model/PaperModel'
import { upsertPapers, queryPapers } from '../service/DbService'
import { init, initDefaultProfiles, getProfiles, addProfile, deleteProfile, updateProfile } from '../service/ConfigService'
import { initAiConfig } from '../services/AiConfigService'
import { initNotes } from '../services/NoteService'
import type { QueryProfile } from '../models/QueryProfile'
import { fetchAll } from '../engine/FetchEngine'
import { deduplicatePapers, scorePapers } from '../engine/ScoreEngine'
import QueryPanel from './QueryPanel'
import PaperList from './PaperList'
import PaperDetail from './PaperDetail'
import TopToolbar from '../components/TopToolbar'
import DesktopWorkbench from '../components/layout/DesktopWorkbench'
import SettingsPanel from '../components/SettingsPanel'
import SearchTranslatorPanel from '../components/SearchTranslatorPanel'
import CollectionsPanel from '../components/CollectionsPanel'
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
  @State showSettings: boolean = false
  @State showAiSearch: boolean = false
  @State showNotes: boolean = false
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  private profiles: QueryProfile[] = []

  async aboutToAppear(): Promise<void> {
    try {
      await init(this.context); await initDefaultProfiles(); await initAiConfig(this.context)
      await initNotes(this.context); this.profiles = await getProfiles()
      this.loadQueriesFromProfiles(); this.papers = await queryPapers(this.context, null, 200); this.computeStats()
    } catch (e) { this.fetchError = (e as Error).message }
  }

  async reloadProfiles(): Promise<void> {
    this.profiles = await getProfiles(); this.loadQueriesFromProfiles()
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

  async onSaveQuery(name: string, pubmed: string, epmc: string, keywords: string, enabled: boolean): Promise<void> {
    const id = name.toLowerCase().replace(/\s+/g, '-')
    const kw = keywords ? keywords.split(',').map((s: string) => s.trim()).filter((s: string) => s !== '') : pubmed.split(/\s+/).filter((w: string) => w.length > 2)
    const found = this.profiles.find((p: QueryProfile) => p.name === name)
    if (found) {
      found.pubmedQuery = pubmed; found.europePmcQuery = epmc; found.keywords = kw
      found.enabled = enabled; found.updatedAt = Date.now()
      await updateProfile(found)
    } else {
      await addProfile({ id, name, enabled, keywords: kw, pubmedQuery: pubmed, europePmcQuery: epmc, createdAt: Date.now(), updatedAt: Date.now() })
    }
    await this.reloadProfiles()
  }

  async onRunClicked(): Promise<void> {
    this.fetchError = ''
    const queryName = this.selectedQuery === '' ? null : this.selectedQuery
    const targets: QueryProfile[] = queryName ? this.profiles.filter((p: QueryProfile) => p.name === queryName) : this.profiles.filter((p: QueryProfile) => p.enabled)
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
    } catch (e) { this.fetchError = (e as Error).message } finally { this.isLoading = false }
  }

  async onSearch(rawQuery: string): Promise<void> {
    this.fetchError = ''; this.isLoading = true; this.selectedQuery = ''
    const tempProfile: QueryProfile = { id: 'search', name: rawQuery.substring(0, 30), enabled: true, keywords: rawQuery.split(/\s+/).filter((w: string) => w.length > 2), pubmedQuery: rawQuery, europePmcQuery: rawQuery, createdAt: 0, updatedAt: 0 }
    try {
      let papers: Paper[] = await fetchAll(tempProfile, 40)
      if (papers.length === 0) { this.fetchError = '未找到结果，尝试更具体的关键词'; this.isLoading = false; return }
      papers = deduplicatePapers(papers); papers = scorePapers(papers, tempProfile.keywords)
      try { await upsertPapers(this.context, papers) } catch (dbErr) { console.error('[Index] upsert:', (dbErr as Error).message) }
      this.papers = papers; this.computeStats()
    } catch (e) { this.fetchError = (e as Error).message } finally { this.isLoading = false }
  }

  build() {
    Stack() {
    Column() {
      TopToolbar({
        statsTotal: this.stats.total, statsOA: this.stats.oa, statsHigh: this.stats.highRelevance,
        isLoading: this.isLoading, onRunClick: () => this.onRunClicked(),
        onSearch: (q: string) => this.onSearch(q),
        onAiSearch: () => { this.showAiSearch = !this.showAiSearch },
        onNotes: () => { this.showNotes = !this.showNotes },
        onSettings: () => { this.showSettings = !this.showSettings }
      })
      DesktopWorkbench({
        sidebar: this.sidebarContent,
        mainContent: this.mainContent,
        detailPanel: this.detailContent
      })
    }.width('100%').height('100%')

    if (this.showSettings) { this.overlay(SettingsPanel, () => { this.showSettings = false }) }
    if (this.showAiSearch) { this.overlay(SearchTranslatorPanel, () => { this.showAiSearch = false }) }
    if (this.showNotes) {
      Column() {
        Scroll() { Column() { Text('📒 知识笔记').fontSize(16).fontWeight(FontWeight.Bold).margin({ bottom: 12 }); TextArea({ placeholder: '使用 [[双向链接]] 引用文献...', text: '' }).height(200).fontSize(13).margin({ bottom: 12 }).backgroundColor('#F5F7FA').borderRadius(6); Button('保存').width('100%').height(36).fontSize(14).backgroundColor('#2F5496').fontColor('#FFF').borderRadius(6).onClick(() => { this.showNotes = false }) }.padding(24).width('100%').alignItems(HorizontalAlign.Start) }.width(400).backgroundColor('#FFF').borderRadius(12)
      }.width('100%').height('100%').backgroundColor('#00000044').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
      .onClick(() => { this.showNotes = false })
    }
    }.width('100%').height('100%')
  }

  @Builder overlay(content: new () => any, dismiss: () => void) {
    Column() {
      Column() { content() }.width(640).backgroundColor('#FFFFFF').borderRadius(12)
    }.width('100%').height('100%').backgroundColor('#00000044')
    .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
    .onClick(() => dismiss())
  }

  @Builder sidebarContent() {
    Column() {
      QueryPanel({ queries: $queries, selectedQuery: $selectedQuery,
        onQuerySelected: (n: string) => this.onQuerySelected(n),
        onDeleteQuery: async (n: string) => { if (this.selectedQuery === n) this.onQuerySelected(''); const found = this.profiles.find((p: QueryProfile) => p.name === n); if (found) { await deleteProfile(found.id); await this.reloadProfiles() } },
        onSaveQuery: (n: string, pub: string, ep: string, kw: string, en: boolean) => { this.onSaveQuery(n, pub, ep, kw, en) }
      })
      CollectionsPanel({ onCollectionSelected: (name: string) => this.onQuerySelected(name) })
    }
  }

  @Builder mainContent() {
    Column() {
      if (this.isLoading) { LoadingState({ message: '正在检索文献...' }) }
      else if (this.fetchError) { ErrorState({ message: this.fetchError, onRetry: () => { this.fetchError = ''; this.papers = []; this.computeStats() } }) }
      else if (this.papers.length === 0) {
        Column() {
          Text('暂无文献').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333').margin({ bottom: 8 })
          Text('输入关键词搜索 PubMed + Europe PMC，或点击"更新订阅"抓取预设策略文献').fontSize(13).fontColor('#999').margin({ bottom: 20 })
          Row() {
            Button('更新订阅').height(36).fontSize(13).backgroundColor('#2F5496').fontColor('#FFF').borderRadius(6).padding({ left: 20, right: 20 }).margin({ right: 10 }).onClick(() => this.onRunClicked())
            Button('AI 生成检索式').height(36).fontSize(13).backgroundColor('#F0EEFF').fontColor('#722ED1').borderRadius(6).padding({ left: 20, right: 20 }).onClick(() => { this.showAiSearch = true })
          }
        }.width('100%').flexGrow(1).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
      }
      else { PaperList({ papers: $papers, selectedPaper: $selectedPaper, isLoading: $isLoading }) }
    }.width('100%').height('100%')
  }

  @Builder detailContent() {
    Column() {
      if (!this.selectedPaper) {
        Column() {
          Text('选择一篇文献').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#BBB').margin({ bottom: 8 })
          Text('点击左侧文献列表后，这里会显示摘要、AI解析、引用导出和笔记').fontSize(12).fontColor('#CCC').textAlign(TextAlign.Center)
        }.width('100%').flexGrow(1).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).padding(30)
      } else { PaperDetail({ paper: $selectedPaper }) }
    }.width('100%').height('100%')
  }
}

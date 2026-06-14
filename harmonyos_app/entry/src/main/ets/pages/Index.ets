// pages/Index.ets
import { Paper, QueryConfig, StatsInfo, AppState } from '../model/PaperModel'
import { fetchPapers, fetchQueries, fetchStats, checkHealth, triggerRun } from '../service/ApiService'
import { upsertPapers, queryPapers } from '../service/DbService'
import QueryPanel from './QueryPanel'
import PaperList from './PaperList'
import PaperDetail from './PaperDetail'
import common from '@ohos.app.ability.common'
import promptAction from '@ohos.promptAction'

@Entry
@Component
struct Index {
  @State queries: QueryConfig[] = []
  @State papers: Paper[] = []
  @State selectedQuery: string = ''
  @State selectedPaper: Paper | null = null
  @State isLoading: boolean = false
  @State stats: StatsInfo = { total: 0, oa: 0, downloaded: 0, highRelevance: 0 }
  @State backendOnline: boolean = false

  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  async aboutToAppear(): Promise<void> {
    try {
      this.backendOnline = await checkHealth()
      if (this.backendOnline) {
        await this.loadQueries()
        await this.loadPapers(null)
        await this.loadStats()
      } else {
        this.papers = await queryPapers(this.context, null, 200)
        promptAction.showToast({ message: '后端离线，显示本地缓存数据', duration: 3000 })
      }
    } catch (e) {
      console.error('[Index] aboutToAppear failed:', (e as Error).message)
    }
  }

  async loadQueries(): Promise<void> {
    try {
      this.queries = await fetchQueries()
    } catch (e) {
      console.error('[Index] loadQueries failed:', (e as Error).message)
    }
  }

  async loadPapers(queryName: string | null): Promise<void> {
    this.isLoading = true
    try {
      const remote: Paper[] = await fetchPapers(queryName, 200)
      await upsertPapers(this.context, remote)
      this.papers = remote
    } catch (e) {
      this.papers = await queryPapers(this.context, queryName, 200)
      promptAction.showToast({ message: '从本地缓存加载', duration: 2000 })
    } finally {
      this.isLoading = false
    }
  }

  async loadStats(): Promise<void> {
    try {
      this.stats = await fetchStats()
    } catch (e) {
      console.error('[Index] loadStats failed:', (e as Error).message)
    }
  }

  async onQuerySelected(queryName: string): Promise<void> {
    this.selectedQuery = queryName
    this.selectedPaper = null
    await this.loadPapers(queryName === '' ? null : queryName)
  }

  async onRunClicked(): Promise<void> {
    if (!this.backendOnline) {
      promptAction.showToast({ message: '后端未启动，请先运行 python litradar.py serve', duration: 4000 })
      return
    }
    this.isLoading = true
    promptAction.showToast({ message: '正在抓取文献，约需 30-120 秒...', duration: 5000 })
    try {
      const result = await triggerRun(this.selectedQuery === '' ? null : this.selectedQuery)
      await this.loadPapers(this.selectedQuery === '' ? null : this.selectedQuery)
      await this.loadStats()
      promptAction.showToast({
        message: `完成：发现 ${result.found} 篇，新增 ${result.saved} 篇`,
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

        Circle({ width: 10, height: 10 })
          .fill(this.backendOnline ? '#52C41A' : '#FF4D4F')
          .margin({ right: 8 })

        Text(this.backendOnline ? '后端在线' : '后端离线')
          .fontSize(12)
          .fontColor(this.backendOnline ? '#52C41A' : '#FF4D4F')
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

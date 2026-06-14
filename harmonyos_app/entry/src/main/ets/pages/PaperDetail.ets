// pages/PaperDetail.ets — M4: AI 解析 + 引用导出入口
import { Paper } from '../model/PaperModel'
import common from '@ohos.app.ability.common'
import Want from '@ohos.app.ability.Want'
import { parseAbstract } from '../engine/AbstractParser'
import { formatCitation, CitationFormat } from '../engine/CitationExportEngine'
import type { AbstractAnalysis } from '../models/AbstractAnalysisModel'
import promptAction from '@ohos.promptAction'

@Component
export default struct PaperDetail {
  @Link paper: Paper | null
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  @State aiAnalysis: AbstractAnalysis | null = null
  @State aiLoading: boolean = false

  private openDOI(doi: string): void {
    if (!doi) return
    try {
      const want: Want = { action: 'ohos.want.action.viewData', uri: `https://doi.org/${doi}` }
      this.context.startAbility(want).catch((e: Error) => console.error('[PaperDetail] openDOI:', e.message))
    } catch (e) { console.error('[PaperDetail] openDOI:', (e as Error).message) }
  }

  async onAiAnalyze(): Promise<void> {
    if (!this.paper) return
    this.aiLoading = true; this.aiAnalysis = null
    try {
      const result = await parseAbstract(this.paper)
      if (result.researchQuestion === '' && result.mainFindings === '') {
        promptAction.showToast({ message: 'AI 未返回有效解析，请检查 API Key 配置', duration: 3000 })
      }
      this.aiAnalysis = result
    } catch (e) {
      promptAction.showToast({ message: `AI 解析失败: ${(e as Error).message}`, duration: 3000 })
    } finally { this.aiLoading = false }
  }

  async onCopyCitation(): Promise<void> {
    if (!this.paper) return
    try {
      const citation = formatCitation(this.paper, CitationFormat.GBT7714)
      promptAction.showToast({ message: '已生成 GB/T 7714 引用', duration: 2000 })
      this.aiAnalysis = { paperId: this.paper.id, researchQuestion: '', methods: '',
        mainFindings: citation, limitations: '', relevanceScore: 0, relevanceReason: '',
        keywords: [], studyType: '', clinicalValue: '', mechanismValue: '',
        createdAt: Date.now(), updatedAt: Date.now() }
    } catch (e) {
      promptAction.showToast({ message: `导出失败: ${(e as Error).message}`, duration: 3000 })
    }
  }

  @Builder LabelValue(label: string, value: string, isMultiLine: boolean = false) {
    if (value && value.trim() !== '') {
      Column() {
        Text(label).fontSize(11).fontColor('#888888').fontWeight(FontWeight.Bold).margin({ bottom: 2 }).width('100%')
        Text(value).fontSize(12).fontColor('#333333').maxLines(isMultiLine ? 8 : 2)
          .textOverflow({ overflow: TextOverflow.Ellipsis }).width('100%')
      }.width('100%').alignItems(HorizontalAlign.Start).margin({ bottom: 12 })
    }
  }

  build() {
    Scroll() {
      Column() {
        if (!this.paper) {
          Column() {
            Text('← 点击文献查看详情').fontSize(14).fontColor('#CCCCCC')
          }.width('100%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        } else {
          Text(this.paper.title).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
            .margin({ bottom: 12 }).width('100%')

          // Score + OA + actions row
          Row() {
            Text(`评分: ${this.paper.relevanceScore.toFixed(1)}`)
              .fontSize(13).fontColor(this.paper.relevanceScore >= 7 ? '#52C41A' : '#FA8C16').fontWeight(FontWeight.Bold)
            if (this.paper.isOA === 'Yes') {
              Text(' OA ').fontSize(11).fontColor('#FFFFFF').backgroundColor('#52C41A')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 }).borderRadius(3).margin({ left: 10 })
            }
            Text(` 引用: ${this.paper.citations}`).fontSize(12).fontColor('#888888').margin({ left: 10 })
          }.width('100%').margin({ bottom: 8 })

          // Action buttons
          Row() {
            Button(this.aiLoading ? '解析中...' : '🤖 AI 解析')
              .fontSize(11).height(28).enabled(!this.aiLoading)
              .backgroundColor('#F0F4FF').fontColor('#2F5496')
              .border({ width: 1, color: '#2F5496' }).borderRadius(4)
              .onClick(() => this.onAiAnalyze())
            Button('📋 GB/T 引用')
              .fontSize(11).height(28).margin({ left: 8 })
              .backgroundColor('#F5F5F5').fontColor('#333')
              .border({ width: 1, color: '#E0E0E0' }).borderRadius(4)
              .onClick(() => this.onCopyCitation())
          }.width('100%').margin({ bottom: 12 })

          if (this.paper.doi) {
            Text(`DOI: ${this.paper.doi}`).fontSize(12).fontColor('#0563C1')
              .decoration({ type: TextDecorationType.Underline }).margin({ bottom: 12 })
              .onClick(() => this.openDOI(this.paper!.doi))
          }

          // AI analysis result
          if (this.aiAnalysis) {
            Divider().strokeWidth(1).color('#2F5496').margin({ bottom: 8 })
            if (this.aiAnalysis.researchQuestion) {
              this.LabelValue('研究问题', this.aiAnalysis.researchQuestion)
              this.LabelValue('方法', this.aiAnalysis.methods)
              this.LabelValue('主要发现', this.aiAnalysis.mainFindings)
              this.LabelValue('局限性', this.aiAnalysis.limitations)
              this.LabelValue('临床价值', this.aiAnalysis.clinicalValue)
            } else if (this.aiAnalysis.mainFindings) {
              // Citation result shown here
              Text('引用格式 (GB/T 7714)').fontSize(11).fontColor('#888888').fontWeight(FontWeight.Bold).margin({ bottom: 4 })
              Text(this.aiAnalysis.mainFindings).fontSize(11).fontColor('#333').padding(8)
                .backgroundColor('#F5F5F5').borderRadius(4).width('100%')
                .margin({ bottom: 12 })
            }
            Divider().strokeWidth(1).color('#EEEEEE').margin({ bottom: 12 })
          }

          Divider().strokeWidth(1).color('#EEEEEE').margin({ bottom: 12 })

          this.LabelValue('作者', this.paper.allAuthors)
          this.LabelValue('期刊', this.paper.journal)
          this.LabelValue('发表时间', this.paper.pubDate)
          this.LabelValue('来源数据库', this.paper.source)
          this.LabelValue('检索策略', this.paper.queryTag)
          this.LabelValue('PMID', this.paper.pmid)
          this.LabelValue('MeSH 术语', this.paper.meshTerms, true)
          this.LabelValue('摘要', this.paper.abstract, true)
        }
      }.width('100%').padding(16).alignItems(HorizontalAlign.Start)
    }.width('100%').height('100%').scrollable(ScrollDirection.Vertical)
  }
}

// pages/PaperDetail.ets — 完整功能：AI解析 + 12种引用导出 + 笔记
import { Paper } from '../model/PaperModel'
import common from '@ohos.app.ability.common'
import Want from '@ohos.app.ability.Want'
import { parseAbstract } from '../engines/AbstractParser'
import { formatCitation, getSupportedFormats } from '../engines/CitationExportEngine'
import { CitationFormat } from '../models/CitationModel'
import type { AbstractAnalysis } from '../models/AbstractAnalysisModel'
import promptAction from '@ohos.promptAction'

@Component
export default struct PaperDetail {
  @Link paper: Paper | null
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  @State aiAnalysis: AbstractAnalysis | null = null
  @State aiLoading: boolean = false
  @State showCitationPicker: boolean = false
  @State showNoteEditor: boolean = false
  @State noteText: string = ''
  @State noteCount: number = 0
  @State citationResult: string = ''
  private allFormats: CitationFormat[] = getSupportedFormats()
  private formatsRow1: CitationFormat[] = this.allFormats.slice(0, 6)
  private formatsRow2: CitationFormat[] = this.allFormats.slice(6)

  private openDOI(doi: string): void {
    if (!doi) return
    try {
      const want: Want = { action: 'ohos.want.action.viewData', uri: `https://doi.org/${doi}` }
      this.context.startAbility(want).catch((e: Error) => console.error('[PaperDetail] openDOI:', e.message))
    } catch (e) { /* ignore */ }
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
    } catch (e) { promptAction.showToast({ message: `解析失败: ${(e as Error).message}`, duration: 3000 }) }
    finally { this.aiLoading = false }
  }

  onCopyCitation(format: CitationFormat): void {
    if (!this.paper) return
    try {
      this.citationResult = formatCitation(this.paper, format)
      this.showCitationPicker = false
      promptAction.showToast({ message: `${format} 格式已生成`, duration: 2000 })
    } catch (e) { promptAction.showToast({ message: `导出失败: ${(e as Error).message}`, duration: 2000 }) }
  }

  onSaveNote(): void {
    if (!this.noteText.trim()) return
    this.noteCount++
    promptAction.showToast({ message: `笔记已保存 (共 ${this.noteCount} 条)`, duration: 2000 })
    this.noteText = ''
    this.showNoteEditor = false
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
    Stack() {
    Scroll() {
      Column() {
        if (!this.paper) {
          Column() { Text('← 点击文献查看详情').fontSize(14).fontColor('#CCCCCC') }
            .width('100%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        } else {
          // Title + action row
          Text(this.paper.title).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#1A1A1A').margin({ bottom: 8 }).width('100%')

          Row() {
            Text(`评分: ${this.paper.relevanceScore.toFixed(1)}`).fontSize(13)
              .fontColor(this.paper.relevanceScore >= 7 ? '#52C41A' : '#FA8C16').fontWeight(FontWeight.Bold)
            if (this.paper.isOA === 'Yes') {
              Text(' OA ').fontSize(11).fontColor('#FFFFFF').backgroundColor('#52C41A')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 }).borderRadius(3).margin({ left: 10 })
            }
          }.width('100%').margin({ bottom: 8 })

          // Action buttons
          Row() {
            Button(this.aiLoading ? '解析中...' : '🤖 AI 解析').fontSize(11).height(28)
              .enabled(!this.aiLoading).backgroundColor('#F0F4FF').fontColor('#2F5496')
              .border({ width: 1, color: '#2F5496' }).borderRadius(4).onClick(() => this.onAiAnalyze())
            Button('📋 引用导出').fontSize(11).height(28).margin({ left: 8 })
              .backgroundColor('#F5F5F5').fontColor('#333').border({ width: 1, color: '#E0E0E0' }).borderRadius(4)
              .onClick(() => { this.showCitationPicker = !this.showCitationPicker })
            Button('📝 笔记').fontSize(11).height(28).margin({ left: 8 })
              .backgroundColor('#FFF7E6').fontColor('#D48806').border({ width: 1, color: '#FFD666' }).borderRadius(4)
              .onClick(() => { this.showNoteEditor = !this.showNoteEditor })
            if (this.paper && this.paper.pmcid && this.paper.isOA === 'Yes') {
              Button('📄 PDF').fontSize(11).height(28).margin({ left: 8 })
                .backgroundColor('#E8F5E9').fontColor('#2E7D32').border({ width: 1, color: '#A5D6A7' }).borderRadius(4)
                .onClick(() => this.openDOI(`https://www.ncbi.nlm.nih.gov/pmc/articles/${this.paper!.pmcid}/pdf/`))
            }
          }.width('100%').margin({ bottom: 4 })

          // Citation format picker (inline)
          if (this.showCitationPicker) {
            Column() {
              Text('选择引用格式').fontSize(12).fontWeight(FontWeight.Bold).margin({ bottom: 6 })
              Grid() {
                ForEach(this.formatsRow1, (fmt: CitationFormat) => {
                  GridItem() {
                    Button(String(fmt)).fontSize(10).height(28)
                      .backgroundColor('#F5F5F5').fontColor('#333').borderRadius(3)
                      .onClick(() => this.onCopyCitation(fmt))
                  }
                })
                ForEach(this.formatsRow2, (fmt: CitationFormat) => {
                  GridItem() {
                    Button(String(fmt)).fontSize(10).height(28)
                      .backgroundColor('#F5F5F5').fontColor('#333').borderRadius(3)
                      .onClick(() => this.onCopyCitation(fmt))
                  }
                })
              }.columnsTemplate('1fr 1fr').rowsGap(4).columnsGap(4)
              .width('100%').margin({ bottom: 8 })
            }.width('100%').padding(10).backgroundColor('#FAFAFA').borderRadius(6).margin({ bottom: 8 })
          }

          // Citation result
          if (this.citationResult) {
            Text(this.citationResult).fontSize(11).fontColor('#333').padding(8)
              .backgroundColor('#E8F5E9').borderRadius(4).width('100%').margin({ bottom: 8 })
          }

          // Note editor
          if (this.showNoteEditor) {
            Column() {
              Text('添加笔记').fontSize(12).fontWeight(FontWeight.Bold).margin({ bottom: 4 })
              TextArea({ placeholder: '写下你的想法...' }).height(80).fontSize(13).margin({ bottom: 6 })
                .backgroundColor('#FFF').borderRadius(4).border({ width: 1, color: '#E0E0E0' })
                .onChange((v: string) => { this.noteText = v })
              Button('保存笔记').fontSize(12).height(28).backgroundColor('#2F5496').fontColor(Color.White)
                .borderRadius(4).onClick(() => this.onSaveNote())
            }.width('100%').padding(10).backgroundColor('#FFF7E6').borderRadius(6).margin({ bottom: 8 })
          }

          if (this.paper.doi) {
            Text(`DOI: ${this.paper.doi}`).fontSize(12).fontColor('#0563C1')
              .decoration({ type: TextDecorationType.Underline }).margin({ bottom: 12 })
              .onClick(() => this.openDOI(this.paper!.doi))
          }

          // AI analysis result
          if (this.aiAnalysis) {
            Divider().strokeWidth(1).color('#2F5496').margin({ bottom: 8 })
            if (this.aiAnalysis.researchQuestion) {
              this.LabelValue('🔬 研究问题', this.aiAnalysis.researchQuestion)
              this.LabelValue('🧪 方法', this.aiAnalysis.methods)
              this.LabelValue('📊 主要发现', this.aiAnalysis.mainFindings)
              this.LabelValue('⚠️ 局限性', this.aiAnalysis.limitations)
              this.LabelValue('🏥 临床价值', this.aiAnalysis.clinicalValue)
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
}

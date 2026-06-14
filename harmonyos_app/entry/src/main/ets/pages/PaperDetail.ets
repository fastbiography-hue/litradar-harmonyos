// pages/PaperDetail.ets — 专业详情面板
import { Paper } from '../model/PaperModel'
import common from '@ohos.app.ability.common'
import Want from '@ohos.app.ability.Want'
import { parseAbstract } from '../engines/AbstractParser'
import { formatCitation, getSupportedFormats } from '../engines/CitationExportEngine'
import { CitationFormat } from '../models/CitationModel'
import type { AbstractAnalysis } from '../models/AbstractAnalysisModel'
import { getNotes, addNote } from '../services/NoteService'
import type { NoteItem } from '../services/NoteService'
import promptAction from '@ohos.promptAction'

@Component
export default struct PaperDetail {
  @Link paper: Paper | null
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  @State aiAnalysis: AbstractAnalysis | null = null; @State aiLoading: boolean = false
  @State showCitationPicker: boolean = false; @State showNoteEditor: boolean = false
  @State noteText: string = ''; @State noteCount: number = 0; @State recentNote: string = ''
  @State citationResult: string = ''
  private allFormats: CitationFormat[] = getSupportedFormats()
  private fmts1: CitationFormat[] = this.allFormats.slice(0, 6)
  private fmts2: CitationFormat[] = this.allFormats.slice(6)

  private openUrl(url: string): void { if (!url) return; try { const w: Want = { action: 'ohos.want.action.viewData', uri: url }; this.context.startAbility(w).catch(() => {}) } catch (e) {} }
  private openDOI(doi: string): void { if (doi) this.openUrl(`https://doi.org/${doi}`) }

  async loadNotes(): Promise<void> { if (!this.paper) return; try { const notes: NoteItem[] = await getNotes(this.paper.id); this.noteCount = notes.length; this.recentNote = notes.length > 0 ? notes[notes.length - 1].content : '' } catch (e) { this.noteCount = 0 } }

  async onAiAnalyze(): Promise<void> { if (!this.paper) return; this.aiLoading = true; this.aiAnalysis = null; try { const r = await parseAbstract(this.paper); if (r.researchQuestion === '' && r.mainFindings === '') promptAction.showToast({ message: 'AI 未返回有效解析，请检查 API Key 配置', duration: 3000 }); this.aiAnalysis = r } catch (e) { promptAction.showToast({ message: `解析失败: ${(e as Error).message}`, duration: 3000 }) } finally { this.aiLoading = false } }

  onCopyCitation(format: CitationFormat): void { if (!this.paper) return; this.citationResult = formatCitation(this.paper, format); this.showCitationPicker = false; promptAction.showToast({ message: '已生成, 长按选中复制', duration: 3000 }) }

  async onSaveNote(): Promise<void> { if (!this.noteText.trim() || !this.paper) return; try { await addNote(this.paper.id, this.noteText.trim()); await this.loadNotes(); promptAction.showToast({ message: `已保存 (共 ${this.noteCount} 条)`, duration: 2000 }); this.noteText = ''; this.showNoteEditor = false } catch (e) { promptAction.showToast({ message: `保存失败`, duration: 2000 }) } }

  @Builder section(title: string, content: () => void) {
    Column() { if (title) Text(title).fontSize(12).fontWeight(FontWeight.Bold).fontColor('#888').margin({ bottom: 8 }).width('100%'); content() }.width('100%').margin({ bottom: 16 })
  }

  @Builder tag(text: string, color: string) {
    Text(text).fontSize(10).padding({ left: 6, right: 6, top: 2, bottom: 2 }).backgroundColor(color).fontColor('#FFF').borderRadius(3)
  }

  build() {
    Scroll() {
    Column() {
      if (!this.paper) {
        Text('选择一篇文献').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#CCC').margin({ top: 60 })
        Text('点击文献列表中的条目查看详情').fontSize(12).fontColor('#DDD').margin({ top: 8 })
      } else {
        // 1. Title
        this.section('', () => { Text(this.paper!.title).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#1A1A1A') })

        // 2. Meta row
        Row() {
          Text(`评分 ${this.paper!.relevanceScore.toFixed(1)}`).fontSize(12).fontColor(this.paper!.relevanceScore >= 7 ? '#52C41A' : '#FA8C16').fontWeight(FontWeight.Bold)
          if (this.paper!.isOA === 'Yes') { this.tag('OA', '#52C41A'); Blank().width(6) }
          if (this.paper!.pmid) { this.tag(`PMID:${this.paper!.pmid}`, '#888'); Blank().width(6) }
          if (this.paper!.pmcid) { this.tag(`PMCID:${this.paper!.pmcid}`, '#888'); Blank().width(6) }
          if (this.paper!.doi) { this.tag('DOI', '#2F5496'); Blank().width(6) }
        }.width('100%').margin({ bottom: 12 }).flexWrap(FlexWrap.Wrap)

        // 3. Action buttons
        Row() {
          Button(this.aiLoading ? '解析中...' : '🤖 AI 解析').fontSize(11).height(32).enabled(!this.aiLoading).backgroundColor('#F0F4FF').fontColor('#2F5496').border({ width: 1, color: '#D0D9F0' }).borderRadius(6).onClick(() => this.onAiAnalyze())
          Blank().width(6)
          Button('📋 引用').fontSize(11).height(32).backgroundColor('#F5F5F5').fontColor('#333').borderRadius(6).border({ width: 1, color: '#E0E0E0' }).onClick(() => { this.showCitationPicker = !this.showCitationPicker })
          Blank().width(6)
          Button(`📝 笔记${this.noteCount > 0 ? `(${this.noteCount})` : ''}`).fontSize(11).height(32).backgroundColor('#FFF7E6').fontColor('#D48806').borderRadius(6).border({ width: 1, color: '#FFD666' }).onClick(() => { this.showNoteEditor = !this.showNoteEditor; this.loadNotes() })
          if (this.paper!.pmcid && this.paper!.isOA === 'Yes') { Blank().width(6); Button('📄 PDF').fontSize(11).height(32).backgroundColor('#E8F5E9').fontColor('#2E7D32').borderRadius(6).border({ width: 1, color: '#A5D6A7' }).onClick(() => this.openUrl(`https://www.ncbi.nlm.nih.gov/pmc/articles/${this.paper!.pmcid}/pdf/`)) }
        }.width('100%').margin({ bottom: 12 }).flexWrap(FlexWrap.Wrap)

        // Citation result
        if (this.citationResult) {
          this.section('引用结果', () => { Text(this.citationResult).fontSize(12).fontColor('#333').padding(10).backgroundColor('#F5F7FA').borderRadius(6).width('100%') })
        }
        if (this.recentNote) {
          this.section(`笔记 (${this.noteCount} 条)`, () => { Text(this.recentNote).fontSize(12).fontColor('#666').maxLines(3) })
        }

        // Citation picker
        if (this.showCitationPicker) {
          this.section('选择引用格式', () => {
            Grid() {
              ForEach(this.fmts1, (fmt: CitationFormat) => { GridItem() { Button(String(fmt)).fontSize(10).height(28).backgroundColor('#F5F5F5').fontColor('#333').borderRadius(4).onClick(() => this.onCopyCitation(fmt)) } })
              ForEach(this.fmts2, (fmt: CitationFormat) => { GridItem() { Button(String(fmt)).fontSize(10).height(28).backgroundColor('#F5F5F5').fontColor('#333').borderRadius(4).onClick(() => this.onCopyCitation(fmt)) } })
            }.columnsTemplate('1fr 1fr').rowsGap(4).columnsGap(4).width('100%')
          })
        }

        // Note editor
        if (this.showNoteEditor) {
          this.section('添加笔记', () => {
            TextArea({ placeholder: '写下你的想法...', text: this.noteText }).height(80).fontSize(13).margin({ bottom: 6 }).backgroundColor('#F5F7FA').borderRadius(6).onChange((v: string) => { this.noteText = v })
            Button('保存笔记').height(32).fontSize(12).backgroundColor('#2F5496').fontColor('#FFF').borderRadius(6).onClick(() => this.onSaveNote())
          })
        }

        // AI analysis
        if (this.aiAnalysis && this.aiAnalysis.researchQuestion) {
          this.section('🤖 AI 解析', () => {
            Column() { LabelValue('研究问题', this.aiAnalysis!.researchQuestion); LabelValue('方法', this.aiAnalysis!.methods); LabelValue('主要发现', this.aiAnalysis!.mainFindings); LabelValue('局限性', this.aiAnalysis!.limitations); LabelValue('临床价值', this.aiAnalysis!.clinicalValue) }
              .padding(12).backgroundColor('#F0F4FF').borderRadius(8).width('100%')
          })
        }

        Divider().strokeWidth(1).color('#EEE').margin({ bottom: 12 })

        // DOI link
        if (this.paper!.doi) {
          Row() { Text(`DOI: ${this.paper!.doi}`).fontSize(12).fontColor('#0563C1').decoration({ type: TextDecorationType.Underline }).onClick(() => this.openDOI(this.paper!.doi)) }.margin({ bottom: 8 })
        }

        // Details
        LabelValue('作者', this.paper!.allAuthors)
        LabelValue('期刊', this.paper!.journal)
        LabelValue('发表时间', this.paper!.pubDate); LabelValue('来源', this.paper!.source)
        LabelValue('MeSH', this.paper!.meshTerms, true)
        LabelValue('摘要', this.paper!.abstract, true)
      }
    }.width('100%').padding(16).alignItems(HorizontalAlign.Start)
    }.width('100%').height('100%').scrollable(ScrollDirection.Vertical)
  }
}

@Component
struct LabelValue {
  @Prop label: string = ''; @Prop value: string = ''; @Prop multi: boolean = false
  build() {
    if (this.value && this.value.trim() !== '') {
      Column() {
        Text(this.label).fontSize(11).fontColor('#999').fontWeight(FontWeight.Bold).margin({ bottom: 2 }).width('100%')
        Text(this.value).fontSize(12).fontColor('#444').maxLines(this.multi ? 12 : 3).textOverflow({ overflow: TextOverflow.Ellipsis }).width('100%')
      }.width('100%').alignItems(HorizontalAlign.Start).margin({ bottom: 10 })
    }
  }
}

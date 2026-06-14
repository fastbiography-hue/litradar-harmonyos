// pages/PaperDetail.ets — 文献详情面板
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
  @State aiAnalysis: AbstractAnalysis | null = null
  @State aiLoading: boolean = false
  @State showCitationPicker: boolean = false
  @State showNoteEditor: boolean = false
  @State noteText: string = ''
  @State noteCount: number = 0
  @State recentNote: string = ''
  @State citationResult: string = ''
  private allFormats: CitationFormat[] = getSupportedFormats()

  private openUrl(url: string): void { if (!url) return; try { const w: Want = { action: 'ohos.want.action.viewData', uri: url }; this.context.startAbility(w).catch(() => {}) } catch (e) {} }
  private openDOI(doi: string): void { if (doi) this.openUrl(`https://doi.org/${doi}`) }

  async loadNotes(): Promise<void> { if (!this.paper) return; try { const notes: NoteItem[] = await getNotes(this.paper.id); this.noteCount = notes.length; this.recentNote = notes.length > 0 ? notes[notes.length - 1].content : '' } catch (e) { this.noteCount = 0 } }

  async onAiAnalyze(): Promise<void> { if (!this.paper) return; this.aiLoading = true; this.aiAnalysis = null; try { const r = await parseAbstract(this.paper); if (r.researchQuestion === '' && r.mainFindings === '') { promptAction.showToast({ message: 'AI 未返回有效解析，请检查 API Key 配置', duration: 3000 }) } this.aiAnalysis = r } catch (e) { promptAction.showToast({ message: `解析失败: ${(e as Error).message}`, duration: 3000 }) } finally { this.aiLoading = false } }

  onCopyCitation(format: CitationFormat): void { if (!this.paper) return; this.citationResult = formatCitation(this.paper, format); this.showCitationPicker = false; promptAction.showToast({ message: '已生成, 长按选中复制', duration: 3000 }) }

  async onSaveNote(): Promise<void> { if (!this.noteText.trim() || !this.paper) return; try { await addNote(this.paper.id, this.noteText.trim()); await this.loadNotes(); promptAction.showToast({ message: `已保存 (共 ${this.noteCount} 条)`, duration: 2000 }); this.noteText = ''; this.showNoteEditor = false } catch (e) { promptAction.showToast({ message: '保存失败', duration: 2000 }) } }

  build() {
    Scroll() {
    Column() {
      if (!this.paper) {
        Text('选择一篇文献').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#CCC').margin({ top: 60 })
        Text('点击文献列表中的条目查看详情').fontSize(12).fontColor('#DDD').margin({ top: 8 })
      } else {
        // Title
        Text(this.paper!.title).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#1A1A1A').margin({ bottom: 12 }).width('100%')

        // Meta row
        Row() {
          Text(`评分 ${this.paper!.relevanceScore.toFixed(1)}`).fontSize(12).fontColor(this.paper!.relevanceScore >= 7 ? '#52C41A' : '#FA8C16').fontWeight(FontWeight.Bold)
          if (this.paper!.isOA === 'Yes') { Text('OA').fontSize(10).fontColor('#FFF').backgroundColor('#52C41A').padding({ left: 4, right: 4, top: 1, bottom: 1 }).borderRadius(3).margin({ left: 8 }) }
          if (this.paper!.pmid) { Text(`PMID:${this.paper!.pmid}`).fontSize(10).fontColor('#FFF').backgroundColor('#888').padding({ left: 4, right: 4, top: 1, bottom: 1 }).borderRadius(3).margin({ left: 6 }) }
        }.width('100%').margin({ bottom: 12 })

        // Action buttons
        Column() {
          Row() {
            Button(this.aiLoading ? '解析中...' : '🤖 AI 解析').fontSize(11).height(32).enabled(!this.aiLoading).backgroundColor('#F0F4FF').fontColor('#2F5496').border({ width: 1, color: '#D0D9F0' }).borderRadius(6).onClick(() => this.onAiAnalyze())
            Button('📋 引用').fontSize(11).height(32).margin({ left: 6 }).backgroundColor('#F5F5F5').fontColor('#333').borderRadius(6).border({ width: 1, color: '#E0E0E0' }).onClick(() => { this.showCitationPicker = !this.showCitationPicker })
            Button(`📝 笔记${this.noteCount > 0 ? '(' + this.noteCount + ')' : ''}`).fontSize(11).height(32).margin({ left: 6 }).backgroundColor('#FFF7E6').fontColor('#D48806').borderRadius(6).border({ width: 1, color: '#FFD666' }).onClick(() => { this.showNoteEditor = !this.showNoteEditor; this.loadNotes() })
            if (this.paper!.pmcid && this.paper!.isOA === 'Yes') { Button('📄 PDF').fontSize(11).height(32).margin({ left: 6 }).backgroundColor('#E8F5E9').fontColor('#2E7D32').borderRadius(6).border({ width: 1, color: '#A5D6A7' }).onClick(() => this.openUrl(`https://www.ncbi.nlm.nih.gov/pmc/articles/${this.paper!.pmcid}/pdf/`)) }
          }.width('100%')
        }.width('100%').margin({ bottom: 12 })

        // Citation result
        if (this.citationResult) {
          Text(this.citationResult).fontSize(12).fontColor('#333').padding(10).backgroundColor('#F5F7FA').borderRadius(6).width('100%').margin({ bottom: 10 })
        }

        // Recent note
        if (this.recentNote) {
          Text(`📝 最近笔记 (共${this.noteCount}条)`).fontSize(11).fontColor('#888').fontWeight(FontWeight.Bold).margin({ bottom: 2 })
          Text(this.recentNote).fontSize(12).fontColor('#666').maxLines(3).margin({ bottom: 10 })
        }

        // Citation picker
        if (this.showCitationPicker) {
          Text('选择引用格式').fontSize(12).fontWeight(FontWeight.Bold).fontColor('#888').margin({ bottom: 6 })
          Row() {
            ForEach(this.allFormats.slice(0, 6), (fmt: CitationFormat) => { Button(String(fmt)).fontSize(10).height(28).layoutWeight(1).margin({ right: 4 }).backgroundColor('#F5F5F5').fontColor('#333').borderRadius(4).onClick(() => this.onCopyCitation(fmt)) })
          }.width('100%').margin({ bottom: 4 })
          Row() {
            ForEach(this.allFormats.slice(6), (fmt: CitationFormat) => { Button(String(fmt)).fontSize(10).height(28).layoutWeight(1).margin({ right: 4 }).backgroundColor('#F5F5F5').fontColor('#333').borderRadius(4).onClick(() => this.onCopyCitation(fmt)) })
          }.width('100%').margin({ bottom: 10 })
        }

        // Note editor
        if (this.showNoteEditor) {
          Text('添加笔记').fontSize(12).fontWeight(FontWeight.Bold).fontColor('#888').margin({ bottom: 6 })
          TextArea({ placeholder: '写下你的想法...', text: this.noteText }).height(80).fontSize(13).margin({ bottom: 6 }).backgroundColor('#F5F7FA').borderRadius(6).onChange((v: string) => { this.noteText = v })
          Button('保存笔记').height(32).fontSize(12).backgroundColor('#2F5496').fontColor('#FFF').borderRadius(6).onClick(() => this.onSaveNote()).margin({ bottom: 10 })
        }

        // AI analysis
        if (this.aiAnalysis && this.aiAnalysis.researchQuestion) {
          Text('🤖 AI 解析').fontSize(12).fontWeight(FontWeight.Bold).fontColor('#2F5496').margin({ bottom: 6 })
          Column() {
            InfoRow('研究问题', this.aiAnalysis!.researchQuestion)
            InfoRow('方法', this.aiAnalysis!.methods)
            InfoRow('主要发现', this.aiAnalysis!.mainFindings)
            InfoRow('局限性', this.aiAnalysis!.limitations)
            InfoRow('临床价值', this.aiAnalysis!.clinicalValue)
          }.padding(12).backgroundColor('#F0F4FF').borderRadius(8).width('100%').margin({ bottom: 10 })
        }

        Divider().strokeWidth(1).color('#EEE').margin({ bottom: 10 })

        if (this.paper!.doi) { Text(`DOI: ${this.paper!.doi}`).fontSize(12).fontColor('#0563C1').decoration({ type: TextDecorationType.Underline }).margin({ bottom: 8 }).onClick(() => this.openDOI(this.paper!.doi)) }

        InfoRow('作者', this.paper!.allAuthors)
        InfoRow('期刊', this.paper!.journal)
        InfoRow('发表时间', this.paper!.pubDate)
        InfoRow('来源', this.paper!.source)
        InfoRow('MeSH', this.paper!.meshTerms)
        InfoRow('摘要', this.paper!.abstract)
      }
    }.width('100%').padding(16).alignItems(HorizontalAlign.Start)
    }.width('100%').height('100%').scrollable(ScrollDirection.Vertical)
  }
}

@Component
struct InfoRow {
  @Prop label: string = ''
  @Prop value: string = ''
  build() {
    if (this.value && this.value.trim() !== '') {
      Column() {
        Text(this.label).fontSize(11).fontColor('#999').fontWeight(FontWeight.Bold).margin({ bottom: 2 }).width('100%')
        Text(this.value).fontSize(12).fontColor('#444').maxLines(this.label === '摘要' ? 12 : 3).textOverflow({ overflow: TextOverflow.Ellipsis }).width('100%')
      }.width('100%').alignItems(HorizontalAlign.Start).margin({ bottom: 10 })
    }
  }
}

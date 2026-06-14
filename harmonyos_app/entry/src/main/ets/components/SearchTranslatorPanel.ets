// components/SearchTranslatorPanel.ets
// M3-T02: AI 检索式翻译面板 — 输入中文，输出结构化检索参数
import { translateSearch } from '../engines/SearchTranslator'
import { SearchTranslationResult } from '../models/SearchTranslationModel'
import promptAction from '@ohos.promptAction'

@Component
export default struct SearchTranslatorPanel {
  @State inputText: string = ''
  @State result: SearchTranslationResult | null = null
  @State isLoading: boolean = false

  async onTranslate(): Promise<void> {
    if (!this.inputText || this.inputText.trim() === '') {
      promptAction.showToast({ message: '请输入中文科研问题', duration: 2000 })
      return
    }
    this.isLoading = true
    try {
      this.result = await translateSearch(this.inputText)
      if (this.result && this.result.warnings.length > 0) {
        promptAction.showToast({ message: this.result.warnings[0], duration: 3000 })
      }
    } catch (e) {
      promptAction.showToast({ message: `翻译失败: ${(e as Error).message}`, duration: 3000 })
    } finally {
      this.isLoading = false
    }
  }

  build() {
    Column() {
      Text('AI 检索式生成')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .padding({ left: 16, top: 12, bottom: 8 })
        .width('100%')

      TextArea({ placeholder: '输入中文科研问题，例如：\n长读长测序 单倍型分型 阿尔茨海默病 APOE风险' })
        .height(80)
        .margin({ left: 16, right: 16, bottom: 8 })
        .onChange((value: string) => { this.inputText = value })

      Button(this.isLoading ? '生成中...' : '生成检索式')
        .enabled(!this.isLoading)
        .backgroundColor('#2F5496')
        .fontColor(Color.White)
        .height(32)
        .margin({ left: 16, right: 16, bottom: 12 })
        .onClick(() => this.onTranslate())

      if (this.result) {
        Scroll() {
          Column() {
            if (this.result.englishKeywords.length > 0) {
              Text('英文关键词: ' + this.result.englishKeywords.join(', '))
                .fontSize(12).padding(4)
            }
            if (this.result.meshTerms.length > 0) {
              Text('MeSH: ' + this.result.meshTerms.join('; '))
                .fontSize(12).padding(4)
            }
            if (this.result.pubmedQuery !== '') {
              Text('PubMed: ' + this.result.pubmedQuery)
                .fontSize(11).padding(4).fontColor('#333')
            }
            if (this.result.europePmcQuery !== '') {
              Text('Europe PMC: ' + this.result.europePmcQuery)
                .fontSize(11).padding(4).fontColor('#333')
            }
            if (this.result.explanation !== '') {
              Text('解释: ' + this.result.explanation)
                .fontSize(11).padding(4).fontColor('#666')
            }
          }
          .width('100%')
          .padding(12)
          .alignItems(HorizontalAlign.Start)
        }
        .height(200)
      }
    }
    .width('100%')
  }
}

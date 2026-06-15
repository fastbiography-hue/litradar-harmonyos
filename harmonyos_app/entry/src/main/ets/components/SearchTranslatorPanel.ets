// components/SearchTranslatorPanel.ets — AI 检索式生成 (左右布局)
import { translateSearch } from '../engines/SearchTranslator'
import { SearchTranslationResult } from '../models/SearchTranslationModel'
import promptAction from '@ohos.promptAction'

@Component
export default struct SearchTranslatorPanel {
  @State input: string = ''
  @State result: SearchTranslationResult | null = null
  @State isLoading: boolean = false

  async onTranslate(): Promise<void> {
    if (!this.input.trim()) { promptAction.showToast({ message: '请输入中文科研问题', duration: 2000 }); return }
    this.isLoading = true
    try {
      this.result = await translateSearch(this.input)
    } catch (e) { promptAction.showToast({ message: `失败: ${(e as Error).message}`, duration: 3000 }) }
    finally { this.isLoading = false }
  }

  build() {
    Column() {
      Row() { Text('AI 检索式生成').fontSize(16).fontWeight(FontWeight.Bold).flexGrow(1) }.width('100%').margin({ bottom: 12 })

      Row() {
        // Left: input
        Column() {
          Text('中文科研问题').fontSize(12).fontColor('#888').margin({ bottom: 6 }).width('100%')
          TextArea({ placeholder: '示例：长读长测序 单倍型分型 阿尔茨海默病 APOE风险', text: this.input })
            .height(120).fontSize(13).margin({ bottom: 8 }).backgroundColor('#F5F7FA').borderRadius(6)
            .onChange((v: string) => { this.input = v })
          Button(this.isLoading ? '生成中...' : '生成检索式').height(36).fontSize(13)
            .enabled(!this.isLoading).backgroundColor('#2F5496').fontColor('#FFF').borderRadius(6).width('100%')
            .onClick(() => this.onTranslate())
        }.width('48%').padding({ right: 8 })

        Divider().vertical(true).strokeWidth(1).color('#E0E0E0').height(280)

        // Right: result
        Column() {
          if (!this.result) {
            Text('生成结果将显示在这里').fontSize(13).fontColor('#CCC').margin({ top: 40 })
          } else if (this.result.warnings.length > 0) {
            Text(this.result.warnings[0]).fontSize(12).fontColor('#FF4D4F').margin({ top: 20 })
          } else {
            Scroll() {
              Column() {
                if (this.result.englishKeywords.length > 0) {
                  Text('英文关键词').fontSize(11).fontColor('#888').fontWeight(FontWeight.Bold).margin({ bottom: 4 })
                  Text(this.result.englishKeywords.join(', ')).fontSize(12).fontColor('#333').margin({ bottom: 10 })
                }
                if (this.result.meshTerms.length > 0) {
                  Text('MeSH Terms').fontSize(11).fontColor('#888').fontWeight(FontWeight.Bold).margin({ bottom: 4 })
                  Text(this.result.meshTerms.join('; ')).fontSize(12).fontColor('#333').margin({ bottom: 10 })
                }
                if (this.result.pubmedQuery) {
                  Text('PubMed').fontSize(11).fontColor('#888').fontWeight(FontWeight.Bold).margin({ bottom: 4 })
                  Text(this.result.pubmedQuery).fontSize(11).fontColor('#333').fontFamily('monospace').padding(8).backgroundColor('#F5F7FA').borderRadius(4).width('100%').margin({ bottom: 10 })
                }
                if (this.result.europePmcQuery) {
                  Text('Europe PMC').fontSize(11).fontColor('#888').fontWeight(FontWeight.Bold).margin({ bottom: 4 })
                  Text(this.result.europePmcQuery).fontSize(11).fontColor('#333').fontFamily('monospace').padding(8).backgroundColor('#F5F7FA').borderRadius(4).width('100%').margin({ bottom: 10 })
                }
                if (this.result.explanation) {
                  Text('解释').fontSize(11).fontColor('#888').fontWeight(FontWeight.Bold).margin({ bottom: 4 })
                  Text(this.result.explanation).fontSize(12).fontColor('#666').margin({ bottom: 10 })
                }

                Divider().strokeWidth(1).color('#EEE').margin({ top: 4, bottom: 8 })
                Button('保存为检索策略').height(32).fontSize(12).backgroundColor('#F5F5F5').fontColor('#AAA').borderRadius(6).width('100%')
                  .enabled(false)
                Text('保存功能下一版支持').fontSize(10).fontColor('#CCC').textAlign(TextAlign.Center).margin({ top: 4 })
              }.width('100%').alignItems(HorizontalAlign.Start)
            }
          }
        }.width('48%').padding({ left: 8 })
      }.width('100%').height(320)
    }.padding(24).width('100%')
  }
}

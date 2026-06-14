// components/mobile/MobilePaperDetail.ets — M4-T05: 手机端文献详情单页
import type { Paper } from '../../model/PaperModel'
import { Colors } from '../../styles/DesignTokens'

@Component
export default struct MobilePaperDetail {
  @Prop paper: Paper | null = null

  build() {
    Scroll() {
      Column() {
        if (!this.paper) {
          Text('← 点击文献查看详情').fontSize(14).fontColor('#CCCCCC').margin({ top: 40 })
        } else {
          Text(this.paper.title).fontSize(16).fontWeight(FontWeight.Bold).margin({ bottom: 12 })
          Text(`${this.paper.firstAuthor} · ${this.paper.journal} · ${this.paper.year}`)
            .fontSize(12).fontColor(Colors.textSecondary).margin({ bottom: 8 })
          if (this.paper.abstract) {
            Text(this.paper.abstract).fontSize(13).fontColor(Colors.textPrimary).maxLines(20)
          }
        }
      }.padding(16).width('100%').alignItems(HorizontalAlign.Start)
    }.width('100%').height('100%')
  }
}

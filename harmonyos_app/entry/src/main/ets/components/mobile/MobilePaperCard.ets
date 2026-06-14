// components/mobile/MobilePaperCard.ets — M4-T05: 手机端文献卡片
import type { Paper } from '../../model/PaperModel'
import { Colors } from '../../styles/DesignTokens'

@Component
export default struct MobilePaperCard {
  @Prop paper: Paper | null = null
  onCardClick: () => void = () => {}

  build() {
    if (!this.paper) {
      Text('')
    } else {
      Column() {
        Text(this.paper.title || '')
          .fontSize(14).fontColor(Colors.textPrimary).maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Row() {
          if (this.paper.relevanceScore >= 7) {
            Text(`${this.paper.relevanceScore.toFixed(1)}`).fontSize(12)
              .fontColor(Colors.success).fontWeight(FontWeight.Bold)
          }
          Text(`${this.paper.firstAuthor} · ${this.paper.journal} · ${this.paper.year}`)
            .fontSize(11).fontColor(Colors.textSecondary).maxLines(1)
            .margin({ left: 8 }).layoutWeight(1)
        }.margin({ top: 4 }).width('100%')
      }
      .padding(12).width('100%')
      .onClick(() => this.onCardClick())
    }
  }
}

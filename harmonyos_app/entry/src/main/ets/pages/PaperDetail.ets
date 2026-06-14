// pages/PaperDetail.ets
import { Paper } from '../model/PaperModel'
import common from '@ohos.app.ability.common'
import Want from '@ohos.app.ability.Want'

@Component
export default struct PaperDetail {
  @Link paper: Paper | null
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  private openDOI(doi: string): void {
    if (!doi) return
    try {
      const want: Want = {
        action: 'ohos.want.action.viewData',
        uri: `https://doi.org/${doi}`
      }
      this.context.startAbility(want).catch((e: Error) => {
        console.error('[PaperDetail] openDOI failed:', e.message)
      })
    } catch (e) {
      console.error('[PaperDetail] openDOI error:', (e as Error).message)
    }
  }

  @Builder
  LabelValue(label: string, value: string, isMultiLine: boolean = false) {
    if (value && value.trim() !== '') {
      Column() {
        Text(label)
          .fontSize(11)
          .fontColor('#888888')
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 2 })
          .width('100%')
        Text(value)
          .fontSize(12)
          .fontColor('#333333')
          .maxLines(isMultiLine ? 8 : 2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 12 })
    }
  }

  build() {
    Scroll() {
      Column() {
        if (!this.paper) {
          Column() {
            Text('← 点击文献查看详情')
              .fontSize(14)
              .fontColor('#CCCCCC')
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        } else {
          Text(this.paper.title)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')
            .margin({ bottom: 12 })
            .width('100%')

          Row() {
            Text(`评分: ${this.paper.relevanceScore.toFixed(1)}`)
              .fontSize(13)
              .fontColor(this.paper.relevanceScore >= 7 ? '#52C41A' : '#FA8C16')
              .fontWeight(FontWeight.Bold)
            if (this.paper.isOA === 'Yes') {
              Text(' OA ')
                .fontSize(11)
                .fontColor('#FFFFFF')
                .backgroundColor('#52C41A')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(3)
                .margin({ left: 10 })
            }
            Text(`  引用: ${this.paper.citations}`)
              .fontSize(12)
              .fontColor('#888888')
              .margin({ left: 10 })
          }
          .width('100%')
          .margin({ bottom: 12 })

          if (this.paper.doi) {
            Text(`DOI: ${this.paper.doi}`)
              .fontSize(12)
              .fontColor('#0563C1')
              .decoration({ type: TextDecorationType.Underline })
              .margin({ bottom: 12 })
              .onClick(() => this.openDOI(this.paper!.doi))
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
      }
      .width('100%')
      .padding(16)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .scrollable(ScrollDirection.Vertical)
  }
}

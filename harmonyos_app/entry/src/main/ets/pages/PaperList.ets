// pages/PaperList.ets — 文献卡片列表
import { Paper } from '../model/PaperModel'

@Component
export default struct PaperList {
  @Link papers: Paper[]
  @Link selectedPaper: Paper | null
  @Link isLoading: boolean

  private scoreColor(score: number): ResourceColor {
    if (score >= 7) return '#52C41A'; if (score >= 5) return '#FA8C16'; return '#AAAAAA'
  }

  build() {
    Column() {
      Row() {
        Text(`文献列表 (${this.papers.length} 篇)`).fontSize(12).fontWeight(FontWeight.Bold).fontColor('#666')
          .padding({ left: 16 })
      }.width('100%').height(34).backgroundColor('#F5F7FA').border({ width: { bottom: 1 }, color: '#E8ECF0' })

      if (this.isLoading) {
        LoadingProgress().width(36).height(36).margin({ top: 60 })
      } else {
        List({ space: 0 }) {
          ForEach(this.papers, (paper: Paper) => {
            ListItem() {
              Row() {
                // Score badge
                Column() {
                  Text(paper.relevanceScore.toFixed(1)).fontSize(16).fontWeight(FontWeight.Bold)
                    .fontColor(this.scoreColor(paper.relevanceScore))
                }.width(44).alignItems(HorizontalAlign.Center)

                // Info
                Column() {
                  Text(paper.title).fontSize(13).fontColor('#1A1A1A').fontWeight(FontWeight.Medium).maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Row() {
                    Text(paper.firstAuthor).fontSize(11).fontColor('#666').maxLines(1)
                    Text(` · ${paper.journal}`).fontSize(11).fontColor('#999').maxLines(1)
                    Text(` · ${paper.year}`).fontSize(11).fontColor('#999')
                  }.margin({ top: 3 }).width('100%')
                  Row() {
                    if (paper.doi) Text(`DOI`).fontSize(9).fontColor('#FFF').backgroundColor('#888').padding({ left: 4, right: 4, top: 1, bottom: 1 }).borderRadius(2)
                    if (paper.pmid) Text(`PMID`).fontSize(9).fontColor('#FFF').backgroundColor('#AAA').padding({ left: 4, right: 4, top: 1, bottom: 1 }).borderRadius(2).margin({ left: 4 })
                  }.margin({ top: 4 })
                }.layoutWeight(1).alignItems(HorizontalAlign.Start).padding({ left: 8, right: 8 })

                // Right badges
                Column() {
                  if (paper.isOA === 'Yes') {
                    Text('OA').fontSize(9).fontColor('#FFF').backgroundColor('#52C41A').padding({ left: 4, right: 4, top: 1, bottom: 1 }).borderRadius(2).margin({ bottom: 4 })
                  }
                  Text(paper.source).fontSize(9).fontColor('#BBB')
                }.width(54).alignItems(HorizontalAlign.Center)
              }
              .width('100%').height(88).padding({ left: 10, right: 10 })
              .backgroundColor(this.selectedPaper?.id === paper.id ? '#EBF0F8' : Color.Transparent)
              .border({ width: { left: 3 }, color: this.selectedPaper?.id === paper.id ? '#2F5496' : Color.Transparent })
              .onClick(() => { this.selectedPaper = paper })
            }
          }, (paper: Paper): string => paper.id)
        }.width('100%').flexGrow(1).divider({ strokeWidth: 1, color: '#F0F2F5' })
      }
    }.width('100%').height('100%')
  }
}

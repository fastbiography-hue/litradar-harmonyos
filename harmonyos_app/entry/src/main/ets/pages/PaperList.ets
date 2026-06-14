// pages/PaperList.ets
import { Paper } from '../model/PaperModel'

@Component
export default struct PaperList {
  @Link papers: Paper[]
  @Link selectedPaper: Paper | null
  @Link isLoading: boolean

  private scoreColor(score: number): ResourceColor {
    if (score >= 7) return '#52C41A'
    if (score >= 5) return '#FA8C16'
    return '#AAAAAA'
  }

  build() {
    Column() {
      Row() {
        Text(`文献列表（${this.papers.length} 篇）`)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .padding({ left: 16 })
      }
      .width('100%')
      .height(36)
      .backgroundColor('#F5F5F5')
      .border({ width: { bottom: 1 }, color: '#E0E0E0' })

      if (this.isLoading) {
        LoadingProgress().width(40).height(40).margin({ top: 60 })
      } else {
        List({ space: 0 }) {
          ForEach(this.papers, (paper: Paper) => {
            ListItem() {
              Row() {
                Column() {
                  Text(paper.relevanceScore.toFixed(1))
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.scoreColor(paper.relevanceScore))
                  Text('score')
                    .fontSize(9)
                    .fontColor('#AAAAAA')
                }
                .width(48)
                .alignItems(HorizontalAlign.Center)

                Column() {
                  Text(paper.title)
                    .fontSize(13)
                    .fontColor('#1A1A1A')
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .fontWeight(FontWeight.Medium)
                  Text(`${paper.firstAuthor}  ·  ${paper.journal}  ·  ${paper.year}`)
                    .fontSize(11)
                    .fontColor('#888888')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .margin({ top: 4 })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                .padding({ left: 8, right: 8 })

                Column() {
                  if (paper.isOA === 'Yes') {
                    Text('OA')
                      .fontSize(10)
                      .fontColor('#FFFFFF')
                      .backgroundColor('#52C41A')
                      .padding({ left: 5, right: 5, top: 2, bottom: 2 })
                      .borderRadius(3)
                      .margin({ bottom: 4 })
                  }
                  Text(paper.source)
                    .fontSize(10)
                    .fontColor('#AAAAAA')
                }
                .width(60)
                .alignItems(HorizontalAlign.Center)
              }
              .width('100%')
              .height(72)
              .padding({ left: 8, right: 8 })
              .backgroundColor(
                this.selectedPaper?.id === paper.id ? '#E8EEF8' : Color.Transparent
              )
              .onClick(() => {
                this.selectedPaper = paper
              })
            }
          }, (paper: Paper): string => paper.id)
        }
        .width('100%')
        .flexGrow(1)
        .divider({ strokeWidth: 1, color: '#F0F0F0' })
      }
    }
    .width('100%')
    .height('100%')
  }
}

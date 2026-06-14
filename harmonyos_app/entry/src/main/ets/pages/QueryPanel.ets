// pages/QueryPanel.ets
import { QueryConfig } from '../model/PaperModel'

@Component
export default struct QueryPanel {
  @Link queries: QueryConfig[]
  @Link selectedQuery: string
  onQuerySelected: (name: string) => void = () => {}

  build() {
    Column() {
      Text('检索策略')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .padding({ left: 16, top: 12, bottom: 8 })
        .width('100%')

      Row() {
        Text('全部文献')
          .fontSize(13)
          .fontColor(this.selectedQuery === '' ? '#2F5496' : '#333333')
      }
      .width('100%')
      .padding({ left: 20, top: 8, bottom: 8 })
      .backgroundColor(this.selectedQuery === '' ? '#E8EEF8' : Color.Transparent)
      .onClick(() => this.onQuerySelected(''))

      ForEach(this.queries, (q: QueryConfig) => {
        Row() {
          Column() {
            Text(q.name)
              .fontSize(13)
              .fontColor(this.selectedQuery === q.name ? '#2F5496' : '#333333')
              .fontWeight(this.selectedQuery === q.name ? FontWeight.Bold : FontWeight.Normal)
            Text(q.query)
              .fontSize(11)
              .fontColor('#888888')
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: 20, right: 12, top: 8, bottom: 8 })
        .backgroundColor(this.selectedQuery === q.name ? '#E8EEF8' : Color.Transparent)
        .onClick(() => this.onQuerySelected(q.name))
      }, (q: QueryConfig): string => q.name)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAFAFA')
    .border({ width: { right: 1 }, color: '#E0E0E0' })
  }
}

// pages/QueryPanel.ets — 可编辑检索策略面板
import { QueryConfig } from '../model/PaperModel'
import promptAction from '@ohos.promptAction'

@Component
export default struct QueryPanel {
  @Link queries: QueryConfig[]
  @Link selectedQuery: string
  onQuerySelected: (name: string) => void = () => {}
  onDeleteQuery: (name: string) => void = () => {}
  onAddQuery: () => void = () => {}
  onEditQuery: (name: string) => void = () => {}
  @State newName: string = ''
  @State newQuery: string = ''
  @State showAddForm: boolean = false

  onAdd(): void {
    if (!this.newName.trim() || !this.newQuery.trim()) {
      promptAction.showToast({ message: '名称和检索式不能为空', duration: 2000 })
      return
    }
    this.queries = this.queries.concat([{ name: this.newName.trim(), query: this.newQuery.trim() }])
    this.newName = ''; this.newQuery = ''; this.showAddForm = false
    promptAction.showToast({ message: '策略已添加', duration: 2000 })
    this.onAddQuery()
  }

  build() {
    Column() {
      Text('检索策略').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#333')
        .padding({ left: 16, top: 12, bottom: 8 }).width('100%')

      Row() {
        Text('全部文献').fontSize(13)
          .fontColor(this.selectedQuery === '' ? '#2F5496' : '#333')
      }
      .width('100%').padding({ left: 20, top: 8, bottom: 8 })
      .backgroundColor(this.selectedQuery === '' ? '#E8EEF8' : Color.Transparent)
      .onClick(() => this.onQuerySelected(''))

      ForEach(this.queries, (q: QueryConfig) => {
        Row() {
          Column() {
            Text(q.name).fontSize(13)
              .fontColor(this.selectedQuery === q.name ? '#2F5496' : '#333')
              .fontWeight(this.selectedQuery === q.name ? FontWeight.Bold : FontWeight.Normal)
            Text(q.query).fontSize(11).fontColor('#888').maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis }).margin({ top: 2 })
          }.alignItems(HorizontalAlign.Start).layoutWeight(1)

          Button('✎').fontSize(11).height(22).width(22).margin({ left: 4 })
            .backgroundColor(Color.Transparent).fontColor('#2F5496')
            .onClick(() => this.onEditQuery(q.name))
          Button('✕').fontSize(11).height(22).width(22).margin({ left: 2 })
            .backgroundColor(Color.Transparent).fontColor('#CCCCCC')
            .onClick(() => {
              this.queries = this.queries.filter((x: QueryConfig) => x.name !== q.name)
              this.onDeleteQuery(q.name)
            })
        }
        .width('100%').padding({ left: 20, right: 8, top: 8, bottom: 8 })
        .backgroundColor(this.selectedQuery === q.name ? '#E8EEF8' : Color.Transparent)
        .onClick(() => this.onQuerySelected(q.name))
      }, (q: QueryConfig): string => q.name)

      // Add new strategy form
      if (this.showAddForm) {
        Column() {
          TextInput({ placeholder: '策略名称', text: this.newName })
            .height(28).fontSize(12).margin({ bottom: 4 })
            .backgroundColor('#FFF').borderRadius(4)
            .onChange((v: string) => { this.newName = v })
          TextInput({ placeholder: 'PubMed 检索式', text: this.newQuery })
            .height(28).fontSize(12).margin({ bottom: 4 })
            .backgroundColor('#FFF').borderRadius(4)
            .onChange((v: string) => { this.newQuery = v })
          Row() {
            Button('取消').fontSize(11).height(24)
              .backgroundColor('#F5F5F5').fontColor('#666').borderRadius(4)
              .onClick(() => { this.showAddForm = false })
            Button('保存').fontSize(11).height(24).margin({ left: 4 })
              .backgroundColor('#2F5496').fontColor(Color.White).borderRadius(4)
              .onClick(() => this.onAdd())
          }.width('100%')
        }.width('100%').padding({ left: 20, right: 12, top: 8, bottom: 8 })
      }

      Button('+ 新建策略').fontSize(12).height(28).margin({ left: 16, top: 6, bottom: 12 })
        .backgroundColor(Color.Transparent).fontColor('#2F5496')
        .onClick(() => { this.showAddForm = !this.showAddForm })
    }
    .width('100%').height('100%').backgroundColor('#FAFAFA')
    .border({ width: { right: 1 }, color: '#E0E0E0' })
  }
}

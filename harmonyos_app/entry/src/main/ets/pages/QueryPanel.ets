// pages/QueryPanel.ets — 专业导航侧栏
import { QueryConfig } from '../model/PaperModel'
import promptAction from '@ohos.promptAction'

@Component
export default struct QueryPanel {
  @Link queries: QueryConfig[]
  @Link selectedQuery: string
  onQuerySelected: (name: string) => void = () => {}
  onDeleteQuery: (name: string) => void = () => {}
  onSaveQuery: (name: string, pubmed: string, epmc: string, keywords: string, enabled: boolean) => void = () => {}
  @State showEditor: boolean = false
  @State editTitle: string = '新建检索策略'
  @State editName: string = ''; @State editPubmed: string = ''; @State editEpmc: string = ''
  @State editKeywords: string = ''; @State editEnabled: boolean = true

  onEdit(name: string): void {
    const q = this.queries.find((x: QueryConfig) => x.name === name)
    this.editTitle = '编辑检索策略'; this.editName = q ? q.name : name
    this.editPubmed = q ? q.query : ''; this.editEpmc = q ? q.query : ''
    this.editKeywords = ''; this.editEnabled = true; this.showEditor = true
  }

  onNew(): void {
    this.editTitle = '新建检索策略'; this.editName = ''; this.editPubmed = ''
    this.editEpmc = ''; this.editKeywords = ''; this.editEnabled = true; this.showEditor = true
  }

  build() {
    Column() {
      // Section header
      Row() {
        Text('检索策略').fontSize(13).fontWeight(FontWeight.Bold).fontColor('#666')
          .padding({ left: 20, top: 16, bottom: 8 })
        Blank()
        Button('＋').fontSize(16).height(28).width(28).margin({ right: 12, top: 14 })
          .backgroundColor(Color.Transparent).fontColor('#2F5496')
          .onClick(() => this.onNew())
      }.width('100%')

      // All papers
      Row() {
        Text('全部文献').fontSize(13)
          .fontColor(this.selectedQuery === '' ? '#2F5496' : '#444')
          .fontWeight(this.selectedQuery === '' ? FontWeight.Medium : FontWeight.Normal)
      }
      .width('100%').padding({ left: 20, top: 10, bottom: 10 })
      .backgroundColor(this.selectedQuery === '' ? '#EBF0F8' : Color.Transparent)
      .border({ width: { left: 3 }, color: this.selectedQuery === '' ? '#2F5496' : Color.Transparent })
      .onClick(() => this.onQuerySelected(''))

      Divider().strokeWidth(1).color('#EEE').width('100%')

      // Query items
      ForEach(this.queries, (q: QueryConfig) => {
        Column() {
          Row() {
            Column() {
              Text(q.name).fontSize(13)
                .fontColor(this.selectedQuery === q.name ? '#2F5496' : '#444')
                .fontWeight(this.selectedQuery === q.name ? FontWeight.Medium : FontWeight.Normal)
              Text(q.query).fontSize(11).fontColor('#AAA').maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis }).margin({ top: 3 })
            }.alignItems(HorizontalAlign.Start).layoutWeight(1)

            Button('✎').fontSize(11).height(24).width(24).margin({ left: 4 })
              .backgroundColor(Color.Transparent).fontColor('#AAA')
              .onClick(() => this.onEdit(q.name))
            Button('✕').fontSize(11).height(24).width(24)
              .backgroundColor(Color.Transparent).fontColor('#DDD')
              .onClick(() => {
                const newQueries = this.queries.filter((x: QueryConfig) => x.name !== q.name)
                this.queries = newQueries
                this.onDeleteQuery(q.name)
              })
          }.width('100%').padding({ left: 20, right: 8, top: 10, bottom: 10 })
        }
        .width('100%')
        .backgroundColor(this.selectedQuery === q.name ? '#EBF0F8' : Color.Transparent)
        .border({ width: { left: 3 }, color: this.selectedQuery === q.name ? '#2F5496' : Color.Transparent })
        .onClick(() => this.onQuerySelected(q.name))
      }, (q: QueryConfig): string => q.name)
    }.width('100%').height('100%')
    .border({ width: { right: 1 }, color: '#E8ECF0' })

    // QueryEditor overlay
    if (this.showEditor) {
      Column() {
        Column() {
          // Inline editor instead of separate dialog
          Row() {
            Text(this.editTitle).fontSize(16).fontWeight(FontWeight.Bold).flexGrow(1)
            Button('✕').fontSize(16).height(28).width(28).backgroundColor(Color.Transparent).fontColor('#999')
              .onClick(() => { this.showEditor = false })
          }.width('100%').margin({ bottom: 12 })

          Text('名称').fontSize(12).fontColor('#888').margin({ bottom: 4 }).width('100%')
          TextInput({ text: this.editName }).height(36).fontSize(13).margin({ bottom: 10 })
            .backgroundColor('#F5F7FA').borderRadius(6)
            .onChange((v: string) => { this.editName = v })

          Text('PubMed 检索式').fontSize(12).fontColor('#888').margin({ bottom: 4 }).width('100%')
          TextArea({ text: this.editPubmed }).height(60).fontSize(13).margin({ bottom: 10 })
            .backgroundColor('#F5F7FA').borderRadius(6)
            .onChange((v: string) => { this.editPubmed = v })

          Text('Europe PMC 检索式 (可选)').fontSize(12).fontColor('#888').margin({ bottom: 4 }).width('100%')
          TextArea({ text: this.editEpmc }).height(60).fontSize(13).margin({ bottom: 10 })
            .backgroundColor('#F5F7FA').borderRadius(6)
            .onChange((v: string) => { this.editEpmc = v })

          Text('关键词').fontSize(12).fontColor('#888').margin({ bottom: 4 }).width('100%')
          TextInput({ text: this.editKeywords }).height(36).fontSize(13).margin({ bottom: 12 })
            .backgroundColor('#F5F7FA').borderRadius(6)
            .onChange((v: string) => { this.editKeywords = v })

          Row() {
            Button('取消').height(36).fontSize(13).layoutWeight(1).margin({ right: 6 })
              .backgroundColor('#F5F5F5').fontColor('#666').borderRadius(6)
              .onClick(() => { this.showEditor = false })
            Button('保存').height(36).fontSize(13).layoutWeight(1).margin({ left: 6 })
              .backgroundColor('#2F5496').fontColor('#FFF').borderRadius(6)
              .onClick(() => {
                if (!this.editName.trim()) { promptAction.showToast({ message: '名称不能为空', duration: 2000 }); return }
                const epmc = this.editEpmc || this.editPubmed
                this.onSaveQuery(this.editName.trim(), this.editPubmed.trim(), epmc.trim(), this.editKeywords.trim(), this.editEnabled)
                this.showEditor = false
              })
          }.width('100%')
        }.width(480).backgroundColor('#FFFFFF').borderRadius(12).padding(24)
      }.width('100%').height('100%').backgroundColor('#00000044')
      .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
      .position({ x: 0, y: 0 })
      .onClick(() => { this.showEditor = false })
    }
  }
}

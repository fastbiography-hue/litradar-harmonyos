// components/CollectionsPanel.ets — 文献分类集合面板
import type { LiteratureCollection } from '../models/CollectionModel'
import promptAction from '@ohos.promptAction'

@Component
export default struct CollectionsPanel {
  @State collections: LiteratureCollection[] = [
    { id: '1', name: '重点关注', parentId: '', description: '', paperIds: [], createdAt: 0, updatedAt: 0 },
    { id: '2', name: '待读文献', parentId: '', description: '', paperIds: [], createdAt: 0, updatedAt: 0 },
    { id: '3', name: '已读文献', parentId: '', description: '', paperIds: [], createdAt: 0, updatedAt: 0 }
  ]
  @State newName: string = ''
  onCollectionSelected: (name: string) => void = () => {}

  onAdd(): void {
    if (!this.newName.trim()) return
    this.collections.push({
      id: String(Date.now()), name: this.newName.trim(), parentId: '',
      description: '', paperIds: [], createdAt: Date.now(), updatedAt: Date.now()
    })
    this.newName = ''
    promptAction.showToast({ message: '分类已创建', duration: 2000 })
  }

  onDelete(id: string): void {
    this.collections = this.collections.filter((c: LiteratureCollection) => c.id !== id)
  }

  build() {
    Column() {
      Text('文献分类').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#333')
        .padding({ left: 16, top: 12, bottom: 4 }).width('100%')

      ForEach(this.collections, (c: LiteratureCollection) => {
        Row() {
          Text(c.name).fontSize(13).fontColor('#333').layoutWeight(1)
          Button('✕').fontSize(10).height(20).width(20)
            .backgroundColor(Color.Transparent).fontColor('#CCC')
            .onClick(() => this.onDelete(c.id))
        }.width('100%').padding({ left: 20, right: 12, top: 6, bottom: 6 })
        .onClick(() => this.onCollectionSelected(c.name))
      }, (c: LiteratureCollection) => c.id)

      Row() {
        TextInput({ placeholder: '新分类名称', text: this.newName })
          .height(28).fontSize(12).layoutWeight(1)
          .backgroundColor('#F5F5F5').borderRadius(4)
          .onChange((v: string) => { this.newName = v })
        Button('+').fontSize(16).height(28).width(28).margin({ left: 4 })
          .backgroundColor('#2F5496').fontColor(Color.White).borderRadius(4)
          .onClick(() => this.onAdd())
      }.width('100%').padding({ left: 20, right: 12, top: 8, bottom: 8 })
    }.width('100%').backgroundColor('#FAFAFA')
    .border({ width: { top: 1 }, color: '#E0E0E0' })
  }
}

// components/common/EmptyState.ets — 空状态组件
@Component
export default struct EmptyState {
  @Prop title: string = '暂无内容'
  @Prop description: string = ''
  @Prop primaryText: string = ''
  @Prop secondaryText: string = ''
  onPrimaryAction: () => void = () => {}
  onSecondaryAction: () => void = () => {}

  build() {
    Column() {
      Text('📭').fontSize(36).margin({ bottom: 12 })
      Text(this.title).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333').margin({ bottom: 4 })
      if (this.description) { Text(this.description).fontSize(13).fontColor('#999').textAlign(TextAlign.Center).maxLines(3).margin({ bottom: 16 }) }
      if (this.primaryText) {
        Button(this.primaryText).height(36).fontSize(13).backgroundColor('#2F5496').fontColor('#FFF').borderRadius(6).padding({ left: 24, right: 24 }).margin({ bottom: this.secondaryText ? 8 : 0 }).onClick(() => this.onPrimaryAction())
      }
      if (this.secondaryText) {
        Button(this.secondaryText).height(36).fontSize(13).backgroundColor('#F0EEFF').fontColor('#722ED1').borderRadius(6).padding({ left: 24, right: 24 }).onClick(() => this.onSecondaryAction())
      }
    }.width('100%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).padding(40)
  }
}

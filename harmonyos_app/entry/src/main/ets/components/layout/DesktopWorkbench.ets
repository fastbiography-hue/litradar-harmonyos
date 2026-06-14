// components/layout/DesktopWorkbench.ets — 桌面三栏工作台壳
@Component
export default struct DesktopWorkbench {
  @BuilderParam sidebar: () => void = this.emptyBuilder
  @BuilderParam mainContent: () => void = this.emptyBuilder
  @BuilderParam detailPanel: () => void = this.emptyBuilder
  @Builder emptyBuilder() {}

  build() {
    Row() {
      Scroll() { Column() { this.sidebar() }.width('100%').alignItems(HorizontalAlign.Start) }
        .width(280).height('100%').backgroundColor('#FAFBFC')
        .border({ width: { right: 1 }, color: '#E8ECF0' }).scrollable(ScrollDirection.Vertical)

      Column() { this.mainContent() }
        .flexGrow(1.2).height('100%').backgroundColor('#FFFFFF')

      Column() { this.detailPanel() }
        .flexGrow(1).height('100%').backgroundColor('#FAFBFC')
        .border({ width: { left: 1 }, color: '#E8ECF0' })
    }.width('100%').flexGrow(1)
  }
}

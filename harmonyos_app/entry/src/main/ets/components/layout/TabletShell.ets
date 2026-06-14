// components/layout/TabletShell.ets — M4-T04: 平板双栏壳
@Component
export default struct TabletShell {
  @BuilderParam sidebar: () => void = this.emptyBuilder
  @BuilderParam mainContent: () => void = this.emptyBuilder

  @Builder emptyBuilder() {}

  build() {
    Row() {
      Column() { this.sidebar() }
        .width(280).height('100%')
        .backgroundColor('#FAFAFA')

      Divider().vertical(true).strokeWidth(1).color('#E0E0E0')

      Column() { this.mainContent() }
        .flexGrow(1).height('100%')
    }
    .width('100%').flexGrow(1)
  }
}

// components/layout/DesktopShell.ets — M4-T02: 电脑端三栏布局壳
import { Layout } from '../../styles/DesignTokens'

@Component
export default struct DesktopShell {
  @BuilderParam sidebar: () => void = this.emptyBuilder
  @BuilderParam mainContent: () => void = this.emptyBuilder
  @BuilderParam detailPanel: () => void = this.emptyBuilder

  @Builder emptyBuilder() {}

  build() {
    Row() {
      Column() { this.sidebar() }
        .width(Layout.desktopSidebarWidth).height('100%')

      Divider().vertical(true).strokeWidth(1).color('#E0E0E0')

      Column() { this.mainContent() }
        .flexGrow(1.2).height('100%')

      Divider().vertical(true).strokeWidth(1).color('#E0E0E0')

      Column() { this.detailPanel() }
        .flexGrow(1).height('100%')
    }
    .width('100%').flexGrow(1)
  }
}

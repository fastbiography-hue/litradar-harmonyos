// components/TopToolbar.ets — M4-T03: 桌面顶部工具栏
import { Colors, Layout } from '../styles/DesignTokens'

@Component
export default struct TopToolbar {
  @Prop statsTotal: number = 0
  @Prop statsOA: number = 0
  @Prop statsHigh: number = 0
  @Prop isLoading: boolean = false
  onRunClick: () => void = () => {}

  build() {
    Row() {
      Text('LitRadar')
        .fontSize(20).fontWeight(FontWeight.Bold).fontColor(Colors.primary)
        .margin({ left: 16 })

      Blank()

      Text(`共 ${this.statsTotal} 篇 | OA: ${this.statsOA} | 高分: ${this.statsHigh}`)
        .fontSize(13).fontColor(Colors.textSecondary).margin({ right: 16 })

      Button(this.isLoading ? '抓取中...' : '立即抓取')
        .enabled(!this.isLoading)
        .backgroundColor(Colors.primary).fontColor(Color.White)
        .height(32).margin({ right: 16 })
        .onClick(() => this.onRunClick())
    }
    .width('100%').height(Layout.toolbarHeight)
    .backgroundColor(Colors.toolbarBg)
    .border({ width: { bottom: 1 }, color: Colors.toolbarBorder })
  }
}

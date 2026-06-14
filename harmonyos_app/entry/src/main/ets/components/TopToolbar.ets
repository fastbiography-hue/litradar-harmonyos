// components/TopToolbar.ets — M4: 搜索 + 抓取工具栏
import { Colors, Layout } from '../styles/DesignTokens'

@Component
export default struct TopToolbar {
  @Prop statsTotal: number = 0
  @Prop statsOA: number = 0
  @Prop statsHigh: number = 0
  @Prop isLoading: boolean = false
  onRunClick: () => void = () => {}
  onSearch: (query: string) => void = () => {}
  onAiSearch: () => void = () => {}
  onSettings: () => void = () => {}
  @State searchText: string = ''

  build() {
    Row() {
      Text('LitRadar')
        .fontSize(20).fontWeight(FontWeight.Bold).fontColor(Colors.primary)
        .margin({ left: 16 })

      TextInput({ placeholder: '输入关键词直接搜索...', text: this.searchText })
        .width(300).height(32).margin({ left: 16 }).fontSize(13)
        .backgroundColor('#FFFFFF')
        .borderRadius(4).border({ width: 1, color: Colors.border })
        .onChange((value: string) => { this.searchText = value })
        .onSubmit(() => { if (this.searchText.trim()) this.onSearch(this.searchText.trim()) })

      Button('搜索')
        .enabled(!this.isLoading && this.searchText.trim() !== '')
        .backgroundColor('#1890FF').fontColor(Color.White)
        .height(32).margin({ left: 8 }).fontSize(12)
        .onClick(() => { if (this.searchText.trim()) this.onSearch(this.searchText.trim()) })

      Button('AI 检索').height(32).margin({ left: 8 }).fontSize(12)
        .backgroundColor('#722ED1').fontColor(Color.White).borderRadius(4)
        .onClick(() => { if (this.onAiSearch) this.onAiSearch() })

      Blank()

      Text(`共 ${this.statsTotal} 篇 | OA: ${this.statsOA} | 高分: ${this.statsHigh}`)
        .fontSize(13).fontColor(Colors.textSecondary).margin({ right: 16 })

      Button(this.isLoading ? '抓取中...' : '更新订阅')
        .enabled(!this.isLoading)
        .backgroundColor(Colors.primary).fontColor(Color.White)
        .height(32).margin({ right: 8 }).fontSize(12)
        .onClick(() => this.onRunClick())

      Button('⚙').height(32).margin({ right: 16 }).fontSize(14)
        .backgroundColor(Color.Transparent).fontColor('#666')
        .onClick(() => { if (this.onSettings) this.onSettings() })
    }
    .width('100%').height(Layout.toolbarHeight)
    .backgroundColor(Colors.toolbarBg)
    .border({ width: { bottom: 1 }, color: Colors.toolbarBorder })
  }
}

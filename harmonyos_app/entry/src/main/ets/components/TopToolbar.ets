// components/TopToolbar.ets — 专业桌面工具栏
@Component
export default struct TopToolbar {
  @Prop statsTotal: number = 0; @Prop statsOA: number = 0; @Prop statsHigh: number = 0
  @Prop isLoading: boolean = false
  onRunClick: () => void = () => {}
  onSearch: (query: string) => void = () => {}
  onAiSearch: () => void = () => {}
  onNotes: () => void = () => {}
  onSettings: () => void = () => {}
  @State searchText: string = ''

  build() {
    Row() {
      Text('LitRadar').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#2F5496').margin({ left: 20 })
      Text('学术文献雷达').fontSize(12).fontColor('#999').margin({ left: 8 })

      TextInput({ placeholder: '搜索 PubMed + Europe PMC...', text: this.searchText })
        .width(440).height(36).margin({ left: 24 }).fontSize(13)
        .backgroundColor('#F5F7FA').borderRadius(18)
        .border({ width: 1, color: '#E0E4E8' })
        .onChange((v: string) => { this.searchText = v })
        .onSubmit(() => { if (this.searchText.trim()) this.onSearch(this.searchText.trim()) })

      Button('搜索').height(36).margin({ left: 8 }).fontSize(12)
        .enabled(!this.isLoading && this.searchText.trim() !== '')
        .backgroundColor('#2F5496').fontColor('#FFF').borderRadius(18).padding({ left: 16, right: 16 })
        .onClick(() => { if (this.searchText.trim()) this.onSearch(this.searchText.trim()) })

      Button('AI 检索').height(36).margin({ left: 6 }).fontSize(12)
        .backgroundColor('#F0EEFF').fontColor('#722ED1').borderRadius(18).padding({ left: 12, right: 12 })
        .onClick(() => this.onAiSearch())

      Blank()

      Row() {
        Chip({ label: '总数', count: this.statsTotal, bgColor: '#F0F4FF' })
        Chip({ label: 'OA', count: this.statsOA, bgColor: '#E8F5E9' })
        Chip({ label: '高分', count: this.statsHigh, bgColor: '#FFF7E6' })
      }

      Button(this.isLoading ? '抓取中...' : '更新订阅').height(36).margin({ left: 12 }).fontSize(12)
        .enabled(!this.isLoading).backgroundColor('#2F5496').fontColor('#FFF').borderRadius(18).padding({ left: 16, right: 16 })
        .onClick(() => this.onRunClick())

      Button('笔记').height(36).margin({ left: 6 }).fontSize(12)
        .backgroundColor('#F5F5F5').fontColor('#666').borderRadius(18).padding({ left: 12, right: 12 })
        .onClick(() => this.onNotes())

      Button('⚙').height(36).margin({ left: 4, right: 20 }).fontSize(16)
        .backgroundColor(Color.Transparent).fontColor('#999')
        .onClick(() => this.onSettings())
    }
    .width('100%').height(64)
    .backgroundColor('#FFFFFF').border({ width: { bottom: 1 }, color: '#E8ECF0' })
  }
}

@Component
struct Chip {
  @Prop label: string = ''; @Prop count: number = 0; @Prop bgColor: string = '#F0F0F0'
  build() {
    Row() {
      Text(`${this.label}: ${this.count}`).fontSize(11).fontColor('#666')
    }
    .padding(4).backgroundColor(this.bgColor).borderRadius(12).margin({ left: 6 })
  }
}

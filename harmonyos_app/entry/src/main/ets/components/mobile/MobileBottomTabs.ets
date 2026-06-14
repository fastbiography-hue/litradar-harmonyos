// components/mobile/MobileBottomTabs.ets — M4-T05: 手机端底部导航
import { Layout } from '../../styles/DesignTokens'

@Component
export default struct MobileBottomTabs {
  @State currentTab: number = 0
  onTabChange: (idx: number) => void = () => {}

  private tabs: string[] = ['雷达', '文献', 'AI', '笔记', '我的']

  build() {
    Row() {
      ForEach(this.tabs, (label: string, idx: number) => {
        Column() {
          Text(label).fontSize(11)
            .fontColor(this.currentTab === idx ? '#2F5496' : '#AAAAAA')
        }
        .layoutWeight(1).alignItems(HorizontalAlign.Center)
        .padding({ top: 8, bottom: 8 })
        .onClick(() => { this.currentTab = idx; this.onTabChange(idx) })
      })
    }
    .width('100%').height(Layout.mobileBottomTabHeight)
    .backgroundColor('#F5F5F5').border({ width: { top: 1 }, color: '#E0E0E0' })
  }
}

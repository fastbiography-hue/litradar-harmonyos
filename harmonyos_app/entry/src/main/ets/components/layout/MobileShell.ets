// components/layout/MobileShell.ets — M4-T02: 手机端底部Tab + 单栏壳
import { Layout } from '../../styles/DesignTokens'

export interface MobileTab {
  label: string; icon: ResourceStr; content: () => void
}

@Component
export default struct MobileShell {
  @State currentTab: number = 0
  @Prop tabs: MobileTab[] = []

  build() {
    Column() {
      Column() {
        if (this.tabs.length > 0 && this.tabs[this.currentTab]) {
          this.tabs[this.currentTab].content()
        }
      }
      .flexGrow(1).width('100%')

      Row() {
        ForEach(this.tabs, (tab: MobileTab, idx: number) => {
          Column() {
            Text(tab.label)
              .fontSize(11)
              .fontColor(this.currentTab === idx ? '#2F5496' : '#AAAAAA')
          }
          .layoutWeight(1).alignItems(HorizontalAlign.Center)
          .padding({ top: 8, bottom: 8 })
          .onClick(() => { this.currentTab = idx })
        })
      }
      .width('100%').height(Layout.mobileBottomTabHeight)
      .backgroundColor('#F5F5F5')
      .border({ width: { top: 1 }, color: '#E0E0E0' })
    }
    .width('100%').height('100%')
  }
}

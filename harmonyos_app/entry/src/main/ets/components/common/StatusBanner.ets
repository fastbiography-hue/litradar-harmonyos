// components/common/StatusBanner.ets — M4-T07: 状态横幅
import { Colors } from '../../styles/DesignTokens'

export enum BannerType { INFO, WARNING, ERROR }

@Component
export default struct StatusBanner {
  @Prop type: BannerType = BannerType.INFO
  @Prop message: string = ''

  build() {
    if (this.message === '') { Text('').height(0) }
    else {
      Row() {
        Text(this.message).fontSize(12)
          .fontColor(this.type === BannerType.ERROR ? '#FFFFFF' : Colors.textPrimary)
      }
      .width('100%').padding(10)
      .backgroundColor(
        this.type === BannerType.ERROR ? Colors.error :
        this.type === BannerType.WARNING ? '#FFF3E0' : '#E3F2FD')
    }
  }
}

// components/common/ErrorState.ets — M4-T07: 错误状态组件
@Component
export default struct ErrorState {
  @Prop message: string = '出错了'
  onRetry?: () => void

  build() {
    Column() {
      Text('⚠️').fontSize(40)
      Text(this.message).fontSize(13).fontColor('#FF4D4F').margin({ top: 8 }).textAlign(TextAlign.Center)
      if (this.onRetry) {
        Button('重试')
          .margin({ top: 12 }).height(32).fontSize(13)
          .onClick(() => { if (this.onRetry) this.onRetry() })
      }
    }
    .width('100%').height('100%')
    .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
  }
}

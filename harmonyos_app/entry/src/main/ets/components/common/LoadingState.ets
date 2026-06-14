// components/common/LoadingState.ets — M4-T07: 加载状态组件
@Component
export default struct LoadingState {
  @Prop message: string = '加载中...'

  build() {
    Column() {
      LoadingProgress().width(40).height(40)
      Text(this.message).fontSize(13).fontColor('#888888').margin({ top: 12 })
    }
    .width('100%').height('100%')
    .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
  }
}

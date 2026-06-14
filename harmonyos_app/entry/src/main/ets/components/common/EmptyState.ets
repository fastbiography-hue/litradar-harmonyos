// components/common/EmptyState.ets — M4-T07: 空状态组件
@Component
export default struct EmptyState {
  @Prop message: string = '暂无数据'

  build() {
    Column() {
      Text('📭').fontSize(40)
      Text(this.message).fontSize(14).fontColor('#CCCCCC').margin({ top: 8 })
    }
    .width('100%').height('100%')
    .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
  }
}

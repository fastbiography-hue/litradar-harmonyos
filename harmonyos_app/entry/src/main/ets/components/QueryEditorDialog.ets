// components/QueryEditorDialog.ets — 检索策略编辑弹窗
import promptAction from '@ohos.promptAction'

export interface QueryEditData {
  name: string; pubmedQuery: string; europePmcQuery: string; keywords: string; enabled: boolean
}

@Component
export default struct QueryEditorDialog {
  @Prop title: string = '新建检索策略'
  @Prop initial: QueryEditData = { name: '', pubmedQuery: '', europePmcQuery: '', keywords: '', enabled: true }
  @State data: QueryEditData = this.initial
  onSave: (data: QueryEditData) => void = () => {}
  onCancel: () => void = () => {}

  aboutToAppear(): void { this.data = this.initial }

  build() {
    Column() {
      Row() {
        Text(this.title).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
        Blank()
        Button('✕').fontSize(16).height(28).width(28).backgroundColor(Color.Transparent).fontColor('#999')
          .onClick(() => this.onCancel())
      }.width('100%').margin({ bottom: 16 })

      Column() {
        Text('策略名称').fontSize(12).fontColor('#888').margin({ bottom: 4 }).width('100%')
        TextInput({ placeholder: '如: AD APOE Research', text: this.data.name })
          .height(36).fontSize(13).margin({ bottom: 12 }).backgroundColor('#F5F7FA').borderRadius(6)
          .onChange((v: string) => { this.data.name = v })
      }

      Column() {
        Text('PubMed 检索式').fontSize(12).fontColor('#888').margin({ bottom: 4 }).width('100%')
        TextArea({ placeholder: '(Alzheimer[Title/Abstract]) AND (APOE[Title/Abstract])', text: this.data.pubmedQuery })
          .height(60).fontSize(13).margin({ bottom: 12 }).backgroundColor('#F5F7FA').borderRadius(6)
          .onChange((v: string) => { this.data.pubmedQuery = v; if (!this.data.europePmcQuery) this.data.europePmcQuery = v })
      }

      Column() {
        Text('Europe PMC 检索式').fontSize(12).fontColor('#888').margin({ bottom: 4 }).width('100%')
        TextArea({ placeholder: '(Alzheimer OR Alzheimer\'s) AND (APOE OR "apolipoprotein E")', text: this.data.europePmcQuery })
          .height(60).fontSize(13).margin({ bottom: 12 }).backgroundColor('#F5F7FA').borderRadius(6)
          .onChange((v: string) => { this.data.europePmcQuery = v })
      }

      Column() {
        Text('关键词（逗号分隔）').fontSize(12).fontColor('#888').margin({ bottom: 4 }).width('100%')
        TextInput({ placeholder: 'Alzheimer, APOE, neurodegeneration', text: this.data.keywords })
          .height(36).fontSize(13).margin({ bottom: 12 }).backgroundColor('#F5F7FA').borderRadius(6)
          .onChange((v: string) => { this.data.keywords = v })
      }

      Row() {
        Text('启用此策略').fontSize(13).layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.data.enabled })
          .onChange((on: boolean) => { this.data.enabled = on })
      }.width('100%').margin({ bottom: 20 })

      Row() {
        Button('取消').height(36).fontSize(13).layoutWeight(1).margin({ right: 8 })
          .backgroundColor('#F5F5F5').fontColor('#666').borderRadius(6)
          .onClick(() => this.onCancel())
        Button('保存').height(36).fontSize(13).layoutWeight(1).margin({ left: 8 })
          .backgroundColor('#2F5496').fontColor('#FFF').borderRadius(6)
          .onClick(() => {
            if (!this.data.name.trim()) { promptAction.showToast({ message: '名称不能为空', duration: 2000 }); return }
            this.onSave(this.data)
          })
      }.width('100%')
    }.padding(24).width('100%')
  }
}

// components/SettingsPanel.ets — M3: AI 配置面板
import { AiProviderConfig, AI_PROVIDERS } from '../models/AiModel'
import { getEnabledProvider, getProviders, saveProvider, updateProvider, disableAllProviders, initAiConfig } from '../services/AiConfigService'
import common from '@ohos.app.ability.common'
import promptAction from '@ohos.promptAction'

@Component
export default struct SettingsPanel {
  @State providers: AiProviderConfig[] = []
  @State selectedProvider: string = 'deepseek'
  @State apiKey: string = ''
  @State model: string = ''
  @State enabled: boolean = false
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  async aboutToAppear(): Promise<void> {
    await initAiConfig(this.context)
    await this.loadProviders()
  }

  async loadProviders(): Promise<void> {
    const all = await getProviders()
    if (all.length === 0) {
      this.providers = []
      return
    }
    this.providers = all
    const ep = await getEnabledProvider()
    if (ep) {
      this.selectedProvider = ep.provider
      this.apiKey = ep.apiKey
      this.model = ep.model
      this.enabled = ep.enabled
    }
  }

  onProviderSelected(provider: string): void {
    this.selectedProvider = provider
    const info = AI_PROVIDERS[provider]
    if (info) this.model = info.defaultModel
    this.loadExistingConfig(provider)
  }

  async loadExistingConfig(provider: string): Promise<void> {
    const all = await getProviders()
    const existing = all.find((p: AiProviderConfig) => p.provider === provider)
    if (existing) {
      this.apiKey = existing.apiKey
      this.model = existing.model
      this.enabled = existing.enabled
    } else {
      this.apiKey = ''
      this.enabled = false
    }
  }

  async onSave(): Promise<void> {
    if (!this.apiKey.trim()) {
      promptAction.showToast({ message: '请输入 API Key', duration: 2000 })
      return
    }
    const info = AI_PROVIDERS[this.selectedProvider]
    if (!info) return
    const config: AiProviderConfig = {
      id: this.selectedProvider,
      provider: this.selectedProvider,
      model: this.model || info.defaultModel,
      apiKey: this.apiKey,
      baseUrl: info.defaultBaseUrl,
      enabled: this.enabled,
      createdAt: 0,
      updatedAt: Date.now()
    }
    const all = await getProviders()
    const exists = all.find((p: AiProviderConfig) => p.provider === this.selectedProvider)
    if (exists) {
      await updateProvider(config)
    } else {
      await saveProvider(config)
    }
    promptAction.showToast({ message: `${info.name} 配置已保存${this.enabled ? '并启用' : ''}`, duration: 2000 })
    await this.loadProviders()
  }

  build() {
    Scroll() {
      Column() {
        Text('AI 服务配置').fontSize(16).fontWeight(FontWeight.Bold).margin({ bottom: 16 })

        Text('选择 Provider').fontSize(12).fontColor('#888').margin({ bottom: 4 })
        Row() {
          ForEach(Object.keys(AI_PROVIDERS), (key: string) => {
            Button(AI_PROVIDERS[key].name)
              .fontSize(11).height(28).margin({ right: 6 })
              .backgroundColor(this.selectedProvider === key ? '#2F5496' : '#F0F0F0')
              .fontColor(this.selectedProvider === key ? '#FFF' : '#333')
              .borderRadius(4)
              .onClick(() => this.onProviderSelected(key))
          })
        }.width('100%').margin({ bottom: 12 })

        Text('API Key').fontSize(12).fontColor('#888').margin({ bottom: 4 })
        TextInput({ placeholder: 'sk-...', text: this.apiKey })
          .width('100%').height(36).fontSize(13).margin({ bottom: 8 })
          .backgroundColor('#F5F5F5').borderRadius(4)
          .type(InputType.Password)
          .onChange((v: string) => { this.apiKey = v })

        Text('Model').fontSize(12).fontColor('#888').margin({ bottom: 4 })
        TextInput({ placeholder: AI_PROVIDERS[this.selectedProvider]?.defaultModel || '', text: this.model })
          .width('100%').height(36).fontSize(13).margin({ bottom: 12 })
          .backgroundColor('#F5F5F5').borderRadius(4)
          .onChange((v: string) => { this.model = v })

        Row() {
          Text('启用此 Provider').fontSize(13).layoutWeight(1)
          Toggle({ type: ToggleType.Switch, isOn: this.enabled })
            .onChange((on: boolean) => { this.enabled = on })
        }.width('100%').margin({ bottom: 16 })

        Button('保存配置')
          .width('100%').height(36).fontSize(14)
          .backgroundColor('#2F5496').fontColor(Color.White).borderRadius(6)
          .onClick(() => this.onSave())
      }.padding(20).width('100%').alignItems(HorizontalAlign.Start)
    }
  }
}

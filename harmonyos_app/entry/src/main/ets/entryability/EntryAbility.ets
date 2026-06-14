// entryability/EntryAbility.ets
import UIAbility from '@ohos.app.ability.UIAbility'
import window from '@ohos.window'

export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code !== 0) {
        console.error('[EntryAbility] loadContent failed:', err.message)
      }
    })
  }
}

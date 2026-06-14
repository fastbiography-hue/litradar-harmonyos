// service/NotifyService.ets
import notificationManager from '@ohos.notificationManager'
import common from '@ohos.app.ability.common'

export async function requestPermission(context: common.UIAbilityContext): Promise<boolean> {
  try {
    // Notification permission is granted by default in HarmonyOS for basic notifications
    return true
  } catch (e) {
    console.error('[NotifyService] requestPermission failed:', (e as Error).message)
    return false
  }
}

export async function notifyNewPapers(newCount: number, highScoreCount: number): Promise<void> {
  try {
    const request: notificationManager.NotificationRequest = {
      id: 1001,
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: `LitRadar · 今日新增 ${newCount} 篇`,
          text: `其中高分文献（≥7分）${highScoreCount} 篇，点击查看`
        }
      },
      slotType: notificationManager.SlotType.SOCIAL_COMMUNICATION
    }
    await notificationManager.publish(request)
  } catch (e) {
    console.error('[NotifyService] notifyNewPapers failed:', (e as Error).message)
  }
}

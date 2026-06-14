// services/NotificationService.ets — M5-T05: 通知服务
import type { LitRadarNotification } from '../models/NotificationModel'
import notify from '../service/NotifyService'

let _notifications: LitRadarNotification[] = []

function uid(): string { return `${Date.now()}_${Math.random().toString(36).slice(2, 8)}` }

export async function createNotification(item: LitRadarNotification): Promise<void> {
  item.id = item.id || uid()
  item.createdAt = Date.now()
  item.read = false
  _notifications.unshift(item)
  // Forward to system notification if available
  try { await notify.notifyNewPapers(1, 0) } catch (e) { /* fallback */ }
}

export async function getNotifications(): Promise<LitRadarNotification[]> {
  return _notifications
}

export async function markAsRead(id: string): Promise<void> {
  const n = _notifications.find((x: LitRadarNotification) => x.id === id)
  if (n) n.read = true
}

export async function notifyHighScorePaper(paperId: string): Promise<void> {
  await createNotification({ id: '', type: 'new_high_score_paper', title: '新高分文献', body: '', paperId, createdAt: 0, read: false })
}

export async function notifyWeeklyDigest(): Promise<void> {
  await createNotification({ id: '', type: 'weekly_digest_ready', title: 'AI 周报已生成', body: '', paperId: '', createdAt: 0, read: false })
}

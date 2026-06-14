// models/NotificationModel.ets — M5-T05: 通知模型
export interface LitRadarNotification {
  id: string
  type: string
  title: string
  body: string
  paperId: string
  createdAt: number
  read: boolean
}

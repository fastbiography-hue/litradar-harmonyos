// models/TransferPayloadModel.ets — M5-T06: 跨设备传输载荷
export interface TransferPayload {
  id: string
  type: string
  title: string
  text: string
  paperId: string
  noteId: string
  createdAt: number
}

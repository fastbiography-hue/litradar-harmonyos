// models/DistributedStateModel.ets — M5-T07: 分布式状态模型
export interface DistributedReadingState {
  paperId: string
  lastPosition: number
  deviceId: string
  timestamp: number
}

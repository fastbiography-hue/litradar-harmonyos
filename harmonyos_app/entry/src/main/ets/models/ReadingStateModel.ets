// models/ReadingStateModel.ets — M5-T02: 接力阅读状态
export interface ReadingState {
  id: string
  paperId: string
  title: string
  currentSection: string
  currentPage: number
  scrollOffset: number
  deviceType: string
  updatedAt: number
}

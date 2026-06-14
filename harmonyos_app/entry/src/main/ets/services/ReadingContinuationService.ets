// services/ReadingContinuationService.ets — M5-T02: 接力阅读服务
import type { ReadingState } from '../models/ReadingStateModel'
let _lastState: ReadingState | undefined = undefined

export async function saveReadingState(state: ReadingState): Promise<void> {
  _lastState = state
  // TODO: persist to Preferences for cross-session continuity
}

export async function getLastReadingState(): Promise<ReadingState | undefined> {
  return _lastState
}

export async function clearReadingState(id: string): Promise<void> {
  if (_lastState && _lastState.id === id) _lastState = undefined
}

export async function prepareContinuationPayload(paperId: string): Promise<ReadingState | undefined> {
  if (_lastState && _lastState.paperId === paperId) return _lastState
  return undefined
}

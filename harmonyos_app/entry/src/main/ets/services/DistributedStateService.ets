// services/DistributedStateService.ets — M5-T07: 分布式阅读状态同步
import type { ReadingState } from '../models/ReadingStateModel'
import type { DistributedReadingState } from '../models/DistributedStateModel'

let _localState: DistributedReadingState | undefined = undefined

export async function pushReadingState(state: ReadingState): Promise<void> {
  _localState = { paperId: state.paperId, lastPosition: state.scrollOffset, deviceId: state.deviceType, timestamp: Date.now() }
}

export async function pullReadingState(): Promise<ReadingState | undefined> {
  return undefined // placeholder: no distributed backend yet
}

export async function isDistributedAvailable(): Promise<boolean> {
  return false // placeholder: HarmonyOS distributed capability not verified
}

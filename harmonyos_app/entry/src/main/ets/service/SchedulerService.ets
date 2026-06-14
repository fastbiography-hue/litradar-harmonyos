// service/SchedulerService.ets
import WorkScheduler from '@ohos.resourceschedule.workScheduler'

export async function registerDailyWork(time: string): Promise<void> {
  try {
    // Cancel existing first
    await cancelDailyWork()

    const parts = time.split(':')
    const hour = parseInt(parts[0])
    const minute = parseInt(parts[1])

    const workInfo: WorkScheduler.WorkInfo = {
      workId: 11001,
      bundleName: 'com.litradar.harmonyos',
      abilityName: 'LitRadarWorker',
      networkType: WorkScheduler.NetworkType.NETWORK_TYPE_ANY,
      isPersisted: true,
      isCharging: false,
      batteryLevel: 0,
      batteryStatus: WorkScheduler.BatteryStatus.BATTERY_STATUS_LOW,
      isDeepIdle: false,
      idleWaitTime: 0,
      repeatCycleTime: 24 * 60 * 60 * 1000,  // daily
      repeatCount: WorkScheduler.MAX_REPEAT_COUNT,
      isRepeat: true,
      parameters: {
        hour: hour,
        minute: minute
      }
    }

    await WorkScheduler.startWork(workInfo)
    console.info(`[SchedulerService] registered daily work at ${time}`)
  } catch (e) {
    console.error('[SchedulerService] registerDailyWork failed:', (e as Error).message)
  }
}

export async function cancelDailyWork(): Promise<void> {
  try {
    await WorkScheduler.stopWork(11001, 'com.litradar.harmonyos')
  } catch (e) {
    // ignore if not registered
  }
}

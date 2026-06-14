// service/ConfigService.ets
// M2-T03: 原生查询配置服务，HarmonyOS Preferences 持久化
import dataPreferences from '@ohos.data.preferences'
import common from '@ohos.app.ability.common'
import { QueryProfile, DEFAULT_PROFILES } from '../models/QueryProfile'

const PREFERENCES_NAME = 'litradar_config'
const KEY_PROFILES = 'query_profiles'
const KEY_INITIALIZED = 'config_initialized'

let _prefs: dataPreferences.Preferences | null = null

async function getPrefs(context: common.Context): Promise<dataPreferences.Preferences> {
  if (_prefs) return _prefs
  _prefs = await dataPreferences.getPreferences(context, PREFERENCES_NAME)
  return _prefs
}

/**
 * 首次启动时写入默认 profiles。幂等，已有数据不覆盖。
 */
export async function initDefaults(context: common.Context): Promise<void> {
  try {
    const prefs = await getPrefs(context)
    const initialized = await prefs.get(KEY_INITIALIZED, false) as boolean
    if (!initialized) {
      const now = new Date().toISOString()
      const defaults: QueryProfile[] = DEFAULT_PROFILES.map((p: QueryProfile): QueryProfile => ({
        ...p,
        createdAt: now,
        updatedAt: now
      }))
      await prefs.put(KEY_PROFILES, JSON.stringify(defaults))
      await prefs.put(KEY_INITIALIZED, true)
      await prefs.flush()
    }
  } catch (e) {
    console.error('[ConfigService] initDefaults failed:', (e as Error).message)
  }
}

/**
 * 读取所有 query profiles
 */
export async function getAllProfiles(context: common.Context): Promise<QueryProfile[]> {
  try {
    const prefs = await getPrefs(context)
    const raw = await prefs.get(KEY_PROFILES, '') as string
    if (raw && raw !== '') {
      return JSON.parse(raw) as QueryProfile[]
    }
  } catch (e) {
    console.error('[ConfigService] getAllProfiles failed:', (e as Error).message)
  }
  return DEFAULT_PROFILES
}

/**
 * 按 id 获取单个 profile
 */
export async function getProfileById(context: common.Context, id: string): Promise<QueryProfile | null> {
  try {
    const profiles = await getAllProfiles(context)
    const found = profiles.find((p: QueryProfile) => p.id === id)
    return found || null
  } catch (e) {
    console.error('[ConfigService] getProfileById failed:', (e as Error).message)
    return null
  }
}

/**
 * 新增或更新 profile。id 已存在则更新，不存在则追加。
 */
export async function upsertProfile(context: common.Context, profile: QueryProfile): Promise<void> {
  try {
    const profiles = await getAllProfiles(context)
    const idx = profiles.findIndex((p: QueryProfile) => p.id === profile.id)
    profile.updatedAt = new Date().toISOString()
    if (idx >= 0) {
      profiles[idx] = profile
    } else {
      profile.createdAt = profile.createdAt || profile.updatedAt
      profiles.push(profile)
    }
    const prefs = await getPrefs(context)
    await prefs.put(KEY_PROFILES, JSON.stringify(profiles))
    await prefs.flush()
  } catch (e) {
    console.error('[ConfigService] upsertProfile failed:', (e as Error).message)
  }
}

/**
 * 删除 profile。id 不存在时 no-op。
 */
export async function deleteProfile(context: common.Context, id: string): Promise<void> {
  try {
    const profiles = await getAllProfiles(context)
    const filtered = profiles.filter((p: QueryProfile) => p.id !== id)
    const prefs = await getPrefs(context)
    await prefs.put(KEY_PROFILES, JSON.stringify(filtered))
    await prefs.flush()
  } catch (e) {
    console.error('[ConfigService] deleteProfile failed:', (e as Error).message)
  }
}

/**
 * 恢复默认 profiles，删除所有自定义
 */
export async function restoreDefaults(context: common.Context): Promise<void> {
  try {
    const now = new Date().toISOString()
    const defaults: QueryProfile[] = DEFAULT_PROFILES.map((p: QueryProfile): QueryProfile => ({
      ...p,
      createdAt: now,
      updatedAt: now
    }))
    const prefs = await getPrefs(context)
    await prefs.put(KEY_PROFILES, JSON.stringify(defaults))
    await prefs.flush()
  } catch (e) {
    console.error('[ConfigService] restoreDefaults failed:', (e as Error).message)
  }
}

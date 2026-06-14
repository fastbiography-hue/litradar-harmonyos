// service/ConfigService.ets
// M2-T03: 原生查询配置服务，HarmonyOS Preferences 持久化
import dataPreferences from '@ohos.data.preferences'
import common from '@ohos.app.ability.common'
import { QueryProfile, DEFAULT_PROFILES } from '../models/QueryProfile'

const PREFERENCES_NAME = 'litradar_config'
const KEY_PROFILES = 'query_profiles'
const KEY_INITIALIZED = 'config_initialized'

let _prefs: dataPreferences.Preferences | null = null
let _context: common.Context | null = null

/**
 * 初始化 ConfigService。必须在 App 启动时调用一次。
 */
export async function init(context: common.Context): Promise<void> {
  _context = context
  _prefs = await dataPreferences.getPreferences(context, PREFERENCES_NAME)
}

function ensureContext(): common.Context {
  if (!_context) {
    throw new Error('ConfigService not initialized. Call init(context) first.')
  }
  return _context
}

async function getPrefs(): Promise<dataPreferences.Preferences> {
  if (_prefs) return _prefs
  const ctx = ensureContext()
  _prefs = await dataPreferences.getPreferences(ctx, PREFERENCES_NAME)
  return _prefs
}

function now(): number {
  return Date.now()
}

/**
 * 首次启动时写入默认 profiles。幂等，已有数据不覆盖。
 */
export async function initDefaultProfiles(): Promise<void> {
  try {
    const prefs = await getPrefs()
    const initialized = await prefs.get(KEY_INITIALIZED, false) as boolean
    if (!initialized) {
      const profiles: QueryProfile[] = DEFAULT_PROFILES.map((p: QueryProfile): QueryProfile => ({
        ...p,
        createdAt: now(),
        updatedAt: now()
      }))
      await prefs.put(KEY_PROFILES, JSON.stringify(profiles))
      await prefs.put(KEY_INITIALIZED, true)
      await prefs.flush()
    }
  } catch (e) {
    console.error('[ConfigService] initDefaultProfiles failed:', (e as Error).message)
  }
}

/**
 * 读取所有 query profiles
 */
export async function getProfiles(): Promise<QueryProfile[]> {
  try {
    const prefs = await getPrefs()
    const raw = await prefs.get(KEY_PROFILES, '') as string
    if (raw && raw !== '') {
      return JSON.parse(raw) as QueryProfile[]
    }
  } catch (e) {
    console.error('[ConfigService] getProfiles failed:', (e as Error).message)
  }
  return DEFAULT_PROFILES
}

/**
 * 读取所有启用的 query profiles
 */
export async function getEnabledProfiles(): Promise<QueryProfile[]> {
  const all = await getProfiles()
  return all.filter((p: QueryProfile) => p.enabled)
}

/**
 * 按 id 获取单个 profile
 */
export async function getProfileById(id: string): Promise<QueryProfile | undefined> {
  try {
    const profiles = await getProfiles()
    return profiles.find((p: QueryProfile) => p.id === id)
  } catch (e) {
    console.error('[ConfigService] getProfileById failed:', (e as Error).message)
    return undefined
  }
}

/**
 * 新增 profile。id 已存在时报错但不崩溃。
 */
export async function addProfile(profile: QueryProfile): Promise<void> {
  try {
    const profiles = await getProfiles()
    const exists = profiles.find((p: QueryProfile) => p.id === profile.id)
    if (exists) {
      console.error('[ConfigService] addProfile: id already exists:', profile.id)
      return
    }
    const ts = now()
    profile.createdAt = ts
    profile.updatedAt = ts
    profiles.push(profile)
    const prefs = await getPrefs()
    await prefs.put(KEY_PROFILES, JSON.stringify(profiles))
    await prefs.flush()
  } catch (e) {
    console.error('[ConfigService] addProfile failed:', (e as Error).message)
  }
}

/**
 * 更新已有 profile。id 不存在时 no-op。
 */
export async function updateProfile(profile: QueryProfile): Promise<void> {
  try {
    const profiles = await getProfiles()
    const idx = profiles.findIndex((p: QueryProfile) => p.id === profile.id)
    if (idx < 0) {
      console.error('[ConfigService] updateProfile: id not found:', profile.id)
      return
    }
    profile.updatedAt = now()
    profiles[idx] = profile
    const prefs = await getPrefs()
    await prefs.put(KEY_PROFILES, JSON.stringify(profiles))
    await prefs.flush()
  } catch (e) {
    console.error('[ConfigService] updateProfile failed:', (e as Error).message)
  }
}

/**
 * 删除 profile。id 不存在时 no-op。
 */
export async function deleteProfile(id: string): Promise<void> {
  try {
    const profiles = await getProfiles()
    const filtered = profiles.filter((p: QueryProfile) => p.id !== id)
    const prefs = await getPrefs()
    await prefs.put(KEY_PROFILES, JSON.stringify(filtered))
    await prefs.flush()
  } catch (e) {
    console.error('[ConfigService] deleteProfile failed:', (e as Error).message)
  }
}

/**
 * 恢复默认 profiles，删除所有自定义。
 */
export async function resetDefaultProfiles(): Promise<void> {
  try {
    const ts = now()
    const defaults: QueryProfile[] = DEFAULT_PROFILES.map((p: QueryProfile): QueryProfile => ({
      ...p,
      createdAt: ts,
      updatedAt: ts
    }))
    const prefs = await getPrefs()
    await prefs.put(KEY_PROFILES, JSON.stringify(defaults))
    await prefs.flush()
  } catch (e) {
    console.error('[ConfigService] resetDefaultProfiles failed:', (e as Error).message)
  }
}

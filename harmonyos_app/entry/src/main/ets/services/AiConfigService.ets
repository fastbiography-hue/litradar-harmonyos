// services/AiConfigService.ets
// M3-T01: AI provider 配置持久化，HarmonyOS Preferences
import dataPreferences from '@ohos.data.preferences'
import common from '@ohos.app.ability.common'
import { AiProviderConfig } from '../models/AiModel'

const PREFERENCES_NAME = 'litradar_ai_config'
const KEY_PROVIDERS = 'ai_providers'

let _prefs: dataPreferences.Preferences | null = null
let _context: common.Context | null = null

export async function initAiConfig(context: common.Context): Promise<void> {
  _context = context
  _prefs = await dataPreferences.getPreferences(context, PREFERENCES_NAME)
}

async function getPrefs(): Promise<dataPreferences.Preferences> {
  if (_prefs) return _prefs
  if (!_context) throw new Error('AiConfigService not initialized. Call initAiConfig(context) first.')
  _prefs = await dataPreferences.getPreferences(_context, PREFERENCES_NAME)
  return _prefs
}

export async function getProviders(): Promise<AiProviderConfig[]> {
  try {
    const prefs = await getPrefs()
    const raw = await prefs.get(KEY_PROVIDERS, '') as string
    if (raw && raw !== '') {
      return JSON.parse(raw) as AiProviderConfig[]
    }
  } catch (e) {
    console.error('[AiConfigService] getProviders failed:', (e as Error).message)
  }
  return []
}

export async function getEnabledProvider(): Promise<AiProviderConfig | undefined> {
  const all = await getProviders()
  return all.find((p: AiProviderConfig) => p.enabled)
}

export async function saveProvider(config: AiProviderConfig): Promise<void> {
  try {
    const profiles = await getProviders()
    if (profiles.find((p: AiProviderConfig) => p.id === config.id)) {
      console.error('[AiConfigService] saveProvider: id already exists:', config.id)
      return
    }
    const ts = Date.now()
    config.createdAt = ts
    config.updatedAt = ts
    profiles.push(config)
    const prefs = await getPrefs()
    await prefs.put(KEY_PROVIDERS, JSON.stringify(profiles))
    await prefs.flush()
  } catch (e) {
    console.error('[AiConfigService] saveProvider failed:', (e as Error).message)
  }
}

export async function updateProvider(config: AiProviderConfig): Promise<void> {
  try {
    const profiles = await getProviders()
    const idx = profiles.findIndex((p: AiProviderConfig) => p.id === config.id)
    if (idx < 0) {
      console.error('[AiConfigService] updateProvider: id not found:', config.id)
      return
    }
    config.updatedAt = Date.now()
    profiles[idx] = config
    const prefs = await getPrefs()
    await prefs.put(KEY_PROVIDERS, JSON.stringify(profiles))
    await prefs.flush()
  } catch (e) {
    console.error('[AiConfigService] updateProvider failed:', (e as Error).message)
  }
}

export async function deleteProvider(id: string): Promise<void> {
  try {
    const profiles = await getProviders()
    const filtered = profiles.filter((p: AiProviderConfig) => p.id !== id)
    const prefs = await getPrefs()
    await prefs.put(KEY_PROVIDERS, JSON.stringify(filtered))
    await prefs.flush()
  } catch (e) {
    console.error('[AiConfigService] deleteProvider failed:', (e as Error).message)
  }
}

export async function disableAllProviders(): Promise<void> {
  try {
    const profiles = await getProviders()
    for (const p of profiles) {
      p.enabled = false
    }
    const prefs = await getPrefs()
    await prefs.put(KEY_PROVIDERS, JSON.stringify(profiles))
    await prefs.flush()
  } catch (e) {
    console.error('[AiConfigService] disableAllProviders failed:', (e as Error).message)
  }
}

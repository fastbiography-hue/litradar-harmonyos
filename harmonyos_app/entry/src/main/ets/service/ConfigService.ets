// service/ConfigService.ets
import dataPreferences from '@ohos.data.preferences'
import common from '@ohos.app.ability.common'

export interface QueryConfig {
  name: string
  query: string
  sources: string[]
  dateFrom: string
  alertOnNew: boolean
}

export interface AppConfig {
  queries: QueryConfig[]
  scoreKeywords: string[]
  maxResultsPerSource: number
  ncbiApiKey: string
  ncbiEmail: string
  schedulerEnabled: boolean
  schedulerTime: string
}

const PREFERENCES_NAME = 'litradar_config'
const KEY_APP_CONFIG = 'app_config'

const DEFAULT_CONFIG: AppConfig = {
  queries: [
    {
      name: 'AD_APOE',
      query: 'APOE AND Alzheimer AND (GWAS OR haplotype OR risk)',
      sources: ['pubmed', 'europe_pmc'],
      dateFrom: '2020-01-01',
      alertOnNew: true
    },
    {
      name: 'longread_variant',
      query: 'long-read sequencing AND (variant calling OR haplotype phasing)',
      sources: ['pubmed', 'europe_pmc'],
      dateFrom: '2020-01-01',
      alertOnNew: true
    },
    {
      name: 'metabolic_genetics',
      query: 'metabolic syndrome AND (GWAS OR polygenic risk score OR WGS)',
      sources: ['pubmed', 'europe_pmc'],
      dateFrom: '2020-01-01',
      alertOnNew: false
    }
  ],
  scoreKeywords: [
    'APOE', 'Alzheimer', 'haplotype', 'long-read', 'PacBio', 'ONT',
    'variant calling', 'polygenic risk', 'GWAS', 'WGS'
  ],
  maxResultsPerSource: 100,
  ncbiApiKey: '',
  ncbiEmail: '',
  schedulerEnabled: false,
  schedulerTime: '08:00'
}

let _prefs: dataPreferences.Preferences | null = null

async function getPrefs(context: common.Context): Promise<dataPreferences.Preferences> {
  if (_prefs) return _prefs
  _prefs = await dataPreferences.getPreferences(context, PREFERENCES_NAME)
  return _prefs
}

/**
 * 读取完整配置。首次启动（Preferences 无数据）时返回 DEFAULT_CONFIG，
 * 不触发自动写入。写入由 saveConfig / upsertQuery / deleteQuery 显式触发。
 */
export async function getConfig(context: common.Context): Promise<AppConfig> {
  try {
    const prefs = await getPrefs(context)
    const raw = await prefs.get(KEY_APP_CONFIG, '') as string
    if (raw && raw !== '') {
      const parsed = JSON.parse(raw) as AppConfig
      return parsed
    }
  } catch (e) {
    console.error('[ConfigService] getConfig failed, using defaults:', (e as Error).message)
  }
  return DEFAULT_CONFIG
}

/**
 * 首次启动时将 DEFAULT_CONFIG 写入 Preferences。
 * 幂等：已有数据时不覆盖。应在 Index.aboutToAppear 中调用一次。
 */
export async function ensureDefaults(context: common.Context): Promise<void> {
  try {
    const prefs = await getPrefs(context)
    const raw = await prefs.get(KEY_APP_CONFIG, '') as string
    if (!raw || raw === '') {
      await prefs.put(KEY_APP_CONFIG, JSON.stringify(DEFAULT_CONFIG))
      await prefs.flush()
    }
  } catch (e) {
    console.error('[ConfigService] ensureDefaults failed:', (e as Error).message)
  }
}

export async function saveConfig(context: common.Context, config: AppConfig): Promise<void> {
  try {
    const prefs = await getPrefs(context)
    await prefs.put(KEY_APP_CONFIG, JSON.stringify(config))
    await prefs.flush()
  } catch (e) {
    console.error('[ConfigService] saveConfig failed:', (e as Error).message)
  }
}

export async function upsertQuery(context: common.Context, q: QueryConfig): Promise<void> {
  try {
    const config = await getConfig(context)
    const idx = config.queries.findIndex((item: QueryConfig) => item.name === q.name)
    if (idx >= 0) {
      config.queries[idx] = q
    } else {
      config.queries.push(q)
    }
    await saveConfig(context, config)
  } catch (e) {
    console.error('[ConfigService] upsertQuery failed:', (e as Error).message)
  }
}

export async function deleteQuery(context: common.Context, name: string): Promise<void> {
  try {
    const config = await getConfig(context)
    config.queries = config.queries.filter((item: QueryConfig) => item.name !== name)
    await saveConfig(context, config)
  } catch (e) {
    console.error('[ConfigService] deleteQuery failed:', (e as Error).message)
  }
}

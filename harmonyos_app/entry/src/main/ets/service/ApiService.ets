// service/ApiService.ets
import http from '@ohos.net.http'
import { Paper, QueryConfig, StatsInfo, RunResult, AppState } from '../model/PaperModel'
import { mapPaperFromApi, mapStatsFromApi } from '../model/PaperModel'

const BASE = AppState.API_BASE

async function httpGet(path: string, timeout: number = 30000): Promise<string> {
  const req = http.createHttp()
  try {
    const res = await req.request(BASE + path, {
      method: http.RequestMethod.GET,
      connectTimeout: timeout,
      readTimeout: timeout,
      header: { 'Content-Type': 'application/json' }
    })
    if (res.responseCode !== 200) {
      throw new Error(`HTTP ${res.responseCode} on ${path}`)
    }
    return res.result as string
  } catch (e) {
    throw new Error((e as Error).message)
  } finally {
    req.destroy()
  }
}

async function httpPost(path: string, bodyStr: string, timeout: number = 120000): Promise<string> {
  const req = http.createHttp()
  try {
    const res = await req.request(BASE + path, {
      method: http.RequestMethod.POST,
      connectTimeout: timeout,
      readTimeout: timeout,
      header: { 'Content-Type': 'application/json' },
      extraData: bodyStr
    })
    if (res.responseCode !== 200) {
      throw new Error(`HTTP ${res.responseCode} on ${path}`)
    }
    return res.result as string
  } catch (e) {
    throw new Error((e as Error).message)
  } finally {
    req.destroy()
  }
}

export async function fetchPapers(queryName: string | null = null, limit: number = 200): Promise<Paper[]> {
  try {
    const qs = queryName ? `?query_name=${encodeURIComponent(queryName)}&limit=${limit}` : `?limit=${limit}`
    const raw = await httpGet('/api/papers' + qs)
    const arr: Array<Record<string, Object>> = JSON.parse(raw) as Array<Record<string, Object>>
    return arr.map((item: Record<string, Object>) => mapPaperFromApi(item))
  } catch (e) {
    console.error('[ApiService] fetchPapers failed:', (e as Error).message)
    return []
  }
}

export async function fetchQueries(): Promise<QueryConfig[]> {
  try {
    const raw = await httpGet('/api/queries')
    return JSON.parse(raw) as QueryConfig[]
  } catch (e) {
    console.error('[ApiService] fetchQueries failed:', (e as Error).message)
    return []
  }
}

export async function fetchStats(): Promise<StatsInfo> {
  try {
    const raw = await httpGet('/api/stats')
    const obj: Record<string, Object> = JSON.parse(raw) as Record<string, Object>
    return mapStatsFromApi(obj)
  } catch (e) {
    console.error('[ApiService] fetchStats failed:', (e as Error).message)
    return { total: 0, oa: 0, downloaded: 0, highRelevance: 0 }
  }
}

export async function checkHealth(): Promise<boolean> {
  try {
    await httpGet('/api/health')
    return true
  } catch (e) {
    return false
  }
}

export async function triggerRun(queryName: string | null = null): Promise<RunResult> {
  try {
    const bodyObj: Record<string, string> = {}
    if (queryName) {
      bodyObj['query_name'] = queryName
    }
    const raw = await httpPost('/api/run', JSON.stringify(bodyObj), 120000)
    return JSON.parse(raw) as RunResult
  } catch (e) {
    console.error('[ApiService] triggerRun failed:', (e as Error).message)
    return { found: 0, saved: 0 }
  }
}

// services/HttpService.ets
// M2-T02: HTTP 请求抽象层，供 FetchEngine 使用
import http from '@ohos.net.http'

export async function httpGetJson(url: string, timeout: number = 60000): Promise<Record<string, Object> | null> {
  const req = http.createHttp()
  try {
    const res = await req.request(url, {
      method: http.RequestMethod.GET,
      connectTimeout: timeout,
      readTimeout: timeout,
      header: { 'Accept': 'application/json' }
    })
    if (res.responseCode !== 200) {
      console.error(`[HttpService] HTTP ${res.responseCode} for ${url.substring(0, 80)}`)
      return null
    }
    const body: string | Object | ArrayBuffer = res.result
    if (typeof body === 'string') {
      return JSON.parse(body) as Record<string, Object>
    }
    if (typeof body === 'object') {
      return body as Record<string, Object>
    }
    return null
  } catch (e) {
    console.error(`[HttpService] GET failed: ${url.substring(0, 80)} — ${(e as Error).message}`)
    return null
  } finally {
    req.destroy()
  }
}

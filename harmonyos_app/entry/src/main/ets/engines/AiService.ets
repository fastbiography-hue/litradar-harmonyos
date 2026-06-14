// engines/AiService.ets
// M3-T01: 可插拔 AI 后端统一接口
import http from '@ohos.net.http'
import { AiProviderConfig, AiResponse, getProviderInfo } from '../models/AiModel'
import { getEnabledProvider } from '../services/AiConfigService'

// ── Provider request builders ────────────────────────

interface MessageItem { role: string; content: string }
interface RequestBody { model: string; max_tokens: number; messages: MessageItem[] }

function buildRequestBody(provider: string, prompt: string, model: string, maxTokens?: number): string {
  const msg: MessageItem = { role: 'user', content: prompt }
  if (provider === 'anthropic') {
    const body: RequestBody = { model: model, max_tokens: maxTokens || 1024, messages: [msg] }
    return JSON.stringify(body)
  }
  const body: RequestBody = { model: model, messages: [msg], max_tokens: maxTokens || 1024 }
  return JSON.stringify(body)
}

function buildHeaders(config: AiProviderConfig): Record<string, string> {
  const headers: Record<string, string> = {
    'Content-Type': 'application/json'
  }
  if (config.provider === 'anthropic') {
    headers['x-api-key'] = config.apiKey
    headers['anthropic-version'] = '2023-06-01'
  } else {
    headers['Authorization'] = `Bearer ${config.apiKey}`
  }
  return headers
}

function parseResponse(provider: string, raw: Record<string, Object>): string {
  try {
    if (provider === 'anthropic') {
      const content = raw['content'] as Record<string, Object>[] | undefined
      if (content && content.length > 0) {
        return (content[0]['text'] ?? '') as string
      }
      return ''
    }
    // OpenAI-compatible format
    const choices = raw['choices'] as Record<string, Object>[] | undefined
    if (choices && choices.length > 0) {
      const message = choices[0]['message'] as Record<string, Object> | undefined
      if (message) {
        return (message['content'] ?? '') as string
      }
    }
    return ''
  } catch (e) {
    console.error('[AiService] parseResponse failed:', (e as Error).message)
    return ''
  }
}

function getEndpoint(config: AiProviderConfig): string {
  if (config.provider === 'anthropic') {
    return `${config.baseUrl}/messages`
  }
  return `${config.baseUrl}/chat/completions`
}

// ── HTTP call ────────────────────────────────────────

async function aiRequest(config: AiProviderConfig, prompt: string, maxTokens?: number): Promise<AiResponse> {
  const model = config.model || getProviderInfo(config.provider)?.defaultModel || ''
  const endpoint = getEndpoint(config)
  const body = buildRequestBody(config.provider, prompt, model, maxTokens)
  const headers = buildHeaders(config)

  const req = http.createHttp()
  try {
    const res = await req.request(endpoint, {
      method: http.RequestMethod.POST,
      header: headers,
      extraData: body,
      connectTimeout: 60000,
      readTimeout: 120000
    })
    if (res.responseCode !== 200) {
      const errText = (res.result as string) || `HTTP ${res.responseCode}`
      return { text: '', provider: config.provider, model: model, error: errText }
    }
    const raw = JSON.parse(res.result as string) as Record<string, Object>
    const text = parseResponse(config.provider, raw)
    return { text: text, provider: config.provider, model: model }
  } catch (e) {
    return { text: '', provider: config.provider, model: model, error: (e as Error).message }
  } finally {
    req.destroy()
  }
}

// ── Public API ───────────────────────────────────────

export async function chat(prompt: string, model?: string): Promise<string> {
  try {
    const config = await getEnabledProvider()
    if (!config) {
      return '[AiService] No AI provider enabled. Configure one in Settings.'
    }
    if (!config.apiKey || config.apiKey === '') {
      return '[AiService] API Key not configured.'
    }
    const resp = await aiRequest(config, prompt, model ? 1024 : undefined)
    if (resp.error) {
      return `[AiService] Error: ${resp.error}`
    }
    return resp.text
  } catch (e) {
    return `[AiService] Unexpected error: ${(e as Error).message}`
  }
}

export async function translate(text: string, targetLang?: string): Promise<string> {
  const lang = targetLang || 'Chinese'
  const prompt = `Translate the following academic text to ${lang}. Output only the translation, no explanation:\n\n${text}`
  return await chat(prompt)
}

export async function summarize(abstractText: string, lang?: string): Promise<string> {
  const language = lang || 'zh'
  const langName = language === 'zh' ? 'Simplified Chinese' : 'English'
  const prompt = `You are an expert researcher in medical genetics. Please provide a structured summary of the following paper abstract in ${langName}, including:
1. Core research question
2. Main methods
3. Key findings
4. Relevance to Alzheimer's disease / neurodegenerative disorders

Abstract: ${abstractText}`
  return await chat(prompt)
}

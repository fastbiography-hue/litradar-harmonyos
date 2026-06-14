// models/AiModel.ets
// M3-T01: AI 服务配置模型

export interface AiProviderConfig {
  id: string; provider: string; model: string; apiKey: string
  baseUrl: string; enabled: boolean; createdAt: number; updatedAt: number
}

export interface AiRequest {
  prompt: string; model?: string; temperature?: number; maxTokens?: number
}

export interface AiResponse {
  text: string; provider: string; model: string; error?: string
}

export interface ProviderInfo {
  name: string; defaultBaseUrl: string; defaultModel: string
}

export function getProviderInfo(provider: string): ProviderInfo | undefined {
  if (provider === 'deepseek')  return { name: 'DeepSeek',  defaultBaseUrl: 'https://api.deepseek.com/v1', defaultModel: 'deepseek-chat' }
  if (provider === 'openai')    return { name: 'OpenAI',    defaultBaseUrl: 'https://api.openai.com/v1', defaultModel: 'gpt-4o-mini' }
  if (provider === 'anthropic') return { name: 'Anthropic', defaultBaseUrl: 'https://api.anthropic.com/v1', defaultModel: 'claude-sonnet-4-6' }
  if (provider === 'doubao')    return { name: '豆包',      defaultBaseUrl: 'https://ark.cn-beijing.volces.com/api/v3', defaultModel: 'ep-2024' }
  if (provider === 'tongyi')    return { name: '通义千问',  defaultBaseUrl: 'https://dashscope.aliyuncs.com/compatible-mode/v1', defaultModel: 'qwen-turbo' }
  return undefined
}

export function getAllProviderKeys(): string[] {
  return ['deepseek', 'openai', 'anthropic', 'doubao', 'tongyi']
}

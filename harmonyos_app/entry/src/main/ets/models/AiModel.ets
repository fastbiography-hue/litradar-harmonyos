// models/AiModel.ets
// M3-T01: AI 服务配置模型

export interface AiProviderConfig {
  id: string
  provider: string
  model: string
  apiKey: string
  baseUrl: string
  enabled: boolean
  createdAt: number
  updatedAt: number
}

export interface AiRequest {
  prompt: string
  model?: string
  temperature?: number
  maxTokens?: number
}

export interface AiResponse {
  text: string
  provider: string
  model: string
  error?: string
}

// Provider metadata (base URLs are defaults, user-overridable)
export const AI_PROVIDERS: Record<string, { name: string; defaultBaseUrl: string; defaultModel: string }> = {
  'deepseek':   { name: 'DeepSeek',   defaultBaseUrl: 'https://api.deepseek.com/v1',           defaultModel: 'deepseek-chat' },
  'openai':     { name: 'OpenAI',     defaultBaseUrl: 'https://api.openai.com/v1',              defaultModel: 'gpt-4o-mini' },
  'anthropic':  { name: 'Anthropic',  defaultBaseUrl: 'https://api.anthropic.com/v1',           defaultModel: 'claude-sonnet-4-6' },
  'doubao':     { name: '豆包',        defaultBaseUrl: 'https://ark.cn-beijing.volces.com/api/v3', defaultModel: 'ep-2024' },
  'tongyi':     { name: '通义千问',    defaultBaseUrl: 'https://dashscope.aliyuncs.com/compatible-mode/v1', defaultModel: 'qwen-turbo' }
}

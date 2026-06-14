// services/LocalAiAdapter.ets — M5-T09: 端侧 AI 适配层（接口预留）
export async function isLocalAiAvailable(): Promise<boolean> { return false }

export async function localSummarize(text: string): Promise<string> {
  return '[LocalAI] Not available. Configure a cloud AI provider in Settings.'
}

export async function localTranslate(text: string, targetLang: string): Promise<string> {
  return `[LocalAI] Not available. Use cloud translate to ${targetLang}.`
}

export async function localExtractKeywords(text: string): Promise<string[]> {
  return []
}

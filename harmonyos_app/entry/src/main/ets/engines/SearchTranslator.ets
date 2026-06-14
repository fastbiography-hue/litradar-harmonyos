// engines/SearchTranslator.ets
// M3-T02: 中文科研问题 → 英文检索式 AI 生成
import { chat } from './AiService'
import { SearchTranslationResult } from '../models/SearchTranslationModel'

function buildPrompt(chineseInput: string): string {
  return `You are a medical literature search specialist. Convert the following Chinese research question into structured search parameters.

Chinese input: "${chineseInput}"

Output ONLY valid JSON in this exact format (no markdown, no explanation outside JSON):
{
  "englishKeywords": ["keyword1", "keyword2"],
  "meshTerms": ["MeSH Term 1", "MeSH Term 2"],
  "pubmedQuery": "full PubMed query string with MeSH terms and field tags",
  "europePmcQuery": "full Europe PMC query string",
  "explanation": "Brief explanation of the search strategy in Chinese"
}

Requirements:
- pubmedQuery must use MeSH terms and [Title/Abstract] field tags where appropriate
- europePmcQuery should use simpler syntax suitable for Europe PMC REST API
- All keywords and MeSH terms must be in English
- explanation should be in Chinese, explaining why these terms were chosen`
}

export async function translateSearch(chineseInput: string): Promise<SearchTranslationResult> {
  const result: SearchTranslationResult = {
    originalChinese: chineseInput,
    englishKeywords: [],
    meshTerms: [],
    pubmedQuery: '',
    europePmcQuery: '',
    explanation: '',
    warnings: [],
    createdAt: Date.now()
  }

  if (!chineseInput || chineseInput.trim() === '') {
    result.warnings.push('输入为空')
    return result
  }

  const response = await chat(buildPrompt(chineseInput))
  if (response.startsWith('[AiService]')) {
    result.warnings.push(response)
    return result
  }

  try {
    // Extract JSON from response (strip markdown code fences if present)
    let jsonStr = response.trim()
    if (jsonStr.startsWith('```')) {
      const end = jsonStr.lastIndexOf('```')
      jsonStr = jsonStr.substring(jsonStr.indexOf('\n'), end).trim()
    }
    const parsed = JSON.parse(jsonStr) as Record<string, Object>

    result.englishKeywords = (parsed['englishKeywords'] as string[]) || []
    result.meshTerms = (parsed['meshTerms'] as string[]) || []
    result.pubmedQuery = (parsed['pubmedQuery'] as string) || ''
    result.europePmcQuery = (parsed['europePmcQuery'] as string) || ''
    result.explanation = (parsed['explanation'] as string) || ''
  } catch (e) {
    result.warnings.push(`JSON parse failed: ${(e as Error).message}`)
  }

  return result
}

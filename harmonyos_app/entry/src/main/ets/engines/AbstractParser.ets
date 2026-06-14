// engines/AbstractParser.ets
// M3-T03: AI 摘要结构化解析
import { chat } from './AiService'
import { AbstractAnalysis } from '../models/AbstractAnalysisModel'
import type { Paper } from '../model/PaperModel'

function buildPrompt(abstractText: string, title: string): string {
  return `Analyze this biomedical paper abstract and output ONLY valid JSON:

Title: ${title}
Abstract: ${abstractText}

Output format:
{
  "researchQuestion": "core question in Chinese",
  "methods": "main methods in Chinese",
  "mainFindings": "key findings in Chinese",
  "limitations": "stated limitations in Chinese",
  "relevanceScore": number 1-10,
  "relevanceReason": "why this score in Chinese",
  "keywords": ["keyword1","keyword2"],
  "studyType": "RCT|cohort|case-control|review|meta-analysis|basic research|other",
  "clinicalValue": "assessment in Chinese",
  "mechanismValue": "assessment in Chinese"
}`
}

export async function parseAbstract(paper: Paper): Promise<AbstractAnalysis> {
  const now = Date.now()
  const empty: AbstractAnalysis = {
    paperId: paper.id,
    researchQuestion: '',
    methods: '',
    mainFindings: '',
    limitations: '',
    relevanceScore: 0,
    relevanceReason: '',
    keywords: [],
    studyType: '',
    clinicalValue: '',
    mechanismValue: '',
    createdAt: now,
    updatedAt: now
  }

  if (!paper.abstract || paper.abstract.trim() === '') {
    return empty
  }

  const response = await chat(buildPrompt(paper.abstract, paper.title))
  if (response.startsWith('[AiService]')) {
    return empty
  }

  try {
    let jsonStr = response.trim()
    if (jsonStr.startsWith('```')) {
      const end = jsonStr.lastIndexOf('```')
      jsonStr = jsonStr.substring(jsonStr.indexOf('\n'), end).trim()
    }
    const parsed = JSON.parse(jsonStr) as Record<string, Object>
    return {
      paperId: paper.id,
      researchQuestion: (parsed['researchQuestion'] as string) || '',
      methods: (parsed['methods'] as string) || '',
      mainFindings: (parsed['mainFindings'] as string) || '',
      limitations: (parsed['limitations'] as string) || '',
      relevanceScore: Number(parsed['relevanceScore']) || 0,
      relevanceReason: (parsed['relevanceReason'] as string) || '',
      keywords: (parsed['keywords'] as string[]) || [],
      studyType: (parsed['studyType'] as string) || '',
      clinicalValue: (parsed['clinicalValue'] as string) || '',
      mechanismValue: (parsed['mechanismValue'] as string) || '',
      createdAt: now,
      updatedAt: now
    }
  } catch (e) {
    return empty
  }
}

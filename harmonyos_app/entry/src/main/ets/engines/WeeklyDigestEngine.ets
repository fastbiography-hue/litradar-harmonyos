// engines/WeeklyDigestEngine.ets
// M3-T10: AI 高分文献周报生成
import type { Paper } from '../model/PaperModel'
import { chat } from './AiService'

export interface WeeklyDigest {
  generatedAt: number
  paperCount: number
  highScoreCount: number
  summary: string
  error?: string
}

function buildDigestPrompt(papers: Paper[]): string {
  const lines = papers.map((p: Paper, i: number) =>
    `${i + 1}. ${p.title} (${p.journal}, ${p.year}). Score: ${p.relevanceScore}. Abstract: ${(p.abstract || '').substring(0, 200)}`
  )
  return `You are a medical genetics researcher. Write a weekly literature digest in Chinese summarizing these ${papers.length} papers. Include: 1) Overall theme 2) Key findings per paper 3) Clinical implications. Keep under 800 words.\n\n${lines.join('\n')}`
}

export async function generateWeeklyDigest(papers: Paper[], minScore: number = 7): Promise<WeeklyDigest> {
  const highScore = papers.filter((p: Paper) => p.relevanceScore >= minScore)
  if (highScore.length === 0) {
    return { generatedAt: Date.now(), paperCount: papers.length, highScoreCount: 0, summary: '' }
  }

  const response = await chat(buildDigestPrompt(highScore.slice(0, 10)))
  if (response.startsWith('[AiService]')) {
    return { generatedAt: Date.now(), paperCount: papers.length, highScoreCount: highScore.length, summary: '', error: response }
  }

  return { generatedAt: Date.now(), paperCount: papers.length, highScoreCount: highScore.length, summary: response }
}

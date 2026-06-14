// engine/ScoreEngine.ets
import { Paper } from '../model/PaperModel'

const HIGH_IMPACT_JOURNALS: string[] = [
  'nature', 'science', 'cell', 'lancet', 'nejm', 'jama',
  'nature genetics', 'nature medicine', 'neuron', 'bmj'
]

function jaccardSimilarity(a: string, b: string): number {
  const tokenize = (s: string): string[] => {
    return s.replace(/[^\w\s]/g, ' ')
      .toLowerCase()
      .split(/\s+/)
      .filter((t: string) => t.length > 1)
  }
  const setA: string[] = tokenize(a)
  const setB: string[] = tokenize(b)
  if (setA.length === 0 || setB.length === 0) return 0.0

  const setBSet = new Set(setB)
  const intersection = setA.filter((t: string) => setBSet.has(t)).length
  const union = new Set([...setA, ...setB]).size
  return union > 0 ? intersection / union : 0.0
}

export function deduplicatePapers(papers: Paper[]): Paper[] {
  const seenDOI = new Set<string>()
  const seenPMID = new Set<string>()
  const kept: Paper[] = []

  for (const p of papers) {
    const doi = (p.doi || '').trim().toLowerCase()
    const pmid = (p.pmid || '').trim()

    if (doi && seenDOI.has(doi)) continue
    if (pmid && seenPMID.has(pmid)) continue

    const titleNorm = (p.title || '').replace(/[^\w\s]/g, '').toLowerCase().trim()
    let isDup = false
    for (const keptPaper of kept) {
      const keptTitleNorm = (keptPaper.title || '').replace(/[^\w\s]/g, '').toLowerCase().trim()
      if (jaccardSimilarity(titleNorm, keptTitleNorm) >= 0.85) {
        isDup = true
        break
      }
    }
    if (isDup) continue

    if (doi) seenDOI.add(doi)
    if (pmid) seenPMID.add(pmid)
    kept.push(p)
  }
  return kept
}

export function scorePapers(papers: Paper[], keywords: string[]): Paper[] {
  for (const p of papers) {
    let s = 0.0
    const titleLower = (p.title || '').toLowerCase()
    const abstractLower = (p.abstract || '').toLowerCase()
    const meshLower = (p.meshTerms || '').toLowerCase()

    let titleHits = 0
    for (const kw of keywords) {
      if (kw.toLowerCase() !== '' && titleLower.includes(kw.toLowerCase())) {
        titleHits++
      }
    }
    s += Math.min(titleHits * 2, 6)

    let abstractHits = 0
    for (const kw of keywords) {
      if (kw.toLowerCase() !== '' && abstractLower.includes(kw.toLowerCase())) {
        abstractHits++
      }
    }
    s += Math.min(abstractHits, 3)

    let meshHits = 0
    for (const kw of keywords) {
      if (kw.toLowerCase() !== '' && meshLower.includes(kw.toLowerCase())) {
        meshHits++
      }
    }
    s += Math.min(meshHits * 0.5, 1)

    const journalLower = (p.journal || '').toLowerCase()
    for (const j of HIGH_IMPACT_JOURNALS) {
      if (journalLower.includes(j)) {
        s += 1.0
        break
      }
    }

    try {
      const yearNum = parseInt(p.year || '0')
      if (yearNum >= 2022) s += 0.5
    } catch (e) {
      // ignore
    }

    if ((p.citations || 0) >= 50) s += 0.5

    p.relevanceScore = Math.round(s * 10) / 10
    if (p.relevanceScore > 10.0) p.relevanceScore = 10.0
  }

  papers.sort((a, b) => b.relevanceScore - a.relevanceScore)
  return papers
}

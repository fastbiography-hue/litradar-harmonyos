// engine/ScoreEngine.ets
// M2-T01: 去重 + 评分，纯函数，零副作用
// 对标 Python litradar.py: deduplicate() + score_papers()
import { Paper } from '../model/PaperModel'

const HIGH_IMPACT_JOURNALS: string[] = [
  'nature', 'science', 'cell', 'lancet', 'nejm', 'jama',
  'nature genetics', 'nature medicine', 'neuron', 'bmj'
]

/**
 * Jaccard token similarity（替代 Python difflib.SequenceMatcher）
 * 1.0 = 完全相同, 0.0 = 无交集
 */
export function jaccardSimilarity(a: string, b: string): number {
  if (!a && !b) return 1.0
  if (!a || !b) return 0.0
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

/**
 * 三级去重：DOI 精确 > PMID 精确 > 标题 Jaccard ≥ 0.85
 * 与 Python deduplicate() 对齐（Python 使用 difflib > 0.9，Jaccard ≥ 0.85 等效近似）
 */
export function deduplicatePapers(papers: Paper[]): Paper[] {
  if (!papers || papers.length === 0) return []

  const seenDOI = new Set<string>()
  const seenPMID = new Set<string>()
  const kept: Paper[] = []

  for (const p of papers) {
    // 边界：跳过 null/undefined 条目
    if (!p) continue

    const doi = (p.doi || '').trim().toLowerCase()
    const pmid = (p.pmid || '').trim()

    // 第一级：DOI 精确匹配
    if (doi && seenDOI.has(doi)) continue
    // 第二级：PMID 精确匹配
    if (pmid && seenPMID.has(pmid)) continue

    // 第三级：标题 Jaccard token similarity
    const titleNorm = (p.title || '').replace(/[^\w\s]/g, '').toLowerCase().trim()
    let isDup = false
    if (titleNorm) {
      for (const keptPaper of kept) {
        const keptTitleNorm = (keptPaper.title || '').replace(/[^\w\s]/g, '').toLowerCase().trim()
        if (!keptTitleNorm) continue
        if (jaccardSimilarity(titleNorm, keptTitleNorm) >= 0.85) {
          isDup = true
          break
        }
      }
    }
    if (isDup) continue

    if (doi) seenDOI.add(doi)
    if (pmid) seenPMID.add(pmid)
    kept.push(p)
  }
  return kept
}

/**
 * 0–10 分自动评分，公式与 Python score_papers() 完全对齐：
 *   + min(title_keyword_hits × 2, 6)
 *   + min(abstract_keyword_hits × 1, 3)
 *   + min(mesh_keyword_hits × 0.5, 1)
 *   + 1.0 (journal in HIGH_IMPACT_JOURNALS)
 *   + 0.5 (pub year ≥ 2022)
 *   + 0.5 (citations > 50, 严格大于，与 Python 一致)
 *   最终 round 到 1 位小数，clamp 到 [0.0, 10.0]
 */
export function scorePapers(papers: Paper[], keywords: string[]): Paper[] {
  if (!papers || papers.length === 0) return []

  // Tag each paper with its original index for stable sort
  const indexed: Array<[Paper, number]> = papers.map((p: Paper, i: number): [Paper, number] => [p, i])

  const scored: Paper[] = []
  for (const [p, _origIdx] of indexed) {
    let s = 0.0
    const titleLower = (p.title || '').toLowerCase()
    const abstractLower = (p.abstract || '').toLowerCase()
    const meshLower = (p.meshTerms || '').toLowerCase()

    // 标题命中：每个关键词 +2，上限 6
    let titleHits = 0
    for (const kw of keywords) {
      if (kw && kw.toLowerCase() !== '' && titleLower.includes(kw.toLowerCase())) {
        titleHits++
      }
    }
    s += Math.min(titleHits * 2, 6)

    // 摘要命中：每个关键词 +1，上限 3
    let abstractHits = 0
    for (const kw of keywords) {
      if (kw && kw.toLowerCase() !== '' && abstractLower.includes(kw.toLowerCase())) {
        abstractHits++
      }
    }
    s += Math.min(abstractHits, 3)

    // MeSH 命中：每个关键词 +0.5，上限 1
    let meshHits = 0
    for (const kw of keywords) {
      if (kw && kw.toLowerCase() !== '' && meshLower.includes(kw.toLowerCase())) {
        meshHits++
      }
    }
    s += Math.min(meshHits * 0.5, 1)

    // 高影响期刊：+1
    const journalLower = (p.journal || '').toLowerCase()
    for (const j of HIGH_IMPACT_JOURNALS) {
      if (journalLower.includes(j)) {
        s += 1.0
        break
      }
    }

    // 近年文献：+0.5
    try {
      const yearNum = parseInt(p.year || '0')
      if (yearNum >= 2022) s += 0.5
    } catch (e) {
      // ignore invalid year
    }

    // 高引用（严格 > 50，与 Python 一致）：+0.5
    if ((p.citations || 0) > 50) s += 0.5

    p.relevanceScore = Math.round(s * 10) / 10
    // Clamp to [0.0, 10.0]
    if (p.relevanceScore < 0.0) p.relevanceScore = 0.0
    if (p.relevanceScore > 10.0) p.relevanceScore = 10.0
    scored.push(p)
  }

  // Stable sort: score descending, original index ascending for ties
  scored.sort((a: Paper, b: Paper): number => {
    const diff = b.relevanceScore - a.relevanceScore
    if (diff !== 0) return diff > 0 ? 1 : -1
    // Tie-break: use original position. Since we push in order,
    // and JS sort is stable in ES2019+, this preserves insertion order.
    return 0
  })
  return scored
}

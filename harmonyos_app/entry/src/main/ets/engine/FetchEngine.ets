// engine/FetchEngine.ets
// M2-T02: PubMed + Europe PMC 原生直连，基于 QueryProfile
import { Paper } from '../model/PaperModel'
import type { QueryProfile } from '../models/QueryProfile'
import { httpGetJson } from '../services/HttpService'

const PUBMED_ESEARCH  = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi'
const PUBMED_ESUMMARY = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi'
const EUROPE_PMC_SEARCH = 'https://www.ebi.ac.uk/europepmc/webservices/rest/search'

const DEFAULT_MAX = 20

// ── helpers ────────────────────────────────────────

function safeStr(v: Object | undefined, fallback: string = ''): string {
  if (v === undefined || v === null) return fallback
  return String(v)
}

function safeNum(v: Object | undefined, fallback: number = 0): number {
  if (v === undefined || v === null) return fallback
  const n = Number(v)
  return isNaN(n) ? fallback : n
}

function sleepMs(ms: number): Promise<void> {
  return new Promise<void>((resolve: () => void) => setTimeout(resolve, ms))
}

// ── PubMed ─────────────────────────────────────────

async function fetchPubMedIds(query: string, maxResults: number): Promise<string[]> {
  const params = `db=pubmed&term=${encodeURIComponent(query)}&retmax=${maxResults}&sort=relevance&retmode=json`
  const url = `${PUBMED_ESEARCH}?${params}`
  const data = await httpGetJson(url)
  if (!data) return []
  const esr = data['esearchresult'] as Record<string, Object> | undefined
  if (!esr) return []
  return (esr['idlist'] ?? []) as string[]
}

async function fetchPubMedDetails(pmids: string[], profile: QueryProfile): Promise<Paper[]> {
  const papers: Paper[] = []
  const batchSize = 50
  for (let i = 0; i < pmids.length; i += batchSize) {
    const batch = pmids.slice(i, i + batchSize)
    const params = `db=pubmed&id=${batch.join(',')}&retmode=json`
    const url = `${PUBMED_ESUMMARY}?${params}`
    const data = await httpGetJson(url)
    if (!data) continue
    const result = data['result'] as Record<string, Object> | undefined
    if (!result) continue
    const uids = result['uids'] as string[] | undefined
    if (!uids) continue
    for (const uid of uids) {
      const raw = result[uid] as Record<string, Object> | undefined
      if (!raw) continue
      const paper = mapPubMedSummary(raw, uid, profile.name)
      if (paper) papers.push(paper)
    }
    await sleepMs(334)
  }
  return papers
}

function mapPubMedSummary(raw: Record<string, Object>, pmid: string, queryTag: string): Paper | null {
  try {
    const title = safeStr(raw['title'])
    if (!title) return null

    const authorList = raw['authors'] as Record<string, Object>[] | undefined
    const authors: string[] = []
    if (authorList) {
      for (const a of authorList) {
        const name = safeStr(a['name'])
        if (name) authors.push(name)
      }
    }
    const firstAuthor = authors.length > 0 ? authors[0] : safeStr(raw['sortfirstauthor'])

    const articleIds = raw['articleids'] as Record<string, Object>[] | undefined
    let doi = ''
    let pmcid = ''
    if (articleIds) {
      for (const idObj of articleIds) {
        const idtype = safeStr(idObj['idtype'])
        if (idtype === 'doi') doi = safeStr(idObj['value'])
        if (idtype === 'pmc') pmcid = safeStr(idObj['value'])
      }
    }

    const pubDate = safeStr(raw['pubdate'])
    const year = pubDate.length >= 4 ? pubDate.substring(0, 4) : safeStr(raw['epubdate']).substring(0, 4)

    return {
      id: `pmid${pmid}`,
      title: title,
      firstAuthor: firstAuthor,
      allAuthors: authors.join('; '),
      journal: safeStr(raw['source']),
      year: year || '',
      pubDate: pubDate || safeStr(raw['epubdate']),
      abstract: '',  // ESummary does not include abstracts
      meshTerms: '',
      keywords: '',
      doi: doi,
      pmid: pmid,
      pmcid: pmcid,
      isOA: pmcid ? 'Yes' : 'No',
      source: 'PubMed',
      citations: 0,
      queryTag: queryTag,
      relevanceScore: 0.0,
      pdfPath: '',
      pdfMd5: '',
      createdAt: '',
      updatedAt: ''
    }
  } catch (e) {
    console.error('[FetchEngine] mapPubMedSummary failed:', (e as Error).message)
    return null
  }
}

export async function fetchPubMed(profile: QueryProfile, maxResults: number = DEFAULT_MAX): Promise<Paper[]> {
  try {
    const query = profile.pubmedQuery
    if (!query) return []
    const ids = await fetchPubMedIds(query, maxResults)
    if (ids.length === 0) return []
    return await fetchPubMedDetails(ids, profile)
  } catch (e) {
    console.error('[FetchEngine] fetchPubMed failed:', (e as Error).message)
    return []
  }
}

// ── Europe PMC ─────────────────────────────────────

function mapEuropePmcToPaper(raw: Record<string, Object>, queryTag: string): Paper | null {
  try {
    const title = safeStr(raw['title'])
    if (!title) return null

    const pmid = safeStr(raw['pmid'])
    const pmcid = safeStr(raw['pmcid'])
    const doi = safeStr(raw['doi'])
    const hasOA = safeStr(raw['isOpenAccess']) === 'Y'
    const authorString = safeStr(raw['authorString'])
    const firstAuthor = authorString.split(',')[0]?.trim() || ''

    return {
      id: pmid ? `pmid${pmid}` : `epmc${safeStr(raw['id'])}`,
      title: title,
      firstAuthor: firstAuthor,
      allAuthors: authorString.replace(/,/g, '; '),
      journal: safeStr(raw['journalTitle']),
      year: safeStr(raw['pubYear']),
      pubDate: safeStr(raw['firstPublicationDate']),
      abstract: safeStr(raw['abstractText']),
      meshTerms: '',
      keywords: '',
      doi: doi,
      pmid: pmid,
      pmcid: pmcid,
      isOA: hasOA ? 'Yes' : 'No',
      source: 'Europe PMC',
      citations: safeNum(raw['citedByCount']),
      queryTag: queryTag,
      relevanceScore: 0.0,
      pdfPath: '',
      pdfMd5: '',
      createdAt: '',
      updatedAt: ''
    }
  } catch (e) {
    console.error('[FetchEngine] mapEuropePmcToPaper failed:', (e as Error).message)
    return null
  }
}

export async function fetchEuropePmc(profile: QueryProfile, maxResults: number = DEFAULT_MAX): Promise<Paper[]> {
  try {
    const query = profile.europePmcQuery
    if (!query) return []
    const papers: Paper[] = []
    let cursor = '*'
    const pageSize = Math.min(maxResults, 25)

    while (papers.length < maxResults) {
      const params = `query=${encodeURIComponent(query)}&resultType=core&pageSize=${pageSize}&format=json&cursorMark=${encodeURIComponent(cursor)}`
      const url = `${EUROPE_PMC_SEARCH}?${params}`
      const data = await httpGetJson(url)
      if (!data) break

      const resultList = data['resultList'] as Record<string, Object> | undefined
      if (!resultList) break
      const items = resultList['result'] as Record<string, Object>[] | undefined
      if (!items || items.length === 0) break

      for (const item of items) {
        const paper = mapEuropePmcToPaper(item, profile.name)
        if (paper) papers.push(paper)
        if (papers.length >= maxResults) break
      }

      const nextCursor = safeStr(resultList['nextCursorMark'])
      if (!nextCursor || nextCursor === cursor) break
      cursor = nextCursor
      await sleepMs(200)
    }
    return papers
  } catch (e) {
    console.error('[FetchEngine] fetchEuropePmc failed:', (e as Error).message)
    return []
  }
}

// ── 统一入口 ────────────────────────────────────────

/**
 * 同时抓取 PubMed 和 Europe PMC，合并结果。
 * 不在这里去重、评分、写库。
 */
export async function fetchAll(profile: QueryProfile, maxResults: number = DEFAULT_MAX): Promise<Paper[]> {
  const results = await Promise.all([
    fetchPubMed(profile, maxResults).catch((): Paper[] => []),
    fetchEuropePmc(profile, maxResults).catch((): Paper[] => [])
  ])
  return results[0].concat(results[1])
}

// engine/FetchEngine.ets
// M2-T02: PubMed + Europe PMC 原生直连，基于 QueryProfile
import { Paper } from '../model/PaperModel'
import type { QueryProfile } from '../models/QueryProfile'
import { httpGetJson } from '../services/HttpService'

const PUBMED_ESEARCH = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi'
const PUBMED_EFETCH = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi'
const EUROPE_PMC_SEARCH = 'https://www.ebi.ac.uk/europepmc/webservices/rest/search'

function simpleHash(str: string): string {
  let hash = 5381
  for (let i = 0; i < str.length; i++) {
    hash = ((hash << 5) + hash) + str.charCodeAt(i)
    hash = hash & hash
  }
  return Math.abs(hash).toString(16).padStart(8, '0')
}

function sleepMs(ms: number): Promise<void> {
  return new Promise<void>((resolve: () => void) => {
    setTimeout(resolve, ms)
  })
}

// ── PubMed ──────────────────────────────────────────

async function pubmedEsearch(query: string, maxResults: number): Promise<string[]> {
  const params = `db=pubmed&term=${encodeURIComponent(query)}&retmax=${maxResults}&sort=relevance&usehistory=y&retmode=json`
  const url = `${PUBMED_ESEARCH}?${params}`
  const data = await httpGetJson(url)
  if (!data) return []
  const esearchResult = data['esearchresult'] as Record<string, Object> | undefined
  if (!esearchResult) return []
  const idList = esearchResult['idlist'] as string[] | undefined
  return idList || []
}

async function pubmedEfetch(ids: string[]): Promise<Record<string, Object>[]> {
  const results: Record<string, Object>[] = []
  const batchSize = 200
  for (let i = 0; i < ids.length; i += batchSize) {
    const batch = ids.slice(i, i + batchSize)
    const params = `db=pubmed&id=${batch.join(',')}&rettype=abstract&retmode=json`
    const url = `${PUBMED_EFETCH}?${params}`
    const data = await httpGetJson(url)
    if (!data) continue
    const result = data['result'] as Record<string, Object> | undefined
    if (result) {
      const uids = result['uids'] as string[] | undefined
      if (uids) {
        for (const uid of uids) {
          const article = result[uid] as Record<string, Object> | undefined
          if (article) {
            article['_pmid'] = uid
            results.push(article)
          }
        }
      }
    }
    await sleepMs(334)  // ~3 req/s without API key
  }
  return results
}

function parsePubmedArticle(art: Record<string, Object>, pmid: string, queryTag: string): Paper | null {
  try {
    const title = (art['title'] ?? '') as string
    const authorList = art['authors'] as Record<string, Object>[] | undefined
    const authors: string[] = []
    if (authorList) {
      for (const a of authorList) {
        const name = (a['name'] ?? '') as string
        if (name) authors.push(name)
      }
    }
    const firstAuthor = authors.length > 0 ? authors[0] : ''

    const articleIds = art['articleids'] as Record<string, Object>[] | undefined
    let doi = ''
    let pmcid = ''
    if (articleIds) {
      for (const idObj of articleIds) {
        if ((idObj['idtype'] ?? '') === 'doi' && !doi) {
          doi = (idObj['value'] ?? '') as string
        }
        if ((idObj['idtype'] ?? '') === 'pmc') {
          pmcid = (idObj['value'] ?? '') as string
        }
      }
    }

    const meshList = art['mesh'] as Record<string, Object>[] | undefined
    const meshTerms: string[] = []
    if (meshList) {
      for (const m of meshList) {
        const descriptor = (m['descriptor'] ?? '') as string
        if (descriptor) meshTerms.push(descriptor)
      }
    }

    const pubDate = (art['pubdate'] ?? '') as string

    return {
      id: `pmid${pmid}`,
      title: title,
      firstAuthor: firstAuthor || (art['sortfirstauthor'] as string) || '',
      allAuthors: authors.join('; '),
      journal: (art['source'] ?? '') as string,
      year: pubDate.length >= 4 ? pubDate.substring(0, 4) : '',
      pubDate: pubDate,
      abstract: (art['abstract'] ?? '') as string,
      meshTerms: meshTerms.join('; '),
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
    console.error('[FetchEngine] parsePubmedArticle failed:', (e as Error).message)
    return null
  }
}

export async function fetchPubMed(profile: QueryProfile, maxResults: number = 100): Promise<Paper[]> {
  try {
    console.info(`[FetchEngine] PubMed: ${profile.pubmedQuery.substring(0, 100)}...`)
    const ids = await pubmedEsearch(profile.pubmedQuery, maxResults)
    if (ids.length === 0) {
      console.info('[FetchEngine] PubMed: no results')
      return []
    }
    const articles = await pubmedEfetch(ids)
    const papers: Paper[] = []
    for (const art of articles) {
      const pmid = (art['_pmid'] ?? '') as string
      const paper = parsePubmedArticle(art, pmid, profile.name)
      if (paper) papers.push(paper)
    }
    console.info(`[FetchEngine] PubMed → ${papers.length} papers`)
    return papers
  } catch (e) {
    console.error('[FetchEngine] fetchPubMed failed:', (e as Error).message)
    return []
  }
}

// ── Europe PMC ──────────────────────────────────────

export async function fetchEuropePmc(profile: QueryProfile, maxResults: number = 100): Promise<Paper[]> {
  try {
    console.info(`[FetchEngine] Europe PMC: ${profile.europePmcQuery.substring(0, 100)}...`)
    const allPapers: Paper[] = []
    let cursor = '*'
    const pageSize = Math.min(maxResults, 100)

    while (allPapers.length < maxResults) {
      const params = `query=${encodeURIComponent(profile.europePmcQuery)}&resultType=core&pageSize=${pageSize}&format=json&cursorMark=${encodeURIComponent(cursor)}`
      const url = `${EUROPE_PMC_SEARCH}?${params}`
      const data = await httpGetJson(url)
      if (!data) break

      const resultList = data['resultList'] as Record<string, Object> | undefined
      if (!resultList) break

      const items = resultList['result'] as Record<string, Object>[] | undefined
      if (!items || items.length === 0) break

      for (const r of items) {
        try {
          const pmid = (r['pmid'] ?? '') as string
          const pmcid = (r['pmcid'] ?? '') as string
          const doi = (r['doi'] ?? '') as string
          const title = (r['title'] ?? '') as string
          const hasOA = (r['isOpenAccess'] ?? '') === 'Y'

          allPapers.push({
            id: pmid ? `pmid${pmid}` : `epmc${simpleHash(title || 'unknown')}`,
            title: title,
            firstAuthor: ((r['authorString'] ?? '') as string).split(',')[0]?.trim() || '',
            allAuthors: ((r['authorString'] ?? '') as string).replace(/,/g, '; '),
            journal: (r['journalTitle'] ?? '') as string,
            year: String(r['pubYear'] ?? ''),
            pubDate: (r['firstPublicationDate'] ?? '') as string,
            abstract: (r['abstractText'] ?? '') as string,
            meshTerms: '',
            keywords: '',
            doi: doi,
            pmid: pmid,
            pmcid: pmcid,
            isOA: hasOA ? 'Yes' : 'No',
            source: 'Europe PMC',
            citations: Number(r['citedByCount'] ?? 0),
            queryTag: profile.name,
            relevanceScore: 0.0,
            pdfPath: '',
            pdfMd5: '',
            createdAt: '',
            updatedAt: ''
          })
        } catch (e) {
          console.error('[FetchEngine] Europe PMC parse item failed:', (e as Error).message)
        }
      }

      const nextCursor = (resultList['nextCursorMark'] ?? '') as string
      if (!nextCursor || nextCursor === cursor) break
      cursor = nextCursor
      await sleepMs(200)
    }

    console.info(`[FetchEngine] Europe PMC → ${allPapers.length} papers`)
    return allPapers
  } catch (e) {
    console.error('[FetchEngine] fetchEuropePmc failed:', (e as Error).message)
    return []
  }
}

// ── 统一入口 ────────────────────────────────────────

export async function fetchAll(profile: QueryProfile, maxResults: number = 100): Promise<Paper[]> {
  const [pubmedResults, epmcResults] = await Promise.all([
    fetchPubMed(profile, maxResults),
    fetchEuropePmc(profile, maxResults)
  ])
  return pubmedResults.concat(epmcResults)
}

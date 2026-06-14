// engine/FetchEngine.ets
import http from '@ohos.net.http'
import { Paper } from '../model/PaperModel'

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

async function httpGetJson(url: string, timeout: number = 60000): Promise<Record<string, Object> | null> {
  const req = http.createHttp()
  try {
    const res = await req.request(url, {
      method: http.RequestMethod.GET,
      connectTimeout: timeout,
      readTimeout: timeout,
      header: { 'Accept': 'application/json' }
    })
    if (res.responseCode !== 200) {
      console.error(`[FetchEngine] HTTP ${res.responseCode} for ${url.substring(0, 80)}`)
      return null
    }
    // result may be string or already-parsed object depending on content-type
    const body: string | Object | ArrayBuffer = res.result
    if (typeof body === 'string') {
      return JSON.parse(body) as Record<string, Object>
    }
    if (typeof body === 'object') {
      return body as Record<string, Object>
    }
    return null
  } catch (e) {
    console.error(`[FetchEngine] HTTP GET failed: ${url.substring(0, 80)} — ${(e as Error).message}`)
    return null
  } finally {
    req.destroy()
  }
}

// PubMed E-utilities — esearch
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

// PubMed E-utilities — efetch (JSON abstracts, supports retmode=json)
async function pubmedEfetch(ids: string[], apiKey: string): Promise<Record<string, Object>[]> {
  const results: Record<string, Object>[] = []
  const batchSize = 200
  for (let i = 0; i < ids.length; i += batchSize) {
    const batch = ids.slice(i, i + batchSize)
    const params = `db=pubmed&id=${batch.join(',')}&rettype=abstract&retmode=json`
    const keyParam = apiKey ? `&api_key=${apiKey}` : ''
    const url = `${PUBMED_EFETCH}?${params}${keyParam}`
    try {
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
    } catch (e) {
      console.error('[FetchEngine] pubmedEfetch batch failed:', (e as Error).message)
    }
    // Rate limit: ~3 req/s without API key
    const delay = apiKey ? 100 : 334
    await sleepMs(delay)
  }
  return results
}

function parsePubmedArticle(art: Record<string, Object>, pmid: string): Paper | null {
  try {
    const title = (art['title'] ?? '') as string
    const authors: string[] = []
    const authorList = art['authors'] as Record<string, Object>[] | undefined
    if (authorList) {
      for (const a of authorList) {
        const name = (a['name'] ?? '') as string
        if (name) authors.push(name)
      }
    }
    const firstAuthor = authors.length > 0 ? authors[0] : ''
    const allAuthors = authors.join('; ')

    const abstract = (art['abstract'] ?? '') as string
    const journal = (art['source'] ?? '') as string
    const pubDate = (art['pubdate'] ?? '') as string
    const year = pubDate.length >= 4 ? pubDate.substring(0, 4) : ''

    const elocationIds = art['elocationid'] as Record<string, Object>[] | undefined
    let doi = ''
    if (elocationIds) {
      for (const e of elocationIds) {
        if ((e['eidtype'] ?? '') === 'doi') {
          doi = (e['content'] ?? '') as string
          break
        }
      }
    }

    // More specific DOI extraction
    const articleIds = art['articleids'] as Record<string, Object>[] | undefined
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

    // Authors might not be in JSON format, fallback to author list from sortfirstauthor
    if (!firstAuthor) {
      const sortFirstAuthor = (art['sortfirstauthor'] ?? '') as string
      if (sortFirstAuthor) {
        // authors array might be in different format
        const authorNames = sortFirstAuthor
      }
    }

    // If title is missing, try to extract from article
    if (!title || title === '') {
      const titleFromArticle = (art['articletitle'] ?? '') as string
      if (!titleFromArticle) return null
    }

    return {
      id: `pmid${pmid}`,
      title: title || (art['articletitle'] as string) || '',
      firstAuthor: firstAuthor || (art['sortfirstauthor'] as string) || '',
      allAuthors: allAuthors || (art['fulljournalname'] as string) || '',
      journal: journal,
      year: year,
      pubDate: pubDate,
      abstract: abstract,
      meshTerms: meshTerms.join('; '),
      keywords: '',
      doi: doi,
      pmid: pmid,
      pmcid: pmcid,
      isOA: pmcid ? 'Yes' : 'No',
      source: 'PubMed',
      citations: 0,
      queryTag: '',
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

export async function fetchPubMed(
  query: string,
  dateFrom: string,
  maxResults: number,
  apiKey: string = ''
): Promise<Paper[]> {
  try {
    const fullQuery = dateFrom
      ? `${query} AND ("${dateFrom}"[Date - Publication] : "3000"[Date - Publication])`
      : query

    console.info(`[FetchEngine] PubMed esearch: ${fullQuery.substring(0, 100)}...`)
    const ids = await pubmedEsearch(fullQuery, maxResults)
    if (ids.length === 0) {
      console.info('[FetchEngine] PubMed: no results')
      return []
    }
    console.info(`[FetchEngine] PubMed found ${ids.length} IDs, fetching details...`)

    const articles = await pubmedEfetch(ids, apiKey)
    const papers: Paper[] = []
    for (const art of articles) {
      const pmid = (art['_pmid'] ?? '') as string
      const paper = parsePubmedArticle(art, pmid)
      if (paper) papers.push(paper)
    }
    console.info(`[FetchEngine] PubMed → ${papers.length} papers`)
    return papers
  } catch (e) {
    console.error('[FetchEngine] fetchPubMed failed:', (e as Error).message)
    return []
  }
}

// Europe PMC REST API
export async function fetchEuropePMC(
  query: string,
  dateFrom: string,
  maxResults: number
): Promise<Paper[]> {
  try {
    let fullQuery = query
    if (dateFrom) {
      fullQuery += ` AND FIRST_PDATE:[${dateFrom} TO 3000-12-31]`
    }
    console.info(`[FetchEngine] Europe PMC: ${fullQuery.substring(0, 100)}...`)

    const allPapers: Paper[] = []
    let cursor = '*'
    const pageSize = Math.min(maxResults, 100)

    while (allPapers.length < maxResults) {
      const params = `query=${encodeURIComponent(fullQuery)}&resultType=core&pageSize=${pageSize}&format=json&cursorMark=${encodeURIComponent(cursor)}`
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

          const paper: Paper = {
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
            queryTag: '',
            relevanceScore: 0.0,
            pdfPath: '',
            pdfMd5: '',
            createdAt: '',
            updatedAt: ''
          }
          allPapers.push(paper)
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
    console.error('[FetchEngine] fetchEuropePMC failed:', (e as Error).message)
    return []
  }
}

export async function fetchAll(
  query: string,
  sources: string[],
  dateFrom: string,
  maxPerSource: number = 100,
  apiKey: string = ''
): Promise<Paper[]> {
  const queue: Promise<Paper[]>[] = []
  for (const src of sources) {
    if (src === 'pubmed') {
      queue.push(fetchPubMed(query, dateFrom, maxPerSource, apiKey))
    } else if (src === 'europe_pmc') {
      queue.push(fetchEuropePMC(query, dateFrom, maxPerSource))
    }
  }
  const results = await Promise.all(queue)
  let all: Paper[] = []
  for (const batch of results) {
    all = all.concat(batch)
  }
  return all
}

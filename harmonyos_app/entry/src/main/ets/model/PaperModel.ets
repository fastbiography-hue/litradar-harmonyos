// model/PaperModel.ets
// ArkTS strict mode requires camelCase for dot-notation field access.

export interface Paper {
  id: string
  title: string
  firstAuthor: string
  allAuthors: string
  journal: string
  year: string
  pubDate: string
  abstract: string
  meshTerms: string
  keywords: string
  doi: string
  pmid: string
  pmcid: string
  isOA: string
  source: string
  citations: number
  queryTag: string
  relevanceScore: number
  pdfPath: string
  pdfMd5: string
  createdAt: string
  updatedAt: string
}

export interface QueryConfig {
  name: string
  query: string
}

export interface StatsInfo {
  total: number
  oa: number
  downloaded: number
  highRelevance: number
}

export interface RunResult {
  found: number
  saved: number
}

// JSON key mapping: Python backend uses space-containing keys,
// ArkTS strict mode requires camelCase dot-notation.
export function mapPaperFromApi(raw: Record<string, Object>): Paper {
  return {
    id: (raw['id'] ?? '') as string,
    title: (raw['Title'] ?? '') as string,
    firstAuthor: (raw['First Author'] ?? '') as string,
    allAuthors: (raw['All Authors'] ?? '') as string,
    journal: (raw['Journal'] ?? '') as string,
    year: (raw['Year'] ?? '') as string,
    pubDate: (raw['Pub Date'] ?? '') as string,
    abstract: (raw['Abstract'] ?? '') as string,
    meshTerms: (raw['MeSH Terms'] ?? '') as string,
    keywords: (raw['Keywords'] ?? '') as string,
    doi: (raw['DOI'] ?? '') as string,
    pmid: (raw['PMID'] ?? '') as string,
    pmcid: (raw['PMCID'] ?? '') as string,
    isOA: (raw['Is OA'] ?? 'No') as string,
    source: (raw['Source'] ?? '') as string,
    citations: (raw['Citations'] ?? 0) as number,
    queryTag: (raw['Query Tag'] ?? '') as string,
    relevanceScore: (raw['Relevance Score'] ?? 0) as number,
    pdfPath: (raw['pdf_path'] ?? '') as string,
    pdfMd5: (raw['pdf_md5'] ?? '') as string,
    createdAt: (raw['created_at'] ?? '') as string,
    updatedAt: (raw['updated_at'] ?? '') as string
  }
}

export function mapStatsFromApi(raw: Record<string, Object>): StatsInfo {
  return {
    total: (raw['total'] ?? 0) as number,
    oa: (raw['oa'] ?? 0) as number,
    downloaded: (raw['downloaded'] ?? 0) as number,
    highRelevance: (raw['high_relevance'] ?? 0) as number
  }
}

export class AppState {
  static readonly STORAGE_KEY_PAPERS = 'papers'
  static readonly STORAGE_KEY_QUERIES = 'queries'
  static readonly STORAGE_KEY_SELECTED_QUERY = 'selectedQuery'
  static readonly STORAGE_KEY_SELECTED_PAPER = 'selectedPaper'
  static readonly STORAGE_KEY_IS_LOADING = 'isLoading'
  static readonly STORAGE_KEY_STATS = 'stats'
  static readonly API_BASE = 'http://172.16.105.2:7749'
}

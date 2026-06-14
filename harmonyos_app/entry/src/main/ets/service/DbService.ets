// service/DbService.ets
import relationalStore from '@ohos.data.relationalStore'
import { Paper } from '../model/PaperModel'
import common from '@ohos.app.ability.common'

const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'litradar.db',
  securityLevel: relationalStore.SecurityLevel.S1
}

const CREATE_TABLE_SQL = `
  CREATE TABLE IF NOT EXISTS papers (
    id TEXT PRIMARY KEY,
    Title TEXT,
    "First Author" TEXT,
    "All Authors" TEXT,
    Journal TEXT,
    Year TEXT,
    "Pub Date" TEXT,
    Abstract TEXT,
    "MeSH Terms" TEXT,
    Keywords TEXT,
    DOI TEXT,
    PMID TEXT,
    PMCID TEXT,
    "Is OA" TEXT DEFAULT 'No',
    Source TEXT,
    Citations INTEGER DEFAULT 0,
    "Query Tag" TEXT,
    "Relevance Score" REAL DEFAULT 0.0,
    pdf_path TEXT,
    pdf_md5 TEXT,
    created_at TEXT,
    updated_at TEXT
  )
`

let _store: relationalStore.RdbStore | null = null

export async function getDb(context: common.UIAbilityContext): Promise<relationalStore.RdbStore | null> {
  if (_store) return _store
  try {
    _store = await relationalStore.getRdbStore(context, STORE_CONFIG)
    await _store.executeSql(CREATE_TABLE_SQL)
    return _store
  } catch (e) {
    console.error('[DbService] getDb failed:', (e as Error).message)
    return null
  }
}

export async function upsertPapers(context: common.UIAbilityContext, papers: Paper[]): Promise<void> {
  try {
    const db = await getDb(context)
    if (!db) {
      return
    }
    for (const p of papers) {
      try {
        const bucket: relationalStore.ValuesBucket = {
          'id': p.id,
          'Title': p.title,
          'First Author': p.firstAuthor,
          'All Authors': p.allAuthors,
          'Journal': p.journal,
          'Year': p.year,
          'Pub Date': p.pubDate,
          'Abstract': p.abstract,
          'MeSH Terms': p.meshTerms,
          'Keywords': p.keywords,
          'DOI': p.doi,
          'PMID': p.pmid,
          'PMCID': p.pmcid,
          'Is OA': p.isOA,
          'Source': p.source,
          'Citations': p.citations,
          'Query Tag': p.queryTag,
          'Relevance Score': p.relevanceScore,
          'pdf_path': p.pdfPath,
          'pdf_md5': p.pdfMd5,
          'created_at': p.createdAt,
          'updated_at': p.updatedAt
        }
        await db.insert('papers', bucket, relationalStore.ConflictResolution.ON_CONFLICT_REPLACE)
      } catch (e) {
        console.error('[DbService] upsertPapers insert failed for', p.id, (e as Error).message)
      }
    }
  } catch (e) {
    console.error('[DbService] upsertPapers failed:', (e as Error).message)
  }
}

export async function queryPapers(
  context: common.UIAbilityContext,
  queryTag: string | null = null,
  limit: number = 200
): Promise<Paper[]> {
  try {
    const db = await getDb(context)
    if (!db) {
      return []
    }
    const predicates = new relationalStore.RdbPredicates('papers')
    if (queryTag) {
      predicates.equalTo('"Query Tag"', queryTag)
    }
    predicates.orderByDesc('"Relevance Score"')
    predicates.limitAs(limit)
    const cursor = await db.query(predicates)
    const result: Paper[] = []
    while (cursor.goToNextRow()) {
      try {
        result.push({
          id: cursor.getString(cursor.getColumnIndex('id')),
          title: cursor.getString(cursor.getColumnIndex('Title')),
          firstAuthor: cursor.getString(cursor.getColumnIndex('First Author')),
          allAuthors: cursor.getString(cursor.getColumnIndex('All Authors')),
          journal: cursor.getString(cursor.getColumnIndex('Journal')),
          year: cursor.getString(cursor.getColumnIndex('Year')),
          pubDate: cursor.getString(cursor.getColumnIndex('Pub Date')),
          abstract: cursor.getString(cursor.getColumnIndex('Abstract')),
          meshTerms: cursor.getString(cursor.getColumnIndex('MeSH Terms')),
          keywords: cursor.getString(cursor.getColumnIndex('Keywords')),
          doi: cursor.getString(cursor.getColumnIndex('DOI')),
          pmid: cursor.getString(cursor.getColumnIndex('PMID')),
          pmcid: cursor.getString(cursor.getColumnIndex('PMCID')),
          isOA: cursor.getString(cursor.getColumnIndex('Is OA')),
          source: cursor.getString(cursor.getColumnIndex('Source')),
          citations: cursor.getLong(cursor.getColumnIndex('Citations')),
          queryTag: cursor.getString(cursor.getColumnIndex('Query Tag')),
          relevanceScore: cursor.getDouble(cursor.getColumnIndex('Relevance Score')),
          pdfPath: cursor.getString(cursor.getColumnIndex('pdf_path')),
          pdfMd5: cursor.getString(cursor.getColumnIndex('pdf_md5')),
          createdAt: cursor.getString(cursor.getColumnIndex('created_at')),
          updatedAt: cursor.getString(cursor.getColumnIndex('updated_at'))
        })
      } catch (e) {
        console.error('[DbService] queryPapers row parse failed:', (e as Error).message)
      }
    }
    cursor.close()
    return result
  } catch (e) {
    console.error('[DbService] queryPapers failed:', (e as Error).message)
    return []
  }
}

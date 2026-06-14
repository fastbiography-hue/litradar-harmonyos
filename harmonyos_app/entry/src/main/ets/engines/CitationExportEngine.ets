// engines/CitationExportEngine.ets
// M3-T04: 12 种引用格式导出引擎 (纯函数)
import { Paper } from '../model/PaperModel'
import { CitationFields, CitationFormat } from '../models/CitationModel'

function toFields(p: Paper): CitationFields {
  const authors = (p.allAuthors || p.firstAuthor || '')
    .split(';')
    .map((a: string) => a.trim())
    .filter((a: string) => a !== '')
  return {
    authors: authors,
    title: p.title || '',
    journal: p.journal || '',
    year: p.year || p.pubDate?.substring(0, 4) || '',
    doi: p.doi || '',
    pmid: p.pmid || '',
    url: p.doi ? `https://doi.org/${p.doi}` : ''
  }
}

function firstAuthorLastName(authors: string[]): string {
  if (authors.length === 0) return 'Anonymous'
  const parts = authors[0].split(' ')
  return parts[parts.length - 1] || authors[0]
}

// ── Individual formatters ───────────────────────────

function fmtGBT7714(f: CitationFields): string {
  const au = f.authors.slice(0, 3).join(', ') + (f.authors.length > 3 ? ', 等' : '')
  return `${au}. ${f.title}[J]. ${f.journal}, ${f.year}${f.doi ? `. DOI: ${f.doi}` : ''}.`
}

function fmtAPA7(f: CitationFields): string {
  const au = f.authors.length > 0 ? `${f.authors[0]}${f.authors.length > 1 ? ', et al.' : ''}` : 'Anonymous'
  return `${au} (${f.year}). ${f.title}. ${f.journal}${f.doi ? `. https://doi.org/${f.doi}` : ''}`
}

function fmtVancouver(f: CitationFields): string {
  const au = f.authors.slice(0, 6).join(', ') + (f.authors.length > 6 ? ', et al.' : '')
  return `${au}. ${f.title}. ${f.journal}. ${f.year}${f.doi ? `. doi:${f.doi}` : ''}`
}

function fmtIEEE(f: CitationFields): string {
  const au = f.authors.join(', ')
  return `[1] ${au}, "${f.title}," ${f.journal}, ${f.year}${f.doi ? `. doi: ${f.doi}` : '.'}`
}

function fmtMLA9(f: CitationFields): string {
  const au = f.authors.length > 0 ? `${f.authors[0]}${f.authors.length > 1 ? ', et al.' : ''}` : 'Anonymous'
  return `${au}. "${f.title}." ${f.journal}, ${f.year}${f.doi ? `. doi:${f.doi}` : '.'}`
}

function fmtChicago(f: CitationFields): string {
  const au = f.authors.length > 0 ? `${f.authors[0]}${f.authors.length > 1 ? ', et al.' : ''}` : 'Anonymous'
  return `${au}. "${f.title}." ${f.journal} (${f.year})${f.doi ? `. https://doi.org/${f.doi}` : '.'}`
}

function fmtHarvard(f: CitationFields): string {
  const au = f.authors.length > 0 ? `${f.authors[0]}${f.authors.length > 1 ? ' et al.' : ''}` : 'Anonymous'
  return `${au} (${f.year}) '${f.title}', ${f.journal}${f.doi ? `. doi:${f.doi}` : '.'}`
}

function fmtBibTeX(f: CitationFields): string {
  const key = `${firstAuthorLastName(f.authors)}${f.year}`
  return `@article{${key},\n  author = {${f.authors.join(' and ')}},\n  title = {${f.title}},\n  journal = {${f.journal}},\n  year = {${f.year}},\n  doi = {${f.doi}}\n}`
}

function fmtRIS(f: CitationFields): string {
  const lines = ['TY  - JOUR']
  for (const a of f.authors) lines.push(`AU  - ${a}`)
  lines.push(`TI  - ${f.title}`, `JO  - ${f.journal}`, `PY  - ${f.year}`)
  if (f.doi) lines.push(`DO  - ${f.doi}`)
  if (f.pmid) lines.push(`ID  - ${f.pmid}`)
  lines.push('ER  - ')
  return lines.join('\n')
}

function fmtCSLJson(f: CitationFields): string {
  return JSON.stringify({
    type: 'article-journal',
    author: f.authors.map((a: string) => ({ family: a.split(' ').pop(), given: a.split(' ')[0] })),
    title: f.title, 'container-title': f.journal,
    issued: { 'date-parts': [[f.year]] }, DOI: f.doi, PMID: f.pmid
  })
}

function fmtWord(f: CitationFields): string {
  return `(${f.authors.length > 0 ? f.authors[0] : 'Anonymous'}, ${f.year})`
}

function fmtMarkdown(f: CitationFields): string {
  const au = f.authors.length > 0 ? f.authors[0] : 'Anonymous'
  return `[^1]: ${au} et al. *${f.title}*. ${f.journal}, ${f.year}.${f.doi ? ` [DOI](${f.url})` : ''}`
}

// ── Public API ───────────────────────────────────────

const FORMATTERS: Record<string, (f: CitationFields) => string> = {
  'GB/T 7714-2015': fmtGBT7714,
  'APA 7th':        fmtAPA7,
  'Vancouver':      fmtVancouver,
  'IEEE':           fmtIEEE,
  'MLA 9th':        fmtMLA9,
  'Chicago':        fmtChicago,
  'Harvard':        fmtHarvard,
  'BibTeX':         fmtBibTeX,
  'RIS':            fmtRIS,
  'CSL-JSON':       fmtCSLJson,
  'Word':           fmtWord,
  'Markdown':       fmtMarkdown
}

export function formatCitation(paper: Paper, format: CitationFormat): string {
  const fields = toFields(paper)
  const fmt = FORMATTERS[format]
  return fmt ? fmt(fields) : ''
}

export function formatCitations(papers: Paper[], format: CitationFormat): string {
  return papers.map((p: Paper) => formatCitation(p, format)).join('\n\n')
}

export function getSupportedFormats(): CitationFormat[] {
  return Object.values(CitationFormat)
}

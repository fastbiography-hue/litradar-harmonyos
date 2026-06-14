// engines/IdentifierParser.ets
// M3-T08: DOI/PMID/PMCID/URL 标识符解析 (纯函数)

export interface ParsedIdentifier {
  type: 'doi' | 'pmid' | 'pmcid' | 'url' | 'unknown'
  value: string
}

const DOI_RE = /10\.\d{4,}\/[\w.\-+/()]+/i
const PMID_RE = /PMID:?\s*(\d{7,8})/i
const PMCID_RE = /PMCID:?\s*(PMC\d+)/i

export function parseIdentifier(input: string): ParsedIdentifier {
  const trimmed = input.trim()
  if (PMCID_RE.test(trimmed)) {
    const m = trimmed.match(PMCID_RE)
    return { type: 'pmcid', value: m ? m[1] : trimmed }
  }
  if (PMID_RE.test(trimmed)) {
    const m = trimmed.match(PMID_RE)
    return { type: 'pmid', value: m ? m[1] : trimmed }
  }
  if (DOI_RE.test(trimmed)) {
    const m = trimmed.match(DOI_RE)
    return { type: 'doi', value: m ? m[0] : trimmed }
  }
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return { type: 'url', value: trimmed }
  }
  return { type: 'unknown', value: trimmed }
}

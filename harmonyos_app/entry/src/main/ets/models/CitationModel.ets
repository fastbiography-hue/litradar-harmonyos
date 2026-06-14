// models/CitationModel.ets
// M3-T04: 引用格式模型

export interface CitationFields {
  authors: string[]
  title: string
  journal: string
  year: string
  volume?: string
  issue?: string
  pages?: string
  doi: string
  pmid: string
  url: string
}

export enum CitationFormat {
  GBT7714 = 'GB/T 7714-2015',
  APA7 = 'APA 7th',
  VANCOUVER = 'Vancouver',
  IEEE = 'IEEE',
  MLA9 = 'MLA 9th',
  CHICAGO = 'Chicago',
  HARVARD = 'Harvard',
  BIBTEX = 'BibTeX',
  RIS = 'RIS',
  CSL_JSON = 'CSL-JSON',
  WORD = 'Word',
  MARKDOWN = 'Markdown'
}

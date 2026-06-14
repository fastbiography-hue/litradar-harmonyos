// models/QueryProfile.ets
// M2-T03: 查询策略配置模型

export interface QueryProfile {
  id: string
  name: string
  enabled: boolean
  keywords: string[]
  pubmedQuery: string
  europePmcQuery: string
  createdAt: number
  updatedAt: number
}

export const DEFAULT_PROFILES: QueryProfile[] = [
  {
    id: 'AD_APOE',
    name: 'AD APOE',
    enabled: true,
    keywords: ['Alzheimer', 'APOE', 'neurodegeneration', 'dementia'],
    pubmedQuery: '(Alzheimer Disease[MeSH Terms] OR Alzheimer*[Title/Abstract]) AND (APOE[Title/Abstract] OR apolipoprotein E[Title/Abstract])',
    europePmcQuery: '(Alzheimer OR Alzheimer\'s) AND (APOE OR "apolipoprotein E")',
    createdAt: 0,
    updatedAt: 0
  },
  {
    id: 'longread_variant',
    name: 'Long-read variant',
    enabled: true,
    keywords: ['long-read', 'PacBio', 'Oxford Nanopore', 'structural variant', 'haplotype'],
    pubmedQuery: '("long-read sequencing"[Title/Abstract] OR PacBio[Title/Abstract] OR "Oxford Nanopore"[Title/Abstract]) AND ("structural variant"[Title/Abstract] OR haplotype[Title/Abstract])',
    europePmcQuery: '("long-read sequencing" OR PacBio OR "Oxford Nanopore") AND ("structural variant" OR haplotype)',
    createdAt: 0,
    updatedAt: 0
  },
  {
    id: 'metabolic_genetics',
    name: 'Metabolic genetics',
    enabled: true,
    keywords: ['metabolism', 'genetics', 'lipid', 'glucose', 'variant'],
    pubmedQuery: '(metabolism[Title/Abstract] OR lipid[Title/Abstract] OR glucose[Title/Abstract]) AND (genetic*[Title/Abstract] OR variant*[Title/Abstract])',
    europePmcQuery: '(metabolism OR lipid OR glucose) AND (genetic OR genetics OR variant)',
    createdAt: 0,
    updatedAt: 0
  }
]

# M2-T02: FetchEngine — PubMed + Europe PMC 原生直连

## 目标
实现 ArkTS 原生 FetchEngine，直连 PubMed E-utilities 和 Europe PMC REST API。

## 允许修改
- `engines/FetchEngine.ets`
- `services/HttpService.ets`（新增，封装 HTTP）
- `models/PaperModel.ets`（类型适配）
- `TASKS.md`

## 禁止修改
- `engines/ScoreEngine.ets`
- `services/ConfigService.ets`（除非仅类型适配）
- `backend/`

## 接口规格

```typescript
export async function fetchPubMed(queryProfile: QueryProfile, maxResults?: number): Promise<Paper[]>
export async function fetchEuropePmc(queryProfile: QueryProfile, maxResults?: number): Promise<Paper[]>
export async function fetchAll(queryProfile: QueryProfile, maxResults?: number): Promise<Paper[]>
```

## 调用流程

### PubMed
1. esearch: `https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term={pubmedQuery}&retmax=100&retmode=json`
2. efetch: `https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id={ids}&rettype=abstract&retmode=json`
3. 解析 → Paper[]

### Europe PMC
1. `https://www.ebi.ac.uk/europepmc/webservices/rest/search?query={europePmcQuery}&resultType=core&pageSize=100&format=json&cursorMark=*`
2. 翻页至 cursorMark 不变或结果为空
3. 解析 → Paper[]

## 要求
- [ ] 使用 QueryProfile.pubmedQuery / europePmcQuery
- [ ] 超时 60s
- [ ] 网络异常返回 [] + console.error
- [ ] 不需要 API Key（速率 3 req/s）
- [ ] PubMed + Europe PMC 结果统一映射为 Paper

## Commit
`feat(fetch): implement native PubMed and Europe PMC fetching`

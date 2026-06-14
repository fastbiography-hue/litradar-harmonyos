# M2-T03: ConfigService — 原生查询配置服务

## 目标
实现 ArkTS 原生 ConfigService，用 HarmonyOS Preferences 保存本地检索策略。

## 允许修改
- `services/ConfigService.ets`
- `models/QueryProfile.ets`（新增）
- `TASKS.md`
- `docs/tasks/M2-T03-config-service.md`
- 必要时最小修改 `pages/Index.ets` 或 `components/QueryPanel.ets`

## 禁止修改
- `engines/ScoreEngine.ets`
- `engines/FetchEngine.ets`
- `backend/`
- `service/DbService.ets`

## 接口规格

```typescript
// models/QueryProfile.ets
export interface QueryProfile {
  id: string
  name: string
  enabled: boolean
  keywords: string[]
  pubmedQuery: string
  europePmcQuery: string
  createdAt: string
  updatedAt: string
}

// services/ConfigService.ets
export async function initDefaults(context: Context): Promise<void>
export async function getAllProfiles(context: Context): Promise<QueryProfile[]>
export async function getProfileById(context: Context, id: string): Promise<QueryProfile | null>
export async function upsertProfile(context: Context, profile: QueryProfile): Promise<void>
export async function deleteProfile(context: Context, id: string): Promise<void>
export async function restoreDefaults(context: Context): Promise<void>
```

## 默认 Query Profiles

### AD_APOE
- id: `ad-apoe`
- name: `AD APOE`
- keywords: `["Alzheimer","APOE","neurodegeneration","dementia"]`
- pubmedQuery: `(Alzheimer Disease[MeSH Terms] OR Alzheimer*[Title/Abstract]) AND (APOE[Title/Abstract] OR apolipoprotein E[Title/Abstract])`
- europePmcQuery: `(Alzheimer OR Alzheimer's) AND (APOE OR "apolipoprotein E")`

### longread_variant
- id: `longread-variant`
- name: `Long-read variant`
- keywords: `["long-read","PacBio","Oxford Nanopore","structural variant","haplotype"]`
- pubmedQuery: `(("long-read sequencing"[Title/Abstract] OR PacBio[Title/Abstract] OR "Oxford Nanopore"[Title/Abstract]) AND ("structural variant"[Title/Abstract] OR haplotype[Title/Abstract]))`
- europePmcQuery: `("long-read sequencing" OR PacBio OR "Oxford Nanopore") AND ("structural variant" OR haplotype)`

### metabolic_genetics
- id: `metabolic-genetics`
- name: `Metabolic genetics`
- keywords: `["metabolism","genetics","lipid","glucose","variant"]`
- pubmedQuery: `(metabolism[Title/Abstract] OR lipid[Title/Abstract] OR glucose[Title/Abstract]) AND (genetic*[Title/Abstract] OR variant*[Title/Abstract])`
- europePmcQuery: `(metabolism OR lipid OR glucose) AND (genetic OR genetics OR variant)`

## 验收标准
- [ ] 首次启动自动写入 3 个默认 profile
- [ ] getAllProfiles 返回所有 profile
- [ ] getProfileById 按 id 查找
- [ ] upsertProfile: id 已存在则更新，不存在则新增
- [ ] deleteProfile: 不存在的 id 不崩溃
- [ ] restoreDefaults: 删除所有自定义，恢复默认 3 个
- [ ] Preferences 写入失败不崩溃，有 console.error

## Commit
`feat(config): implement native query profile service`

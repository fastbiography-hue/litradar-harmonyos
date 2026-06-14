// models/ShareImportModel.ets — M5-T03: 分享入库模型
export interface ShareImportPayload {
  rawText: string
  doi: string
  pmid: string
  pmcid: string
  url: string
  sourceApp: string
  createdAt: number
}

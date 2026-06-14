// models/BackupModel.ets — M5-T10: 备份模型
export interface BackupManifest {
  version: string
  createdAt: number
  paperCount: number
  noteCount: number
  collectionCount: number
}

// services/CloudBackupAdapter.ets — M5-T10: 云备份适配层（接口预留）
import type { BackupManifest } from '../models/BackupModel'

export async function createBackupManifest(): Promise<BackupManifest> {
  return { version: '1.0', createdAt: Date.now(), paperCount: 0, noteCount: 0, collectionCount: 0 }
}

export async function exportBackupJson(): Promise<string> {
  return JSON.stringify({ exportedAt: Date.now(), papers: [], notes: [], collections: [] })
}

export async function importBackupJson(json: string): Promise<void> {
  try { JSON.parse(json) } catch (e) { /* invalid */ }
}

export async function isCloudBackupAvailable(): Promise<boolean> { return false }

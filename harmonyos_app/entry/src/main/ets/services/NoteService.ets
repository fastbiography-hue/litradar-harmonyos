// services/NoteService.ets — 文献笔记持久化 (Preferences)
import dataPreferences from '@ohos.data.preferences'
import common from '@ohos.app.ability.common'

const PREF_NAME = 'litradar_notes'
const KEY_PREFIX = 'note_'

export interface NoteItem {
  id: string; paperId: string; content: string; createdAt: number; updatedAt: number
}

let _prefs: dataPreferences.Preferences | null = null

export async function initNotes(context: common.Context): Promise<void> {
  _prefs = await dataPreferences.getPreferences(context, PREF_NAME)
}

async function getPrefs(): Promise<dataPreferences.Preferences> {
  if (_prefs) return _prefs
  throw new Error('NoteService not initialized')
}

function key(paperId: string): string { return KEY_PREFIX + paperId }

export async function getNotes(paperId: string): Promise<NoteItem[]> {
  try {
    const prefs = await getPrefs()
    const raw = await prefs.get(key(paperId), '') as string
    if (raw && raw !== '') return JSON.parse(raw) as NoteItem[]
  } catch (e) { console.error('[NoteService] getNotes:', (e as Error).message) }
  return []
}

export async function addNote(paperId: string, content: string): Promise<void> {
  try {
    const notes = await getNotes(paperId)
    const ts = Date.now()
    notes.push({ id: `${ts}_${notes.length}`, paperId, content, createdAt: ts, updatedAt: ts })
    const prefs = await getPrefs()
    await prefs.put(key(paperId), JSON.stringify(notes))
    await prefs.flush()
  } catch (e) { console.error('[NoteService] addNote:', (e as Error).message) }
}

export async function deleteNote(paperId: string, noteId: string): Promise<void> {
  try {
    const notes = await getNotes(paperId)
    const filtered = notes.filter((n: NoteItem) => n.id !== noteId)
    const prefs = await getPrefs()
    await prefs.put(key(paperId), JSON.stringify(filtered))
    await prefs.flush()
  } catch (e) { console.error('[NoteService] deleteNote:', (e as Error).message) }
}

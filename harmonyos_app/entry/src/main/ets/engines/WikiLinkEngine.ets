// engines/WikiLinkEngine.ets
// M3-T05: WikiLink 双向链接引擎 (纯函数)
import type { Note } from '../models/NoteModel'

const WIKILINK_RE = /\[\[([^\]]+)\]\]/g

/**
 * 从笔记内容提取所有 [[wikilinks]]
 */
export function extractWikiLinks(content: string): string[] {
  const links: string[] = []
  let match = WIKILINK_RE.exec(content)
  while (match !== null) {
    links.push(match[1])
    match = WIKILINK_RE.exec(content)
  }
  return [...new Set(links)]  // dedup
}

/**
 * 为一批笔记计算 backlinks（哪些笔记引用了给定标题）
 */
export function computeBacklinks(notes: Note[]): void {
  for (const note of notes) {
    note.backlinks = []
  }
  for (const note of notes) {
    for (const link of note.wikilinks) {
      for (const target of notes) {
        if (target.title === link || target.id === link) {
          target.backlinks.push(note.id)
        }
      }
    }
  }
}

export { WIKILINK_RE }

// models/NoteModel.ets
// M3-T05: Markdown 知识笔记模型

export interface Note {
  id: string
  title: string
  content: string
  linkedPaperIds: string[]
  wikilinks: string[]
  backlinks: string[]
  tags: string[]
  createdAt: number
  updatedAt: number
}

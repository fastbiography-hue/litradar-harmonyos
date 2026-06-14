# M3-T05: KnowledgeNotes — Markdown 知识笔记

## 目标
实现本地 Markdown 知识笔记系统，支持 Obsidian 风格 `[[双向链接]]`。

## 允许修改
- `models/NoteModel.ets`
- `services/NoteDbService.ets`
- `engines/WikiLinkEngine.ets`
- `components/NoteEditor.ets`
- `components/BacklinkPanel.ets`

## Note 字段
id, title, content, linkedPaperIds, wikilinks, backlinks, tags, createdAt, updatedAt

## 要求
- [ ] 创建/编辑/删除笔记
- [ ] 提取 wikilinks
- [ ] 显示 backlinks
- [ ] 关联 paper
- [ ] 本地 RDB 持久化

## Commit
`feat(notes): add markdown knowledge notes with wikilinks`

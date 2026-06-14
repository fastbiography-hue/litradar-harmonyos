// models/CollectionModel.ets
// M3-T06: 文献分类集合模型

export interface LiteratureCollection {
  id: string
  name: string
  parentId: string
  description: string
  paperIds: string[]
  createdAt: number
  updatedAt: number
}

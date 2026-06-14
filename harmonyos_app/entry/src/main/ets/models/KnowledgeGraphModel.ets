// models/KnowledgeGraphModel.ets
// M3-T07: 知识图谱数据模型

export enum NodeType {
  LIT = 'LitNode',
  AUTHOR = 'AuthorNode',
  JOURNAL = 'JournalNode',
  MESH = 'MeshNode',
  NOTE = 'NoteNode',
  CONCEPT = 'ConceptNode'
}

export enum RelationType {
  CITES = 'cites',
  SIMILAR_TOPIC = 'similar_topic',
  SAME_AUTHOR = 'same_author',
  SAME_JOURNAL = 'same_journal',
  USER_LINK = 'user_link',
  WIKILINK = 'wikilink',
  MESH_RELATED = 'mesh_related'
}

export interface GraphNode {
  id: string
  type: NodeType
  label: string
  x: number
  y: number
}

export interface GraphEdge {
  source: string
  target: string
  type: RelationType
}

export interface KnowledgeGraph {
  nodes: GraphNode[]
  edges: GraphEdge[]
}

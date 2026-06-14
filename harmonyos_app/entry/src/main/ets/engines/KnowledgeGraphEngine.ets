// engines/KnowledgeGraphEngine.ets
// M3-T07: 知识图谱构建引擎
import { Paper } from '../model/PaperModel'
import { KnowledgeGraph, GraphNode, GraphEdge, NodeType, RelationType } from '../models/KnowledgeGraphModel'

/**
 * Build a knowledge graph from a list of papers.
 * Nodes: papers, authors, journals, MeSH terms
 * Edges: author-of, published-in, has-mesh-term
 */
export function buildGraph(papers: Paper[]): KnowledgeGraph {
  const nodes: GraphNode[] = []
  const edges: GraphEdge[] = []
  const seenNodeIds = new Set<string>()

  function addNode(id: string, type: NodeType, label: string): void {
    if (!seenNodeIds.has(id)) {
      seenNodeIds.add(id)
      nodes.push({ id, type, label, x: Math.random() * 400, y: Math.random() * 400 })
    }
  }

  function addEdge(source: string, target: string, type: RelationType): void {
    edges.push({ source, target, type })
  }

  for (const p of papers) {
    // Paper node
    const paperId = p.id
    addNode(paperId, NodeType.LIT, p.title?.substring(0, 40) || paperId)

    // Author nodes
    const authors = (p.allAuthors || p.firstAuthor || '').split(';').map((a: string) => a.trim()).filter((a: string) => a !== '')
    for (const author of authors) {
      const authorId = `author:${author}`
      addNode(authorId, NodeType.AUTHOR, author)
      addEdge(paperId, authorId, RelationType.SAME_AUTHOR)
    }

    // Journal node
    if (p.journal) {
      const journalId = `journal:${p.journal}`
      addNode(journalId, NodeType.JOURNAL, p.journal)
      addEdge(paperId, journalId, RelationType.SAME_JOURNAL)
    }

    // MeSH term nodes
    const meshTerms = (p.meshTerms || '').split(';').map((m: string) => m.trim()).filter((m: string) => m !== '')
    for (const mesh of meshTerms) {
      const meshId = `mesh:${mesh}`
      addNode(meshId, NodeType.MESH, mesh)
      addEdge(paperId, meshId, RelationType.MESH_RELATED)
    }
  }

  return { nodes, edges }
}

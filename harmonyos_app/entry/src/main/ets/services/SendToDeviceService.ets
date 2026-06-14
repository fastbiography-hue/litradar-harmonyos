// services/SendToDeviceService.ets — M5-T06: 发送到设备服务
import type { Paper } from '../model/PaperModel'
import type { TransferPayload } from '../models/TransferPayloadModel'
import { formatCitation, CitationFormat } from '../engines/CitationExportEngine'

function uid(): string { return `${Date.now()}` }

export async function buildPaperPayload(paper: Paper): Promise<TransferPayload | undefined> {
  if (!paper) return undefined
  return { id: uid(), type: 'paper_summary', title: paper.title || '', text: paper.abstract || '', paperId: paper.id, noteId: '', createdAt: Date.now() }
}

export async function buildCitationPayload(paper: Paper, format: CitationFormat): Promise<TransferPayload | undefined> {
  if (!paper) return undefined
  const text = formatCitation(paper, format)
  return { id: uid(), type: 'citation', title: `${paper.title} (${format})`, text, paperId: paper.id, noteId: '', createdAt: Date.now() }
}

export function exportPayloadAsText(payload: TransferPayload): string {
  return `${payload.title}\n\n${payload.text}`
}

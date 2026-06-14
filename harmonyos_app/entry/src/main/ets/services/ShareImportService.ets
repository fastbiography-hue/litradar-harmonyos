// services/ShareImportService.ets
// M3-T08: 分享面板快捷入库服务（接口预留）
import { parseIdentifier, ParsedIdentifier } from '../engines/IdentifierParser'

export { parseIdentifier }
export type { ParsedIdentifier }

/**
 * Validate and parse a shared text into a usable identifier.
 * Returns null for unrecognized input.
 */
export function validateShareInput(input: string): ParsedIdentifier | null {
  if (!input || input.trim() === '') return null
  const parsed = parseIdentifier(input)
  if (parsed.type === 'unknown') return null
  return parsed
}

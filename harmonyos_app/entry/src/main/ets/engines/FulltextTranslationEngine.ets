// engines/FulltextTranslationEngine.ets
// M3-T11: 全文翻译引擎
import { translate } from './AiService'

export interface TranslationSegment {
  original: string
  translated: string
}

export interface FulltextTranslation {
  segments: TranslationSegment[]
  sourceLang: string
  targetLang: string
  error?: string
}

const MAX_SEGMENT_LENGTH = 2000

/**
 * Split text into translatable segments (split on paragraph boundaries).
 */
export function splitParagraphs(text: string): string[] {
  return text
    .split(/\n{2,}/)
    .map((s: string) => s.trim())
    .filter((s: string) => s.length > 0)
    .map((s: string) => s.length > MAX_SEGMENT_LENGTH ? s.substring(0, MAX_SEGMENT_LENGTH) : s)
}

/**
 * Translate a full article paragraph by paragraph.
 * Returns bilingual segments for side-by-side display.
 */
export async function translateFulltext(
  text: string,
  targetLang: string = 'Chinese'
): Promise<FulltextTranslation> {
  const paragraphs = splitParagraphs(text)
  const segments: TranslationSegment[] = []

  for (const para of paragraphs) {
    const translated = await translate(para, targetLang)
    if (translated.startsWith('[AiService]')) {
      return { segments, sourceLang: 'en', targetLang, error: translated }
    }
    segments.push({ original: para, translated })
  }

  return { segments, sourceLang: 'en', targetLang }
}

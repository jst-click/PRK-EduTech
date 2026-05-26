export const DEFAULT_PREVIEW_WORD_LIMIT = 12

export function truncateWords(value, maxWords = DEFAULT_PREVIEW_WORD_LIMIT) {
  if (!value) return '-'
  const normalized = String(value).trim()
  if (!normalized) return '-'

  const words = normalized.split(/\s+/)
  if (words.length <= maxWords) return normalized

  return `${words.slice(0, maxWords).join(' ')}...`
}

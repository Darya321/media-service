const SHORT_RUSSIAN_WORD = /(^|[\s(«„"—–-])([А-ЯЁа-яё]{1,2})[ \t]+(?=[А-ЯЁа-яё0-9])/gu

export function bindRussianShortWords(text) {
  return text.replace(SHORT_RUSSIAN_WORD, "$1$2\u00a0")
}

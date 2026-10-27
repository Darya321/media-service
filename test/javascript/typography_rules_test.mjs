import assert from "node:assert/strict"
import test from "node:test"

import { bindRussianShortWords } from "../../app/javascript/controllers/typography_rules.js"

test("binds short Russian words to the word that follows", () => {
  const source = "Упаковка работает на бизнес и помогает с выбором"

  assert.equal(
    bindRussianShortWords(source),
    "Упаковка работает на\u00a0бизнес и\u00a0помогает с\u00a0выбором"
  )
})

test("keeps ordinary word spacing unchanged", () => {
  const source = "Понятные материалы помогают предпринимателям"

  assert.equal(bindRussianShortWords(source), source)
})

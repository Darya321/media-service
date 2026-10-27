import { Controller } from "@hotwired/stimulus"
import { bindRussianShortWords } from "controllers/typography_rules"

const SKIP_SELECTOR = [
  "button",
  "code",
  "input",
  "noscript",
  "option",
  "pre",
  "script",
  "select",
  "style",
  "textarea",
  "[contenteditable]",
  "[data-typography='off']"
].join(",")

export default class extends Controller {
  connect() {
    const walker = document.createTreeWalker(this.element, NodeFilter.SHOW_TEXT)
    const textNodes = []

    while (walker.nextNode()) {
      const node = walker.currentNode
      const parent = node.parentElement

      if (parent && !parent.closest(SKIP_SELECTOR)) textNodes.push(node)
    }

    textNodes.forEach((node) => {
      node.nodeValue = bindRussianShortWords(node.nodeValue)
    })
  }
}

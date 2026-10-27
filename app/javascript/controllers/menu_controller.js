import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "panel"]

  connect() {
    this.close()
  }

  toggle() {
    const willOpen = this.buttonTarget.getAttribute("aria-expanded") !== "true"

    this.buttonTarget.setAttribute("aria-expanded", willOpen.toString())
    this.panelTarget.classList.toggle("is-open", willOpen)
    this.buttonTarget.querySelector(".visually-hidden").textContent = willOpen ? "Закрыть меню" : "Открыть меню"
  }

  close() {
    this.buttonTarget.setAttribute("aria-expanded", "false")
    this.panelTarget.classList.remove("is-open")
  }
}

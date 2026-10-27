import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "submit", "errors", "unitPrice", "totalPrice", "range", "disclaimer", "suppliersLink", "inquiryLink"]

  async submit(event) {
    event.preventDefault()
    this.submitTarget.disabled = true
    this.submitTarget.value = "Считаем…"
    this.clearErrors()

    try {
      const response = await fetch(this.formTarget.action, {
        method: "POST",
        headers: {
          "Accept": "application/json",
          "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
        },
        body: new FormData(this.formTarget)
      })
      const payload = await response.json()

      if (!response.ok) {
        this.showErrors(payload.errors)
        return
      }

      const quantity = Number(new FormData(this.formTarget).get("quantity"))
      this.unitPriceTarget.textContent = `${this.money(payload.unit_price)} ₽`
      this.totalPriceTarget.textContent = `за штуку • ${this.money(payload.total_price)} ₽ за ${quantity} штук`
      this.rangeTarget.textContent = `${Math.round(payload.low_price)}–${Math.round(payload.high_price)} ₽`
      this.disclaimerTarget.textContent = payload.disclaimer

      const formData = new FormData(this.formTarget)
      const query = new URLSearchParams({
        material: formData.get("material_slug"),
        region: formData.get("region")
      })
      this.suppliersLinkTarget.href = `/suppliers?${query.toString()}`

      const inquiryQuery = new URLSearchParams()
      formData.forEach((value, key) => {
        if (key !== "authenticity_token") inquiryQuery.append(key, value)
      })
      this.inquiryLinkTarget.href = `/inquiries/new?${inquiryQuery.toString()}`
    } catch (_error) {
      this.showErrors({ base: ["Не удалось выполнить расчёт. Попробуйте ещё раз."] })
    } finally {
      this.submitTarget.disabled = false
      this.submitTarget.value = "Рассчитать"
    }
  }

  money(value) {
    return new Intl.NumberFormat("ru-RU", { maximumFractionDigits: 2 }).format(value)
  }

  clearErrors() {
    this.errorsTarget.hidden = true
    this.errorsTarget.replaceChildren()
  }

  showErrors(errors = {}) {
    const list = document.createElement("ul")
    Object.values(errors).flat().forEach((message) => {
      const item = document.createElement("li")
      item.textContent = message
      list.appendChild(item)
    })
    this.errorsTarget.replaceChildren(list)
    this.errorsTarget.hidden = false
    this.errorsTarget.focus()
  }
}

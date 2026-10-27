import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["productType", "length", "width", "height", "weight", "fragile", "printOption", "material", "quantity", "region"]

  populate() {
    this.productTypeTarget.value = "Свечи в стекле"
    this.lengthTarget.value = "90"
    this.widthTarget.value = "90"
    this.heightTarget.value = "110"
    this.weightTarget.value = "0"
    this.fragileTarget.value = "false"
    this.printOptionTarget.value = "none"
    this.materialTarget.value = "microcorrugated-cardboard"
    this.quantityTarget.value = "500"
    this.regionTarget.value = "Москва"

    const calculator = document.querySelector("#home-calculator")
    calculator?.scrollIntoView({ behavior: "smooth", block: "start" })
    this.lengthTarget.focus({ preventScroll: true })
  }
}

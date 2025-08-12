import { Controller } from "@hotwired/stimulus"

// Adds up to 4 player mapping blocks for Indiepad
export default class extends Controller {
  static targets = ["template", "container", "addButton"]
  static values = { max: Number, current: Number }

  connect() {
    this.updateButton()
  }

  add() {
    if (this.currentValue >= this.maxValue) return
    const html = this.templateTarget.innerHTML.replaceAll("__INDEX__", this.currentValue)
    const frag = document.createRange().createContextualFragment(html)
    this.containerTarget.appendChild(frag)
    this.currentValue++
    this.updateButton()
  }

  updateButton() {
    if (!this.hasAddButtonTarget) return
    const disable = this.currentValue >= this.maxValue
    this.addButtonTarget.disabled = disable
    this.addButtonTarget.classList.toggle("opacity-50", disable)
    this.addButtonTarget.classList.toggle("cursor-not-allowed", disable)
  }
}

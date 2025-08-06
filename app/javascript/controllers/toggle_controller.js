import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle"
export default class extends Controller {
  static targets = []

  toggle(event) {
    event.preventDefault()

    const targetName = event.currentTarget.dataset.toggleTargetName
    if (!targetName) return

    const target = this.element.querySelector(`[data-toggle-name="${targetName}"]`)
    if (target) {
      target.classList.toggle("hidden")
    }
  }
}

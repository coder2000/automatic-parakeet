import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="language-selector"
export default class extends Controller {
  static targets = ["container"]

  selectAll() {
    const checkboxes = this.containerTarget.querySelectorAll('input[type="checkbox"]')
    checkboxes.forEach(checkbox => {
      // For the _destroy field, we want it to be "0" (not destroyed) when selected
      if (checkbox.name.includes('_destroy')) {
        checkbox.checked = true
        checkbox.value = "0"
      }
    })
  }

  selectNone() {
    const checkboxes = this.containerTarget.querySelectorAll('input[type="checkbox"]')
    checkboxes.forEach(checkbox => {
      // For the _destroy field, we want it to be "1" (destroyed) when not selected
      if (checkbox.name.includes('_destroy')) {
        checkbox.checked = false
        checkbox.value = "1"
      }
    })
  }
}
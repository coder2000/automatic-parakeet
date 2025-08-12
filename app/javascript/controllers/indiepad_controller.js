import { Controller } from "@hotwired/stimulus"

// Controls show/hide of the indiepad config panel and the info blurb
export default class extends Controller {
  static targets = ["panel", "info"]

  toggle(event) {
    const checked = event.currentTarget.checked
    if (this.hasPanelTarget) {
      this.panelTarget.classList.toggle("hidden", !checked)
    }
  }

  toggleInfo(event) {
    event.preventDefault()
    if (this.hasInfoTarget) {
      this.infoTarget.classList.toggle("hidden")
    }
  }
}

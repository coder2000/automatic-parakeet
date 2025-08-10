import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle"
export default class extends Controller {
  toggle(event) {
    event.preventDefault()

    const targetName = event.currentTarget.dataset.toggleTargetName
    if (!targetName) return

    const target = this.element.querySelector(`[data-toggle-name="${targetName}"]`)
    if (target) {
      target.classList.toggle("hidden")
    }

    // hide/show
    const hideId = event.currentTarget.dataset.toggleHideId
    const showId = event.currentTarget.dataset.toggleShowId

    if (hideId) {
      const hideEl = document.getElementById(hideId)
      if (hideEl) hideEl.classList.add("hidden")
    }
    if (showId) {
      const showEl = document.getElementById(showId)
      if (showEl) showEl.classList.remove("hidden")
    }
  }
}

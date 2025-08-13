import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle"
export default class extends Controller {
  toggle(event) {
    event.preventDefault()

    const targetName = event.currentTarget.dataset.toggleTargetName
    if (!targetName) return

    const wrapper = this.element.querySelector(`[data-toggle-name="${targetName}"]`)
    if (!wrapper) return

    // === Lazy load Turbo Frame ===
    const wasHidden = wrapper.classList.contains("hidden")
    if (wasHidden) {
      const frame = wrapper.querySelector(`turbo-frame#${targetName}_frame`)
      if (frame && !frame.hasAttribute("src")) {
        const src = frame.dataset.src
        if (src) frame.setAttribute("src", src)
      }
    }
    // ====================================================

    // toggle visiblity
    wrapper.classList.toggle("hidden")

    // lock/unlock body scroll
    document.body.style.overflow = wrapper.classList.contains("hidden") ? "" : "hidden"

    // hide/show by id
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

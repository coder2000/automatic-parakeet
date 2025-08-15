import { Controller } from "@hotwired/stimulus"

// Reusable modal/overlay controller
export default class extends Controller {
  static targets = ["overlay", "frame"]
  static values = { name: String }

  connect() {
    this.escHandler = this.closeOnEscape.bind(this)
    document.addEventListener("keydown", this.escHandler)
  }

  disconnect() {
    document.removeEventListener("keydown", this.escHandler)
  }

  open(event) {
    event?.preventDefault()
    this.overlayTarget.classList.remove("hidden")
    this.overlayTarget.classList.add("flex")
    document.body.classList.add("overflow-hidden")
    this.loadFrame()
    this.overlayTarget.setAttribute("aria-modal", "true")
    this.overlayTarget.setAttribute("role", "dialog")
    this.overlayTarget.focus()
  }

  close() {
    this.overlayTarget.classList.add("hidden")
    this.overlayTarget.classList.remove("flex")
    document.body.classList.remove("overflow-hidden")
    this.overlayTarget.removeAttribute("aria-modal")
    this.overlayTarget.removeAttribute("role")
  }

  toggle(event) {
    event?.preventDefault()
    const isHidden = this.overlayTarget.classList.contains("hidden")
    if (isHidden) {
      this.open()
    } else {
      this.close()
    }
  }

  closeOnEscape(event) {
    if (event.key === "Escape" && !this.overlayTarget.classList.contains("hidden")) {
      this.close()
    }
  }

  loadFrame() {
    if (this.hasFrameTarget && !this.frameTarget.hasAttribute("src")) {
      const src = this.frameTarget.dataset.src
      if (src) this.frameTarget.setAttribute("src", src)
    }
  }
}

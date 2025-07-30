import { Controller } from "@hotwired/stimulus"

// Generic dialog controller for modals/overlays
export default class extends Controller {
  static targets = ["dialog"]
  static classes = ["open"]

  connect() {
    this.escHandler = this.closeOnEscape.bind(this)
    document.addEventListener("keydown", this.escHandler)
  }

  disconnect() {
    document.removeEventListener("keydown", this.escHandler)
  }

  open() {
    this.dialogTarget.classList.add(this.openClass)
    this.dialogTarget.removeAttribute("aria-hidden")
  }

  close() {
    this.dialogTarget.classList.remove(this.openClass)
    this.dialogTarget.setAttribute("aria-hidden", "true")
  }

  toggle() {
    this.dialogTarget.classList.toggle(this.openClass)
    if (this.dialogTarget.classList.contains(this.openClass)) {
      this.dialogTarget.removeAttribute("aria-hidden")
    } else {
      this.dialogTarget.setAttribute("aria-hidden", "true")
    }
  }

  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  get openClass() {
    return this.hasOpenClass ? this.openClass : "block"
  }
}

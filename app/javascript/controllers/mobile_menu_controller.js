import { Controller } from "@hotwired/stimulus"

// Mobile navigation menu controller
export default class extends Controller {
  static targets = ["menu"]

  connect() {
    // Close menu when clicking outside
    this.outsideClickHandler = this.closeOnOutsideClick.bind(this)
    document.addEventListener("click", this.outsideClickHandler)
  }

  disconnect() {
    document.removeEventListener("click", this.outsideClickHandler)
  }

  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }

  open() {
    this.menuTarget.classList.remove("hidden")
  }

  close() {
    this.menuTarget.classList.add("hidden")
  }

  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }
}

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="language-switcher"
export default class extends Controller {
  static targets = ["dropdown"]

  connect() {
    // Close dropdown when clicking outside
    this.boundCloseOnOutsideClick = this.closeOnOutsideClick.bind(this)
    document.addEventListener("click", this.boundCloseOnOutsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this.boundCloseOnOutsideClick)
  }

  toggle(event) {
    event.stopPropagation()
    this.dropdownTarget.classList.toggle("hidden")
  }

  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.dropdownTarget.classList.add("hidden")
    }
  }
}
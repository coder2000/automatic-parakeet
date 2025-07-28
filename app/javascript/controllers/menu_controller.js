import { Controller } from "@hotwired/stimulus"

// Generic menu controller for toggling dropdowns/popovers
export default class extends Controller {
  static targets = ["menu"]
  static classes = ["active"]

  connect() {
    // Optionally close menu when clicking outside
    this.outsideClickHandler = this.closeOnOutsideClick.bind(this)
    document.addEventListener("click", this.outsideClickHandler)
  }

  disconnect() {
    document.removeEventListener("click", this.outsideClickHandler)
  }

  toggle() {
    this.menuTarget.classList.toggle(this.activeClass)
  }

  open() {
    this.menuTarget.classList.add(this.activeClass)
  }

  close() {
    this.menuTarget.classList.remove(this.activeClass)
  }

  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  get activeClass() {
    return this.hasActiveClass ? this.activeClass : "hidden"
  }
}

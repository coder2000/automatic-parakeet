import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="character-counter"
export default class extends Controller {
  static targets = ["input", "counter"]
  static values = {
    minLength: Number,
    maxLength: Number,
    showMin: Boolean
  }

  connect() {
    this.updateCounter()
  }

  // Action triggered on input
  updateCounter() {
    const currentLength = this.inputTarget.value.length
    const remaining = this.maxLengthValue - currentLength
    
    let counterText = ""
    let counterClass = "text-gray-400 text-sm"

    if (this.showMinValue && currentLength < this.minLengthValue) {
      const needed = this.minLengthValue - currentLength
      counterText = `${needed} more characters needed (minimum ${this.minLengthValue})`
      counterClass = "text-yellow-400 text-sm"
    } else if (remaining < 0) {
      counterText = `${Math.abs(remaining)} characters over limit`
      counterClass = "text-red-400 text-sm font-medium"
    } else if (remaining <= 20) {
      counterText = `${remaining} characters remaining`
      counterClass = "text-orange-400 text-sm"
    } else {
      counterText = `${currentLength}/${this.maxLengthValue} characters`
      counterClass = "text-gray-400 text-sm"
    }

    this.counterTarget.textContent = counterText
    this.counterTarget.className = counterClass
  }
}

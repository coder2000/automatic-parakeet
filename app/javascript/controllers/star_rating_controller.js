import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="star-rating"
export default class extends Controller {
  static targets = ["hiddenField", "submitButton"]
  static values = { current: Number }

  connect() {
    this.updateStars(this.currentValue)
    this.updateSubmitButton()
  }

  setRating(event) {
    const rating = parseInt(event.currentTarget.dataset.rating)
    this.hiddenFieldTarget.value = rating
    this.updateStars(rating)
    this.updateSubmitButton()
    // Submit the form automatically when a star is clicked
    const form = this.element.closest('form')
    if (form) {
      form.requestSubmit()
    }
  }

  updateStars(rating) {
    const stars = this.element.querySelectorAll('.star-icon')
    stars.forEach((star, index) => {
      const button = star.closest('.star-button')
      if (index < rating) {
        star.classList.remove('text-gray-300')
        star.classList.add('text-yellow-400')
        button.classList.add('selected')
      } else {
        star.classList.remove('text-yellow-400')
        star.classList.add('text-gray-300')
        button.classList.remove('selected')
      }
    })
  }

  updateSubmitButton() {
    const rating = parseInt(this.hiddenFieldTarget.value)
    if (rating > 0) {
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.classList.remove('opacity-50', 'cursor-not-allowed')
    } else {
      this.submitButtonTarget.disabled = true
      this.submitButtonTarget.classList.add('opacity-50', 'cursor-not-allowed')
    }
  }

  // Hover effects
  hoverStar(event) {
    const rating = parseInt(event.currentTarget.dataset.rating)
    this.updateStars(rating)
  }

  leaveStar(event) {
    const currentRating = parseInt(this.hiddenFieldTarget.value) || this.currentValue
    this.updateStars(currentRating)
  }
}
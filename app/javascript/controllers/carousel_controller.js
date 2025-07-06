import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="carousel"
export default class extends Controller {
  static targets = ["slides", "dot"]
  static values = { 
    autoAdvance: { type: Boolean, default: true },
    interval: { type: Number, default: 5000 }
  }

  connect() {
    this.currentSlide = 0
    this.totalSlides = this.slidesTarget.children.length
    this.updateDots()
    
    if (this.autoAdvanceValue && this.totalSlides > 1) {
      this.startAutoAdvance()
    }
  }

  disconnect() {
    this.stopAutoAdvance()
  }

  // Action methods
  next() {
    this.stopAutoAdvance()
    this.currentSlide = (this.currentSlide + 1) % this.totalSlides
    this.updateCarousel()
    if (this.autoAdvanceValue) {
      this.startAutoAdvance()
    }
  }

  previous() {
    this.stopAutoAdvance()
    this.currentSlide = this.currentSlide === 0 ? this.totalSlides - 1 : this.currentSlide - 1
    this.updateCarousel()
    if (this.autoAdvanceValue) {
      this.startAutoAdvance()
    }
  }

  goToSlide(event) {
    this.stopAutoAdvance()
    this.currentSlide = parseInt(event.target.dataset.slide)
    this.updateCarousel()
    if (this.autoAdvanceValue) {
      this.startAutoAdvance()
    }
  }

  // Private methods
  updateCarousel() {
    const translateX = -this.currentSlide * 100
    this.slidesTarget.style.transform = `translateX(${translateX}%)`
    this.updateDots()
  }

  updateDots() {
    if (this.hasDotTarget) {
      this.dotTargets.forEach((dot, index) => {
        if (index === this.currentSlide) {
          dot.classList.remove('bg-gray-300')
          dot.classList.add('bg-blue-600')
        } else {
          dot.classList.remove('bg-blue-600')
          dot.classList.add('bg-gray-300')
        }
      })
    }
  }

  startAutoAdvance() {
    if (this.totalSlides > 1) {
      this.autoAdvanceTimer = setInterval(() => {
        this.currentSlide = (this.currentSlide + 1) % this.totalSlides
        this.updateCarousel()
      }, this.intervalValue)
    }
  }

  stopAutoAdvance() {
    if (this.autoAdvanceTimer) {
      clearInterval(this.autoAdvanceTimer)
      this.autoAdvanceTimer = null
    }
  }

  // Pause auto-advance on hover
  pauseAutoAdvance() {
    this.stopAutoAdvance()
  }

  // Resume auto-advance when not hovering
  resumeAutoAdvance() {
    if (this.autoAdvanceValue) {
      this.startAutoAdvance()
    }
  }
}
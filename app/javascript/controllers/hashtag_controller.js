import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="hashtag"
export default class extends Controller {
  static targets = ["tag"]

  connect() {
    // Add click handlers to hashtags when the controller connects
    this.element.addEventListener('click', this.handleHashtagClick.bind(this))
  }

  handleHashtagClick(event) {
    if (event.target.classList.contains('hashtag')) {
      event.preventDefault();
      const hashtag = event.target.getAttribute('data-hashtag');
      if (hashtag) {
        // Navigate to the hashtag page
        window.location.href = `/hashtags/${encodeURIComponent(hashtag)}`;
      }
    }
  }
}

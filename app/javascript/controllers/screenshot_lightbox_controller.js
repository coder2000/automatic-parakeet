import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="screenshot-lightbox"
export default class extends Controller {
  static targets = ["modal", "modalImage", "modalCaption"]

  open(event) {
    event.preventDefault();
    const imageUrl = event.currentTarget.dataset.imageUrl;
    const caption = event.currentTarget.dataset.caption || '';
    this.modalImageTarget.src = imageUrl;
    this.modalCaptionTarget.textContent = caption;
    this.modalTarget.classList.remove("hidden");
    this.modalTarget.classList.add("flex");
    document.body.classList.add("overflow-hidden");
  }

  close() {
    this.modalTarget.classList.add("hidden");
    this.modalTarget.classList.remove("flex");
    this.modalImageTarget.src = '';
    this.modalCaptionTarget.textContent = '';
    document.body.classList.remove("overflow-hidden");
  }
}

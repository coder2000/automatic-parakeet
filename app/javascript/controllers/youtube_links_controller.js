import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="youtube-links"
export default class extends Controller {
  static targets = ["container", "template"]
  static values = { linkIndex: Number }

  connect() {
    // Initialize link index from existing links
    this.updateLinkIndex()
  }

  // Action: Add a new YouTube link
  addLink() {
    const linkHtml = this.createYoutubeLinkHtml()
    this.containerTarget.insertAdjacentHTML('beforeend', linkHtml)
    this.linkIndexValue++
  }

  // Action: Remove a YouTube link
  removeLink(event) {
    const linkField = event.target.closest('.youtube-link-fields')
    linkField.remove()
  }

  // Private: Create HTML for new YouTube link
  createYoutubeLinkHtml() {
    const template = this.templateTarget
    let html = template.innerHTML
    
    // Replace INDEX_PLACEHOLDER with current index
    html = html.replace(/INDEX_PLACEHOLDER/g, this.linkIndexValue)
    
    return html
  }

  // Private: Update link index based on existing links
  updateLinkIndex() {
    const existingLinks = this.containerTarget.querySelectorAll('.youtube-link-fields')
    this.linkIndexValue = existingLinks.length
  }
}

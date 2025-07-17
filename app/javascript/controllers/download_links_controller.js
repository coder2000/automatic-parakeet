import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="download-links"
export default class extends Controller {
  static targets = ["container", "template"]
  static values = { linkIndex: Number }

  connect() {
    // Initialize link index from existing links
    this.updateLinkIndex()
  }

  // Action: Add a new download link
  addLink() {
    const linkHtml = this.createDownloadLinkHtml()
    this.containerTarget.insertAdjacentHTML('beforeend', linkHtml)
    this.linkIndexValue++
  }

  // Action: Remove a download link
  removeLink(event) {
    const linkField = event.target.closest('.download-link-fields')
    linkField.remove()
  }

  // Private: Create HTML for new download link
  createDownloadLinkHtml() {
    const template = this.templateTarget
    let html = template.innerHTML
    
    // Replace INDEX_PLACEHOLDER with current index
    html = html.replace(/INDEX_PLACEHOLDER/g, this.linkIndexValue)
    
    return html
  }

  // Private: Update link index based on existing links
  updateLinkIndex() {
    const existingLinks = this.containerTarget.querySelectorAll('.download-link-fields')
    this.linkIndexValue = existingLinks.length
  }
}
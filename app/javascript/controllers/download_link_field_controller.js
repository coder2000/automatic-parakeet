import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="download-link-field"
export default class extends Controller {
  static targets = ["fileSection", "urlSection", "separator"]

  connect() {
    this.toggleSections()
  }

  fileSelected(event) {
    const hasFile = event.target.files.length > 0
    this.urlSectionTarget.hidden = hasFile
    this.separatorTarget.hidden = hasFile
  }

  urlInput(event) {
    const hasUrl = event.target.value.length > 0
    this.fileSectionTarget.hidden = hasUrl
    this.separatorTarget.hidden = hasUrl
  }

  removeFile(event) {
    const fileInput = this.fileSectionTarget.querySelector("input[type=file]")
    fileInput.value = ""
    this.toggleSections()

    // Also remove the displayed filename
    const fileDisplay = event.target.closest(".flex.items-center.justify-between")
    if(fileDisplay) {
      fileDisplay.parentElement.remove()
    }
  }

  toggleSections() {
    const urlInput = this.urlSectionTarget.querySelector("input[type=url]")
    const fileInput = this.fileSectionTarget.querySelector("input[type=file]")

    const hasUrl = urlInput.value.length > 0
    const hasFile = fileInput.files.length > 0

    this.fileSectionTarget.hidden = hasUrl
    this.urlSectionTarget.hidden = hasFile
    this.separatorTarget.hidden = hasUrl || hasFile
  }
}


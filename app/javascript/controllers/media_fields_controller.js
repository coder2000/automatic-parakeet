import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="media-fields"
export default class extends Controller {
  static targets = ["container", "template"]
  static values = { mediaIndex: Number }

  connect() {
    // Initialize media index from existing fields
    this.updateMediaIndex()
  }

  // Action: Add a new media field
  addField(event) {
    const mediaType = event.params.mediaType
    
    if (!this.canAddMedia(mediaType)) {
      return
    }

    const fieldHtml = this.createMediaFieldHtml(mediaType)
    this.containerTarget.insertAdjacentHTML('beforeend', fieldHtml)
    
    this.mediaIndexValue++
    this.updateCounters(mediaType)
  }

  // Action: Remove a media field
  removeField(event) {
    const mediaField = event.target.closest('.media-field')
    const destroyField = mediaField.querySelector('.destroy-field')
    const mediaType = this.getMediaTypeFromField(mediaField)
    
    if (destroyField) {
      // Mark for destruction instead of removing (existing records)
      destroyField.value = 'true'
      mediaField.style.display = 'none'
    } else {
      // Remove new field completely
      mediaField.remove()
    }
    
    this.updateCounters(mediaType)
    this.notifyDragDropControllers()
  }

  // Private: Check if we can add more media of this type
  canAddMedia(mediaType) {
    const currentCount = this.getCurrentCount(mediaType)
    const maxCount = mediaType === 'screenshot' ? 6 : 3
    
    if (currentCount >= maxCount) {
      alert(`Maximum ${maxCount} ${mediaType}s allowed`)
      return false
    }
    
    return true
  }

  // Private: Get current count of media type
  getCurrentCount(mediaType) {
    const visibleFields = this.containerTarget.querySelectorAll(
      `.media-field:not([style*="display: none"]) input[name*="[media_type]"][value="${mediaType}"]`
    )
    return visibleFields.length
  }

  // Private: Create HTML for new media field
  createMediaFieldHtml(mediaType) {
    const template = this.templateTarget
    let html = template.innerHTML
    
    // Replace placeholders
    html = html.replace(/MEDIA_INDEX_PLACEHOLDER/g, this.mediaIndexValue)
    html = html.replace(/MEDIA_TYPE_PLACEHOLDER/g, mediaType)
    html = html.replace(/MEDIA_TYPE_LABEL_PLACEHOLDER/g, mediaType.charAt(0).toUpperCase() + mediaType.slice(1))
    
    // Set correct file input attributes
    if (mediaType === 'screenshot') {
      html = html.replace(/ACCEPT_PLACEHOLDER/g, 'image/jpeg,image/jpg,image/png,image/gif,image/webp')
      html = html.replace(/FILE_CLASS_PLACEHOLDER/g, 'block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-medium file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500')
    } else {
      html = html.replace(/ACCEPT_PLACEHOLDER/g, 'video/mp4,video/webm,video/ogg,video/avi,video/mov')
      html = html.replace(/FILE_CLASS_PLACEHOLDER/g, 'block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-medium file:bg-purple-50 file:text-purple-700 hover:file:bg-purple-100 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500')
    }
    
    return html
  }

  // Private: Get media type from field element
  getMediaTypeFromField(field) {
    const mediaTypeInput = field.querySelector('input[name*="[media_type]"]')
    return mediaTypeInput?.value || ''
  }

  // Private: Update media index based on existing fields
  updateMediaIndex() {
    const existingFields = this.containerTarget.querySelectorAll('.media-field')
    this.mediaIndexValue = existingFields.length
  }

  // Private: Update counters in drag-drop controllers
  updateCounters(mediaType) {
    // Dispatch custom event to notify other controllers
    this.dispatch('mediaCountChanged', { 
      detail: { 
        mediaType: mediaType,
        count: this.getCurrentCount(mediaType)
      }
    })
  }

  // Private: Notify drag-drop controllers about field removal
  notifyDragDropControllers() {
    document.querySelectorAll('[data-controller*="drag-drop-upload"]').forEach(element => {
      const controller = this.application.getControllerForElementAndIdentifier(element, 'drag-drop-upload')
      if (controller && controller.mediaFieldRemoved) {
        controller.mediaFieldRemoved()
      }
    })
  }
}
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropZone", "fileInput", "preview", "counter"]
  static values = { 
    mediaType: String,
    maxFiles: Number,
    accept: String,
    currentCount: Number
  }

  connect() {
    this.setupDropZone()
    this.updateCounter()
  }

  setupDropZone() {
    const dropZone = this.dropZoneTarget

    // Prevent default drag behaviors
    ;['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
      dropZone.addEventListener(eventName, this.preventDefaults, false)
      document.body.addEventListener(eventName, this.preventDefaults, false)
    })

    // Highlight drop zone when item is dragged over it
    ;['dragenter', 'dragover'].forEach(eventName => {
      dropZone.addEventListener(eventName, this.highlight.bind(this), false)
    })

    ;['dragleave', 'drop'].forEach(eventName => {
      dropZone.addEventListener(eventName, this.unhighlight.bind(this), false)
    })

    // Handle dropped files
    dropZone.addEventListener('drop', this.handleDrop.bind(this), false)
  }

  preventDefaults(e) {
    e.preventDefault()
    e.stopPropagation()
  }

  highlight(e) {
    this.dropZoneTarget.classList.add('drag-over')
  }

  unhighlight(e) {
    this.dropZoneTarget.classList.remove('drag-over')
  }

  handleDrop(e) {
    const dt = e.dataTransfer
    const files = dt.files

    this.handleFiles(files)
  }

  // Handle file input change (traditional file picker)
  fileInputChanged(e) {
    const files = e.target.files
    this.handleFiles(files)
  }

  handleFiles(files) {
    const fileArray = Array.from(files)
    const validFiles = this.filterValidFiles(fileArray)
    
    if (validFiles.length === 0) {
      this.showError("No valid files selected. Please check file types and sizes.")
      return
    }

    // Check if adding these files would exceed the limit
    const totalCount = this.currentCountValue + validFiles.length
    if (totalCount > this.maxFilesValue) {
      const remaining = this.maxFilesValue - this.currentCountValue
      this.showError(`Cannot add ${validFiles.length} files. Maximum ${this.maxFilesValue} ${this.mediaTypeValue}s allowed. You can add ${remaining} more.`)
      return
    }

    validFiles.forEach(file => this.addMediaField(file))
    this.updateCounter()
  }

  filterValidFiles(files) {
    const acceptedTypes = this.acceptValue.split(',')
    const maxSize = this.mediaTypeValue === 'screenshot' ? 10 * 1024 * 1024 : 100 * 1024 * 1024 // 10MB for images, 100MB for videos

    return files.filter(file => {
      // Check file type
      if (!acceptedTypes.some(type => file.type.match(type.replace('*', '.*')))) {
        this.showError(`${file.name}: Invalid file type. Accepted types: ${acceptedTypes.join(', ')}`)
        return false
      }

      // Check file size
      if (file.size > maxSize) {
        const maxSizeMB = maxSize / (1024 * 1024)
        this.showError(`${file.name}: File too large. Maximum size: ${maxSizeMB}MB`)
        return false
      }

      return true
    })
  }

  addMediaField(file) {
    const container = document.getElementById('existing-media')
    const template = document.getElementById('media-field-template')
    const clone = template.content.cloneNode(true)
    
    // Get current media index
    let mediaIndex = parseInt(document.querySelector('[data-media-index]')?.dataset.mediaIndex || '0')
    mediaIndex++
    
    // Replace placeholders with actual values
    let html = clone.querySelector('.media-field').outerHTML
    html = html.replace(/MEDIA_INDEX_PLACEHOLDER/g, mediaIndex)
    html = html.replace(/MEDIA_TYPE_PLACEHOLDER/g, this.mediaTypeValue)
    html = html.replace(/MEDIA_TYPE_LABEL_PLACEHOLDER/g, this.mediaTypeValue.charAt(0).toUpperCase() + this.mediaTypeValue.slice(1))
    
    // Set the correct file input accept attribute and classes
    if (this.mediaTypeValue === 'screenshot') {
      html = html.replace(/ACCEPT_PLACEHOLDER/g, 'image/jpeg,image/jpg,image/png,image/gif,image/webp')
      html = html.replace(/FILE_CLASS_PLACEHOLDER/g, 'block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-medium file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500')
    } else {
      html = html.replace(/ACCEPT_PLACEHOLDER/g, 'video/mp4,video/webm,video/ogg,video/avi,video/mov')
      html = html.replace(/FILE_CLASS_PLACEHOLDER/g, 'block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-medium file:bg-purple-50 file:text-purple-700 hover:file:bg-purple-100 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500')
    }
    
    container.insertAdjacentHTML('beforeend', html)
    
    // Find the newly added field and set the file
    const newField = container.lastElementChild
    const fileInput = newField.querySelector('input[type="file"]')
    
    // Create a new FileList with our file
    const dataTransfer = new DataTransfer()
    dataTransfer.items.add(file)
    fileInput.files = dataTransfer.files
    
    // Add preview
    this.addPreview(newField, file)
    
    // Update media index for next field
    document.body.dataset.mediaIndex = mediaIndex
    
    // Increment current count
    this.currentCountValue++
    
    // If this is a screenshot, add it to cover image options
    if (this.mediaTypeValue === 'screenshot') {
      this.addToCoverImageOptions(file, mediaIndex);
    }
  }

  addPreview(fieldElement, file) {
    const previewContainer = fieldElement.querySelector('.file-preview') || this.createPreviewContainer(fieldElement)
    
    if (this.mediaTypeValue === 'screenshot') {
      const img = document.createElement('img')
      img.src = URL.createObjectURL(file)
      img.className = 'w-32 h-24 object-cover rounded border border-gray-200'
      img.onload = () => URL.revokeObjectURL(img.src) // Clean up
      previewContainer.appendChild(img)
    } else {
      const video = document.createElement('video')
      video.src = URL.createObjectURL(file)
      video.className = 'w-32 h-24 object-cover rounded border border-gray-200'
      video.controls = true
      video.preload = 'metadata'
      video.onload = () => URL.revokeObjectURL(video.src) // Clean up
      previewContainer.appendChild(video)
    }
  }

  createPreviewContainer(fieldElement) {
    const container = document.createElement('div')
    container.className = 'file-preview mt-3'
    
    const label = document.createElement('p')
    label.className = 'text-sm text-gray-600 mb-2'
    label.textContent = 'Preview:'
    container.appendChild(label)
    
    // Insert after the file input
    const fileInputContainer = fieldElement.querySelector('input[type="file"]').closest('div')
    fileInputContainer.parentNode.insertBefore(container, fileInputContainer.nextSibling)
    
    return container
  }

  updateCounter() {
    if (this.hasCounterTarget) {
      const remaining = this.maxFilesValue - this.currentCountValue
      this.counterTarget.textContent = `${remaining} remaining`
      
      if (remaining <= 0) {
        this.counterTarget.classList.add('text-red-600')
        this.counterTarget.classList.remove('text-gray-500')
      } else {
        this.counterTarget.classList.add('text-gray-500')
        this.counterTarget.classList.remove('text-red-600')
      }
    }
  }

  showError(message) {
    // Create or update error message
    let errorDiv = this.dropZoneTarget.querySelector('.upload-error')
    if (!errorDiv) {
      errorDiv = document.createElement('div')
      errorDiv.className = 'upload-error mt-2 p-2 bg-red-50 border border-red-200 rounded text-red-700 text-sm'
      this.dropZoneTarget.appendChild(errorDiv)
    }
    
    errorDiv.textContent = message
    
    // Auto-hide after 5 seconds
    setTimeout(() => {
      if (errorDiv.parentNode) {
        errorDiv.remove()
      }
    }, 5000)
  }

  // Called when media field is removed
  mediaFieldRemoved() {
    this.currentCountValue = Math.max(0, this.currentCountValue - 1)
    this.updateCounter()
  }

  // Update current count when controller connects (for existing media)
  updateCurrentCount() {
    const existingFields = document.querySelectorAll(`#existing-media .media-field input[name*="[media_type]"][value="${this.mediaTypeValue}"]`)
    this.currentCountValue = existingFields.length
    this.updateCounter()
  }

  // Override connect to update count on load
  connect() {
    this.setupDropZone()
    this.updateCurrentCount()
  }

  addToCoverImageOptions(file, mediaIndex) {
    const tempId = `temp_${mediaIndex}`;

    const coverImageController = this.getCoverImageController();
    if (coverImageController) {
      coverImageController.addScreenshot(file, tempId);
    }
  }

  // Private: Get the cover image controller instance
  getCoverImageController() {
    const coverImageElement = document.querySelector('[data-controller*="cover-image"]')
    if (coverImageElement) {
      return this.application.getControllerForElementAndIdentifier(coverImageElement, 'cover-image')
    }
    return null
  }

  // Listen for media count changes from media-fields controller
  mediaCountChanged(event) {
    const { mediaType, count } = event.detail
    if (mediaType === this.mediaTypeValue) {
      this.currentCountValue = count
      this.updateCounter()
    }
  }
}
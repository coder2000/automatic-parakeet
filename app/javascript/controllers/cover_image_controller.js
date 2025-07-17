import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="cover-image"
export default class extends Controller {
  static targets = ["option", "hiddenField", "clearButton", "noScreenshotsMessage"]
  static values = { selectedId: String }

  connect() {
    this.updateDisplay()
  }

  // Action: Select a cover image
  select(event) {
    const option = event.currentTarget
    const screenshotId = option.dataset.screenshotId
    
    this.selectedIdValue = screenshotId
    this.hiddenFieldTarget.value = screenshotId
    this.updateDisplay()
  }

  // Action: Clear cover image selection
  clear() {
    this.selectedIdValue = ""
    this.hiddenFieldTarget.value = ""
    this.updateDisplay()
  }

  // Add a new cover image option dynamically
  addOption(screenshotId, previewUrl, title) {
    // Hide no screenshots message if visible
    if (this.hasNoScreenshotsMessageTarget) {
      this.noScreenshotsMessageTarget.classList.add('hidden')
    }

    // Create new option element
    const optionHtml = this.createOptionHtml(screenshotId, previewUrl, title)
    this.element.querySelector('#cover-image-options').insertAdjacentHTML('beforeend', optionHtml)

    // Auto-select if it's the first screenshot and no cover image is selected
    const existingOptions = this.optionTargets.length
    if (existingOptions === 1 && !this.selectedIdValue) {
      this.selectedIdValue = screenshotId
      this.hiddenFieldTarget.value = screenshotId
      this.updateDisplay()
    }
  }

  // Private: Update visual display based on selected ID
  updateDisplay() {
    this.optionTargets.forEach(option => {
      const screenshotId = option.dataset.screenshotId
      const isSelected = screenshotId === this.selectedIdValue
      
      this.updateOptionAppearance(option, isSelected)
    })

    // Show/hide clear button
    if (this.hasClearButtonTarget) {
      this.clearButtonTarget.classList.toggle('hidden', !this.selectedIdValue)
    }
  }

  // Private: Update individual option appearance
  updateOptionAppearance(option, isSelected) {
    const indicator = option.querySelector('.cover-selected-indicator')
    
    if (isSelected) {
      option.classList.remove('border-gray-200')
      option.classList.add('border-blue-500', 'ring-2', 'ring-blue-200')
      indicator?.classList.remove('opacity-0')
      indicator?.classList.add('opacity-100')
    } else {
      option.classList.remove('border-blue-500', 'ring-2', 'ring-blue-200')
      option.classList.add('border-gray-200')
      indicator?.classList.remove('opacity-100')
      indicator?.classList.add('opacity-0')
    }
  }

  // Private: Create HTML for new option
  createOptionHtml(screenshotId, previewUrl, title) {
    return `
      <div class="cover-option relative cursor-pointer border-2 border-gray-200 hover:border-blue-300 rounded-lg overflow-hidden transition-all duration-200"
           data-cover-image-target="option"
           data-screenshot-id="${screenshotId}"
           data-action="click->cover-image#select">
        <img src="${previewUrl}" class="w-full h-24 object-cover" alt="${title}">
        
        <div class="absolute inset-0 bg-black bg-opacity-0 hover:bg-opacity-20 transition-all duration-200 flex items-center justify-center">
          <div class="cover-selected-indicator opacity-0 transition-opacity duration-200">
            <div class="bg-blue-500 text-white rounded-full p-1">
              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
              </svg>
            </div>
          </div>
        </div>
        
        <div class="absolute bottom-1 left-1 right-1">
          <div class="bg-black bg-opacity-50 text-white text-xs px-2 py-1 rounded text-center truncate">
            ${title}
          </div>
        </div>
      </div>
    `
  }
}
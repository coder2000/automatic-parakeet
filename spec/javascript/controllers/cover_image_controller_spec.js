import { Application } from "@hotwired/stimulus"
import CoverImageController from "../../../app/javascript/controllers/cover_image_controller"

describe("CoverImageController", () => {
  let application
  let controller
  let element

  beforeEach(() => {
    application = Application.start()
    application.register("cover-image", CoverImageController)

    document.body.innerHTML = `
      <div data-controller="cover-image" data-cover-image-selected-id-value="123">
        <div id="cover-image-options">
          <div class="cover-option" 
               data-cover-image-target="option"
               data-screenshot-id="123">
            <img src="test1.jpg" alt="Screenshot 1">
            <div class="cover-selected-indicator"></div>
          </div>
          <div class="cover-option" 
               data-cover-image-target="option"
               data-screenshot-id="456">
            <img src="test2.jpg" alt="Screenshot 2">
            <div class="cover-selected-indicator"></div>
          </div>
        </div>
        
        <input type="hidden" 
               data-cover-image-target="hiddenField" 
               value="123">
        
        <div data-cover-image-target="clearButton">
          <button data-action="click->cover-image#clear">Clear</button>
        </div>
        
        <div data-cover-image-target="noScreenshotsMessage" class="hidden">
          No screenshots message
        </div>
      </div>
    `

    element = document.querySelector('[data-controller="cover-image"]')
    controller = application.getControllerForElementAndIdentifier(element, "cover-image")
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ""
  })

  describe("initialization", () => {
    it("connects successfully", () => {
      expect(controller).toBeDefined()
      expect(controller.selectedIdValue).toBe("123")
    })

    it("updates display on connect", () => {
      const selectedOption = controller.optionTargets.find(
        option => option.dataset.screenshotId === "123"
      )
      
      expect(selectedOption.classList.contains("border-blue-500")).toBe(true)
    })
  })

  describe("cover image selection", () => {
    it("selects a cover image option", () => {
      const option = controller.optionTargets.find(
        opt => opt.dataset.screenshotId === "456"
      )
      
      const event = { currentTarget: option }
      controller.select(event)
      
      expect(controller.selectedIdValue).toBe("456")
      expect(controller.hiddenFieldTarget.value).toBe("456")
      expect(option.classList.contains("border-blue-500")).toBe(true)
    })

    it("deselects previously selected option", () => {
      const option1 = controller.optionTargets.find(
        opt => opt.dataset.screenshotId === "123"
      )
      const option2 = controller.optionTargets.find(
        opt => opt.dataset.screenshotId === "456"
      )
      
      // Select option2
      const event = { currentTarget: option2 }
      controller.select(event)
      
      // Option1 should be deselected
      expect(option1.classList.contains("border-blue-500")).toBe(false)
      expect(option2.classList.contains("border-blue-500")).toBe(true)
    })

    it("shows clear button when option is selected", () => {
      const option = controller.optionTargets[0]
      const event = { currentTarget: option }
      controller.select(event)
      
      expect(controller.clearButtonTarget.classList.contains("hidden")).toBe(false)
    })
  })

  describe("clearing selection", () => {
    it("clears the selected cover image", () => {
      controller.clear()
      
      expect(controller.selectedIdValue).toBe("")
      expect(controller.hiddenFieldTarget.value).toBe("")
    })

    it("removes visual selection from all options", () => {
      controller.clear()
      
      controller.optionTargets.forEach(option => {
        expect(option.classList.contains("border-blue-500")).toBe(false)
      })
    })

    it("hides clear button", () => {
      controller.clear()
      
      expect(controller.clearButtonTarget.classList.contains("hidden")).toBe(true)
    })
  })

  describe("adding new options", () => {
    it("adds a new cover image option", () => {
      const initialCount = controller.optionTargets.length
      
      controller.addOption("789", "test3.jpg", "New Screenshot")
      
      // Note: In a real test, we'd need to trigger Stimulus to re-scan for targets
      const newOption = document.querySelector('[data-screenshot-id="789"]')
      expect(newOption).toBeDefined()
      expect(newOption.querySelector("img").src).toContain("test3.jpg")
    })

    it("hides no screenshots message when adding first option", () => {
      controller.noScreenshotsMessageTarget.classList.remove("hidden")
      
      controller.addOption("789", "test3.jpg", "New Screenshot")
      
      expect(controller.noScreenshotsMessageTarget.classList.contains("hidden")).toBe(true)
    })

    it("auto-selects first option when none selected", () => {
      controller.selectedIdValue = ""
      
      // Remove existing options to simulate empty state
      controller.optionTargets.forEach(option => option.remove())
      
      controller.addOption("789", "test3.jpg", "New Screenshot")
      
      expect(controller.selectedIdValue).toBe("789")
    })
  })

  describe("visual feedback", () => {
    it("updates option appearance correctly", () => {
      const option = controller.optionTargets[0]
      
      controller.updateOptionAppearance(option, true)
      
      expect(option.classList.contains("border-blue-500")).toBe(true)
      expect(option.classList.contains("ring-2")).toBe(true)
      expect(option.classList.contains("ring-blue-200")).toBe(true)
      
      const indicator = option.querySelector(".cover-selected-indicator")
      expect(indicator.classList.contains("opacity-100")).toBe(true)
    })

    it("removes selection styling", () => {
      const option = controller.optionTargets[0]
      option.classList.add("border-blue-500", "ring-2", "ring-blue-200")
      
      controller.updateOptionAppearance(option, false)
      
      expect(option.classList.contains("border-blue-500")).toBe(false)
      expect(option.classList.contains("border-gray-200")).toBe(true)
    })
  })

  describe("HTML generation", () => {
    it("creates proper HTML for new options", () => {
      const html = controller.createOptionHtml("test-id", "test.jpg", "Test Title")
      
      expect(html).toContain('data-screenshot-id="test-id"')
      expect(html).toContain('src="test.jpg"')
      expect(html).toContain("Test Title")
      expect(html).toContain("cover-selected-indicator")
    })
  })
})
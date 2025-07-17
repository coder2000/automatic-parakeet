import { Application } from "@hotwired/stimulus"
import DragDropUploadController from "../../../app/javascript/controllers/drag_drop_upload_controller"

describe("DragDropUploadController", () => {
  let application
  let controller
  let element

  beforeEach(() => {
    application = Application.start()
    application.register("drag-drop-upload", DragDropUploadController)

    document.body.innerHTML = `
      <div data-controller="drag-drop-upload"
           data-drag-drop-upload-media-type-value="screenshot"
           data-drag-drop-upload-max-files-value="6"
           data-drag-drop-upload-accept-value="image/jpeg,image/jpg,image/png,image/gif,image/webp"
           data-drag-drop-upload-current-count-value="0">
        
        <div data-drag-drop-upload-target="dropZone" class="border-2 border-dashed">
          <input type="file" 
                 data-drag-drop-upload-target="fileInput"
                 data-action="change->drag-drop-upload#fileInputChanged"
                 multiple>
        </div>
        
        <span data-drag-drop-upload-target="counter"></span>
      </div>
    `

    element = document.querySelector('[data-controller="drag-drop-upload"]')
    controller = application.getControllerForElementAndIdentifier(element, "drag-drop-upload")
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ""
  })

  describe("initialization", () => {
    it("connects successfully", () => {
      expect(controller).toBeDefined()
      expect(controller.mediaTypeValue).toBe("screenshot")
      expect(controller.maxFilesValue).toBe(6)
      expect(controller.currentCountValue).toBe(0)
    })

    it("sets up drop zone event listeners", () => {
      const dropZone = controller.dropZoneTarget
      expect(dropZone).toBeDefined()
      expect(dropZone.classList.contains("border-dashed")).toBe(true)
    })

    it("updates counter on connect", () => {
      const counter = controller.counterTarget
      expect(counter.textContent).toContain("remaining")
    })
  })

  describe("file validation", () => {
    it("accepts valid image files for screenshots", () => {
      const validFile = new File(["test"], "test.jpg", { type: "image/jpeg" })
      const validFiles = controller.filterValidFiles([validFile])
      
      expect(validFiles).toHaveLength(1)
      expect(validFiles[0]).toBe(validFile)
    })

    it("rejects invalid file types", () => {
      const invalidFile = new File(["test"], "test.txt", { type: "text/plain" })
      const validFiles = controller.filterValidFiles([invalidFile])
      
      expect(validFiles).toHaveLength(0)
    })

    it("rejects oversized files", () => {
      // Mock a large file
      const largeFile = new File(["x".repeat(11 * 1024 * 1024)], "large.jpg", { type: "image/jpeg" })
      Object.defineProperty(largeFile, 'size', { value: 11 * 1024 * 1024 })
      
      const validFiles = controller.filterValidFiles([largeFile])
      expect(validFiles).toHaveLength(0)
    })
  })

  describe("file count limits", () => {
    it("prevents adding files when at limit", () => {
      controller.currentCountValue = 6
      
      const file = new File(["test"], "test.jpg", { type: "image/jpeg" })
      const spy = jest.spyOn(controller, 'showError')
      
      controller.handleFiles([file])
      
      expect(spy).toHaveBeenCalledWith(expect.stringContaining("Maximum 6"))
    })

    it("allows adding files when under limit", () => {
      controller.currentCountValue = 3
      
      const file = new File(["test"], "test.jpg", { type: "image/jpeg" })
      const spy = jest.spyOn(controller, 'addMediaField')
      
      controller.handleFiles([file])
      
      expect(spy).toHaveBeenCalledWith(file)
    })
  })

  describe("drag and drop events", () => {
    let dropZone

    beforeEach(() => {
      dropZone = controller.dropZoneTarget
    })

    it("highlights drop zone on dragover", () => {
      const event = new DragEvent("dragover")
      dropZone.dispatchEvent(event)
      
      expect(dropZone.classList.contains("drag-over")).toBe(true)
    })

    it("removes highlight on dragleave", () => {
      dropZone.classList.add("drag-over")
      
      const event = new DragEvent("dragleave")
      dropZone.dispatchEvent(event)
      
      expect(dropZone.classList.contains("drag-over")).toBe(false)
    })

    it("handles file drop", () => {
      const file = new File(["test"], "test.jpg", { type: "image/jpeg" })
      const dataTransfer = new DataTransfer()
      dataTransfer.items.add(file)
      
      const event = new DragEvent("drop", { dataTransfer })
      const spy = jest.spyOn(controller, 'handleFiles')
      
      dropZone.dispatchEvent(event)
      
      expect(spy).toHaveBeenCalled()
    })
  })

  describe("counter updates", () => {
    it("updates counter text", () => {
      controller.currentCountValue = 2
      controller.updateCounter()
      
      const counter = controller.counterTarget
      expect(counter.textContent).toBe("4 remaining")
    })

    it("changes counter color when at limit", () => {
      controller.currentCountValue = 6
      controller.updateCounter()
      
      const counter = controller.counterTarget
      expect(counter.classList.contains("text-red-600")).toBe(true)
    })
  })

  describe("error handling", () => {
    it("displays error messages", () => {
      controller.showError("Test error message")
      
      const errorDiv = controller.dropZoneTarget.querySelector(".upload-error")
      expect(errorDiv).toBeDefined()
      expect(errorDiv.textContent).toBe("Test error message")
    })

    it("auto-hides error messages", (done) => {
      controller.showError("Test error")
      
      setTimeout(() => {
        const errorDiv = controller.dropZoneTarget.querySelector(".upload-error")
        expect(errorDiv).toBeNull()
        done()
      }, 5100)
    })
  })

  describe("cover image integration", () => {
    it("adds screenshots to cover image options", () => {
      const mockCoverController = {
        addOption: jest.fn()
      }
      
      jest.spyOn(controller, 'getCoverImageController').mockReturnValue(mockCoverController)
      
      const file = new File(["test"], "test.jpg", { type: "image/jpeg" })
      controller.addToCoverImageOptions(file, 0)
      
      expect(mockCoverController.addOption).toHaveBeenCalledWith(
        "temp_0",
        expect.any(String),
        "Screenshot 1"
      )
    })
  })
})
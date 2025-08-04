import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="comments"
export default class extends Controller {
  static targets = ["replyForm", "editForm"]

  connect() {
    // Add click event listeners to all spoiler elements within this controller's scope
    this.element.addEventListener('click', this.handleSpoilerClick.bind(this))
  }

  toggleReplyForm(event) {
    event.preventDefault()
    const commentId = event.currentTarget.dataset.commentId
    const replyForm = document.getElementById(`reply_form_${commentId}`)

    if (replyForm) {
      // Hide all other reply forms
      this.hideAllReplyForms()
      // Toggle this reply form
      replyForm.classList.toggle("hidden")
      if (!replyForm.classList.contains("hidden")) {
        const textarea = replyForm.querySelector("textarea")
        if (textarea) textarea.focus()
      }
    }
  }

  hideReplyForm(event) {
    event.preventDefault()
    const commentId = event.currentTarget.dataset.commentId
    const replyForm = document.getElementById(`reply_form_${commentId}`)

    if (replyForm) {
      replyForm.classList.add("hidden")
      // Clear the textarea
      const textarea = replyForm.querySelector("textarea")
      if (textarea) textarea.value = ""
    }
  }

  toggleEditForm(event) {
    event.preventDefault()
    const commentId = event.currentTarget.dataset.commentId
    const editForm = document.getElementById(`edit_form_${commentId}`)

    if (editForm) {
      // Hide all other edit forms
      this.hideAllEditForms()
      // Toggle this edit form
      editForm.classList.toggle("hidden")
      if (!editForm.classList.contains("hidden")) {
        const textarea = editForm.querySelector("textarea")
        if (textarea) textarea.focus()
      }
    }
  }

  hideEditForm(event) {
    event.preventDefault()
    const commentId = event.currentTarget.dataset.commentId
    const editForm = document.getElementById(`edit_form_${commentId}`)

    if (editForm) {
      editForm.classList.add("hidden")
    }
  }

  hideAllReplyForms() {
    const replyForms = document.querySelectorAll('[id^="reply_form_"]')
    replyForms.forEach(form => {
      form.classList.add("hidden")
      const textarea = form.querySelector("textarea")
      if (textarea) textarea.value = ""
    })
  }

  hideAllEditForms() {
    const editForms = document.querySelectorAll('[id^="edit_form_"]')
    editForms.forEach(form => {
      form.classList.add("hidden")
    })
  }

  handleSpoilerClick(event) {
    // Check if the clicked element or its parent is a spoiler
    const spoilerElement = event.target.closest('.spoiler')
    
    if (spoilerElement && !spoilerElement.classList.contains('revealed')) {
      event.preventDefault()
      event.stopPropagation()
      
      // Reveal the spoiler by adding the 'revealed' class
      spoilerElement.classList.add('revealed')
      
      // Remove the click-to-reveal tooltip
      spoilerElement.removeAttribute('title')
      
      // Add a visual indicator that it's been revealed
      spoilerElement.title = 'Spoiler revealed'
    }
  }
}

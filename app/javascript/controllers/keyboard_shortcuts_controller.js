import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "typeSelect"]

  connect() {
    this.handleKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.handleKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown)
  }

  handleKeydown(event) {
    // Don't trigger shortcuts when typing in inputs
    if (event.target.tagName === "INPUT" || event.target.tagName === "TEXTAREA" || event.target.tagName === "SELECT") {
      return
    }

    switch (event.key) {
      case "n":
        event.preventDefault()
        this.focusInput()
        break
      case "t":
        event.preventDefault()
        this.setType("task")
        break
      case "e":
        event.preventDefault()
        this.setType("event")
        break
    }
  }

  focusInput() {
    if (this.hasInputTarget) {
      this.inputTarget.focus()
    }
  }

  setType(type) {
    if (this.hasTypeSelectTarget) {
      this.typeSelectTarget.value = type
      this.focusInput()
    }
  }
}

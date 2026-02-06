import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "typeSelect", "bodyWrapper", "bodyInput"]

  refocus() {
    requestAnimationFrame(() => {
      const input = this.hasInputTarget ? this.inputTarget : this.element.querySelector("input[name='text']")
      if (input) {
        input.value = ""
        input.focus()
      }
      if (this.hasBodyInputTarget) {
        this.bodyInputTarget.value = ""
      }
    })
  }

  typeChanged() {
    if (!this.hasBodyWrapperTarget) return

    const isSnippet = this.typeSelectTarget.value === "snippet"
    this.bodyWrapperTarget.classList.toggle("hidden", !isSnippet)
  }
}

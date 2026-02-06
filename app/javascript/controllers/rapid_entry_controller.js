import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "typeSelect"]

  refocus() {
    requestAnimationFrame(() => {
      const input = this.hasInputTarget ? this.inputTarget : this.element.querySelector("input[name='text']")
      if (input) {
        input.value = ""
        input.focus()
      }
    })
  }
}

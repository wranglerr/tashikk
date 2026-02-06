import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  delete() {
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content

    fetch(this.urlValue, {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": csrfToken,
        "Accept": "text/vnd.turbo-stream.html"
      }
    })
    .then(response => response.text())
    .then(html => {
      Turbo.renderStreamMessage(html)
    })
  }
}

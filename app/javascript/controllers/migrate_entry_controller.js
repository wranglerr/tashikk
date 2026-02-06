import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  migrate() {
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content

    fetch(this.urlValue, {
      method: "POST",
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

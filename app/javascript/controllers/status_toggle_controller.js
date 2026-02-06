import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String, status: String }

  toggle() {
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content

    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "X-CSRF-Token": csrfToken,
        "Accept": "text/vnd.turbo-stream.html"
      },
      body: `status=${this.statusValue}`
    })
    .then(response => response.text())
    .then(html => {
      Turbo.renderStreamMessage(html)
    })
  }
}

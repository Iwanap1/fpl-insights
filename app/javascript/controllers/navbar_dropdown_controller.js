import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="navbar-dropdown"
export default class extends Controller {
  static targets = ["menu"]

  connect() {
    console.log("Hello from navbar dropdown stimulus")

    console.log(this.menuTarget)
  }

  toggle() {
    console.log("Clicked")

    // Remove BS style class
    this.menuTarget.classList.remove("show")

    // Use our own JS to add/remove class
    this.menuTarget.classList.toggle("show-menu")
  }
}

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="slider"1
export default class extends Controller {
  static targets = ["output"];

  connect() {
    this.outputTarget.innerHTML = this.sliderValue;
  }

  sliderValueChanged() {
    this.outputTarget.innerHTML = this.sliderValue;
    this.updateSearchParams();
    this.sendAjaxRequest();
  }

  get sliderValue() {
    return this.element.querySelector(".slider").value;
  }

  updateSearchParams() {
    const url = new URL(window.location);
    url.searchParams.set('sliderValue', this.sliderValue);
    window.history.pushState({}, '', url);
  }

  sendAjaxRequest() {
    fetch("/players", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        // Include other headers if needed (e.g., for authentication)
      },
      body: JSON.stringify({ "sliderValue": this.sliderValue }),
    })
    .then(response => response.json())
    .then(data => {
      console.log(data);
      // Handle the server response here, if needed
    })
    .catch(error => console.error("Error:", error));
  }
}

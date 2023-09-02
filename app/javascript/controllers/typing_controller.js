import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="typing"
export default class extends Controller {
  static targets = ["display"];

  connect() {
    this.textToType = "Hello, manager! Ready to conquer the FPL leaderboard? I'm FPLBOT, your personalized guide to success. Let's get started!";
    this.index = 0;
    document.querySelector(".blinking-cursor").style.display = "none";  // Hide cursor
    this.typeText();
}

  typeText() {
    if (this.index < this.textToType.length) {
        this.displayTarget.innerHTML += this.textToType.charAt(this.index);
        this.index++;
        setTimeout(() => this.typeText(), 50);
    } else {
      document.querySelector(".blinking-cursor").style.display = "inline-block"; // Display cursor after typing
      document.querySelector(".actions").style.opacity = "1";
      document.querySelector(".actions").style.display = "flex";

      let arrow = document.querySelector(".arrow1");
      setTimeout(() => {
          arrow.style.opacity = "1";
          arrow.style.visibility = "visible";  // Make it visible
      }, 500);
  }
  }
}

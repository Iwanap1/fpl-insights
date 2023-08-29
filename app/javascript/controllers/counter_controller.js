import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display"];

  connect() {
    this.startCount();
  }

  startCount() {
    const endValue = parseInt(this.data.get("endValue"));
    const duration = parseInt(this.data.get("durationValue")) || 1000;

    if (isNaN(endValue)) return;

    let startTime = null;

    const step = (timestamp) => {
        if (!startTime) startTime = timestamp;
        const progress = Math.min((timestamp - startTime) / duration, 1);
        this.displayTarget.textContent = Math.floor(progress * endValue).toString();
        if (progress < 1) {
            window.requestAnimationFrame(step);
        }
    };

    window.requestAnimationFrame(step);
  }
}

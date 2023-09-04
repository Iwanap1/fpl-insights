import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="fade-video"

export default class extends Controller {
  connect() {
    this.scrollHandler = this.handleScroll.bind(this);
    window.addEventListener('scroll', this.scrollHandler);
  }

  disconnect() {
    window.removeEventListener('scroll', this.scrollHandler);
  }

  handleScroll() {
    let scrollPosition = window.scrollY;
    let opacity = 1 - 3*(scrollPosition / window.innerHeight);
    this.element.style.opacity = opacity > 0 ? opacity : 0;
  }
}

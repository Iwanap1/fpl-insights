import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["card", "indicator"];
  currentCard = 0;

  connect() {
    console.log("Hello, Stimulus!");
    this.showCard(this.currentCard);
  }

  showCard(index) {
    const offset = -index * 112;  // width of one card
    this.cardTargets.forEach(card => {
      card.style.transform = `translateX(${offset}%)`;
    });

    this.indicatorTargets.forEach((indicator, i) => {
      if (i === index) {
        indicator.classList.add('active');
      } else {
        indicator.classList.remove('active');
      }
    });
  }

  goNext() {
    if (this.currentCard < this.cardTargets.length - 1) {
      this.currentCard++;
      this.showCard(this.currentCard);
    }
  }

  goPrev() {
    if (this.currentCard > 0) {
      this.currentCard--;
      this.showCard(this.currentCard);
    }
  }
}

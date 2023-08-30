import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["card", "indicator"];
  currentCard = 0;

  connect() {
    this.showCard(this.currentCard);
  }

  showCard(index) {
    const offset = -index * 1200;  // width of one card
    this.cardTargets.forEach(card => {
      card.style.transform = `translateX(${offset}px)`;
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
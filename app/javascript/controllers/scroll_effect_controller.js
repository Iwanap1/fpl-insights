import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="scroll-effect"

export default class extends Controller {
  connect() {
    console.log('Hello from scroll effect controller');
    window.addEventListener('scroll', this.checkPosition.bind(this));
  }

  disconnect() {
    window.removeEventListener('scroll', this.checkPosition);
  }

  checkPosition() {
    if ((window.innerHeight + window.scrollY) >= document.body.offsetHeight- -1300) {
      // User is at the bottom of the page
      this.triggerHoverEffect();
    }
    if ((window.innerHeight + window.scrollY) >= document.body.offsetHeight- -150) {
      // User is at the bottom of the page
      this.scroll1();
    }

    if ((window.innerHeight + window.scrollY) >= document.body.offsetHeight- -300) {
      // User is at the bottom of the page
      this.homenav();
    }

    if ((window.innerHeight + window.scrollY) >= document.body.offsetHeight- -500) {
      // User is at the bottom of the page
      this.arrow2();
    }
    if ((window.innerHeight + window.scrollY) >= document.body.offsetHeight- -700) {
      // User is at the bottom of the page
      this.scroll2();
    }

    if ((window.innerHeight + window.scrollY) >= document.body.offsetHeight- -1000) {
      // User is at the bottom of the page
      this.arrow3();
    }

    if ((window.innerHeight + window.scrollY) >= document.body.offsetHeight- -1250) {
      // User is at the bottom of the page
      this.scroll3();
    }


  }


  homenav() {
    const homenavElement = document.querySelector('.homenav');
    homenavElement.style.backgroundColor = '#38003C';
    homenavElement.style.opacity = '1';
    homenavElement.style.color = 'white';
  }

  arrow2() {
    const arrow2Element = document.querySelector('.arrow2');
    arrow2Element.style.opacity = '1';
  }

  arrow3() {
    const arrow3Element = document.querySelector('.arrow3');
    arrow3Element.style.opacity = '1';
  }


  scroll1() {
    const scroll1Element = document.querySelector('.scroll1');
    // scroll1Element.style.opacity = '1';
    // scroll1Element.style.opacity = '1';
    scroll1Element.style.transform = 'translateY(0)';
  }

  scroll2() {
    const scroll2Element = document.querySelector('.scroll2');
    // scroll2Element.style.opacity = '1';
    scroll2Element.style.transform = 'translateY(0)';
  }

  scroll3() {
    const scroll3Element = document.querySelector('.scroll3');
    scroll3Element.style.transform = 'translateY(-0)';
  }

  triggerHoverEffect() {
    // Get the elements and apply hover effect
    const loginElement = document.querySelector('.login');
    const viewPlayersElement = document.querySelector('.view-players');

    // You can use classes that represent the hover effect or directly modify the styles
    loginElement.style.width = 'auto';
    loginElement.style.paddingRight = '10px';

    const loginText = loginElement.querySelector('.login-text');
    loginText.style.opacity = '1';

    // move loginElement to the center of the page

    // loginElement.style.marginLeft = '40%';
    // loginElement.style.marginBottom = '15px';
    // viewPlayersElement.style.marginRight= '35%';
    // viewPlayersElement.style.display= 'inline';


    viewPlayersElement.style.width = '200px';
    viewPlayersElement.style.backgroundColor = '#28002b';
    loginElement.style.backgroundColor = '#28002b';

    const playersText = viewPlayersElement.querySelector('.players-text');
    playersText.style.display = 'inline';
  }
}

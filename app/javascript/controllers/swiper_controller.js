import { Controller } from "@hotwired/stimulus"
import Swiper from 'swiper';

// Connects to data-controller="swiper"
export default class extends Controller {
  connect() {
    const swiper = new Swiper('.swiper', {
      // Optional parameters
      direction: 'vertical',
      loop: true,

      // If we need pagination
      pagination: {
        el: '.swiper-pagination',
      },

      // Navigation arrows
      navigation: {
        nextEl: '.swiper-button-next',
        prevEl: '.swiper-button-prev',
      },

      // And if we need scrollbar
      scrollbar: {
        el: '.swiper-scrollbar',
      },
    });


    // const swiper = new Swiper(this.element, {

    //   // direction: 'horizontal',
    //   loop: true,
    //   autoplay: {
    //     delay: 5000,
    //   },
    //   speed: 1000,
    //   // effect: 'fade',
    //   fadeEffect: {
    //     crossFade: true
    //   },
    //   // navigation: {
    //   //   nextEl: '.swiper-button-next',
    //   //   prevEl: '.swiper-button-prev',
    //   // },
    //   // scrollbar: {
    //   //   el: '.swiper-scrollbar',
    //   // },
    // });
  }
}

(function(){
  'use strict';

  $(document).ready(init);

  function init(){
    blinker;
    $('.downArrow').click(scroll);
  }

  setInterval(blinker, 1700); //Runs every second

  function blinker() {
    $('.blink_me').fadeOut(500).fadeIn(500);
  }

  function scroll() {
    $('html, body').animate({
      scrollTop: $("#whatAreYouLookingFor").offset().top
    }, 1800);
  }

})();

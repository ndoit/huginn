(function(){
  'use strict';

  $(document).ready(init);

  function init(){
    $('.leftModalIcon').on('click', activateLeftModal);
    $('.rightModalIcon').on('click', activateRightModal);
  }

  function activateLeftModal() {
    $('.leftModal').toggleClass('leftModalOut').css({'transition':'1s ease-in-out'});
  }



  function activateRightModal() {
    $('.rightModal').toggleClass('rightModalOut').css({'transition':'1s ease-in-out'});
  }



})();

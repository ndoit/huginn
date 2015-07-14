(function(){
  'use strict';

  $(document).ready(init);

  function init(){
    $('#editmode').on('change', checkMode);
  }


  function checkMode(){
    $('#editmode').is(':checked') ? editMode() : viewMode() ;
  }

  function editMode(){
    $('#currentmode').text('View');
    $('.canEdit').addClass('editable free-text');
    $('.editable').attr({'contenteditable':'true'});
    initializetinymce(".editable");
  }

  function viewMode(){
    $('.canEdit').removeClass('editable free-text');
    $('#currentmode').text('Edit');
  }

  function initializetinymce(the_textarea_div_class) {
    tinymce.init({
      selector: "div" + the_textarea_div_class,
      relative_urls: false,
      inline: true,
      menubar: true,
      relative_urls: false,
      plugins: [
          "advlist autolink lists link image charmap print preview anchor",
          "searchreplace visualblocks code fullscreen",
          "insertdatetime media table contextmenu paste "
      ],
      toolbar: "insertfile undo redo | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image|anchor"
    });
  }

})();

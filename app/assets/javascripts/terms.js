 
$(document).ready(function(){

  if (typeof office_json != 'undefined')  {
   $('.raci_input').select2({
        data:office_json,
        multiple: true,
        width: "500px"
    });

    $('.raci_input').each( function() {
    	$(this).data().select2.updateSelection( $(this).data('init') )
    })

  }

  if(typeof term_object != 'undefined')  {

		$('#updateTermButton').click(function() {
		//alert("updating term object")
		  if (updateTermObject(term_object) == false)
			  return false;

		  updateTerm(term_object)
		})

		$('#showJSONButton').click( function() {
			$('#json_container').toggle()
		})

		$('#deleteConfirm').click( function() {
			$('a.close-reveal-modal').trigger('click')
			deleteTerm(term_object.id)
		})
		$('#deleteCancel').click( function() {
			$('a.close-reveal-modal').trigger('click')
		})

  }

   if(typeof office_detail_json != 'undefined')  {

    $('#updateOfficeButton').click(function() {
    //alert("updating term object")
      if (updateOfficeObject(office_detail_json) == false)
        return false;

      updateOffice(office_detail_json)
    })

    $('#showOfficeButton').click( function() {
      $('#json_container').toggle()
    })

    $('#deleteConfirm').click( function() {
      $('a.close-reveal-modal').trigger('click')
      deleteOffice(office_detail_json.id)
    })
    $('#deleteCancel').click( function() {
      $('a.close-reveal-modal').trigger('click')
    })

  }
  $("#search1").bind("change keyup",function() {
     console.log( $(this) )
     if ($(this).val().length >=2 ) {
       var url = 'terms/partial_search?q=' + $(this).val();
       var search_string = $(this).val();
       console.log(url)
       $('#search_results').load(encodeURI(url), function() {
          $(".do_highlight").highlight(search_string);
       });
     }
  })

  $('#createTermButton').click(function() {
	var term = $('#tname').val();
	term_new = {
     "name": term,
     "definition": "",
     "source_system": "",
     "data_sensitivity": "",
     "possible_values": "",
     "data_availability": "",
     "notes": ""};
    $('a.close-reveal-modal').trigger('click');
    createTerm(term_new);
  })

$('#addOfficeButton').click(function() {
  clearValidationErrors()
  var office = $('#oname').val();
  office_new = {"name": office};
    $('a.close-reveal-modal').trigger('click');
    addOffice(office_new);
  })
})


function clearValidationErrors() {
 $('.alert-box').each( function() {
 		$(this).find('.error_list').html('');
 		$(this).find('.success_msg').html('');
 		$(this).hide()
 })
}

function addValidationError( type, message ) {
  error_list = $('.alert-box.' + type ).find('ul.error_list')
  error_list.append( '<li>' + message + '</li>')
}

 function showValidationErrors() {
 	errors_exist = false
 	$('.alert-box').each( function() {
 		if ( $(this).find('li').length != 0 ){ 
 			type = $(this).find('alert','warning')
 		   $('.alert-box.' + type.selector).show().html_safe;
 		   errors_exist = true
 		}
 	})
 	if ( errors_exist ) {
 		window.scrollTo(0,0)
 	}
 	return errors_exist
 }

 function addSuccessMessage(type, message ) {
  $('.alert-box.' + type ).find('span.success_msg').append(message);
 }
  function showSuccessMessage() {
 	success_exist = false
 	$('.alert-box').each( function() {
 		if ( $(this).find('span').html){ 
 			 type = $(this).find('success')
 		   $('.alert-box.' + type.selector).show().html_safe;
 		   success_exist = true
 		}
 	})
 	if ( success_exist) {
 		window.scrollTo(0,0)
 	}
 	return success_exist
 }

function updateTermObject(term_object ) {
	clearValidationErrors()
	tinymce.triggerSave();
  console.log(term_object);
	$('.editable').each( function() {
		id = $(this).attr('id');
		if ( id ) {
			p = tinymce.get(id).getContent()
			if (id == "name") {
				var StrippedString = p.replace(/(<([^>]+)>)/ig,"");
				p = StrippedString;

			}
			console.log(p);
			console.log(id);
			term_object[id] = p;
		}

	});

	term_object["stakeholders"] = []
	var office_array=[]

	var i = 0;
	var exitRACI = false;
	var dupRACI = false;
	var office_text =null;
	$('.raci_row').each( function() {
		stake = $(this).data('raci-stake')
		console.log("stake value is " + stake);
		json_array = $('#raci' + i ).select2('data')	
    if (stake == "Responsible" && json_array.length >1){
    	addValidationError( "alert", "Only one <b>Responsible</b> office is allowed.")
    }
      
		for (var j = 0; j < json_array.length; j++ ) {
			term_object["stakeholders"].push( { name: json_array[j]["text"], stake: stake} )
			var office_exist = false;
      if (office_array !=null )  {
         for (var k=0; k<office_array.length; k++){
            if (json_array[j]["text"] == office_array[k]["name"])  {
              office_exist = true;
              break;
      	    }
         }
       }

      if (!office_exist)
        office_array.push({name: json_array[j]["text"]})	
      else{
        if (!office_text)
          office_text = json_array[j]["text"]
        else if (office_text.search( json_array[j]["text"]) <0)
        	office_text  += " , "+ json_array[j]["text"]
        }

      }
      i++;
	}) 

  if (office_text !=null)
    addValidationError( "alert", "<b>" +  office_text + "</b>" +  " has repeated in the RACI entry. Each office is assigned for one role per term.");
    console.log( term_object )

  if ( showValidationErrors()  == true ) {
    return false;
  }
  
	return term_object;
}


function deleteTerm( termid ) {
  	$.ajax({
	    url:   termid,
	    type: 'DELETE',
	    success: function(data, status, xhr){
	      addSuccessMessage("success", "<b>" + data.message + ". Please wait for Glossary Page display.</br>" )
	      showSuccessMessage(); 
        var url = '../terms'
        window.location = url;
	    },
	    error: function(xhr, status, error) {
           //alert(xhr.responseText)
        addValidationError( "alert", "Delete term has errors: " + xhr.responseText);
        showValidationErrors()
      }
	});
}
function updateTerm( term_object ) {

	$.ajax({
	    url: term_object.id,
	    type: 'PUT',
	    data: {"termJSON": JSON.stringify(term_object) },
	   // data: { "termJSON": term_object },
    	dataType: 'json',
	    success: function (data) {
	       var url = escape(term_object.name);
	       addSuccessMessage("success", "<b>" + term_object.name + "</b>" +  " updated successfully. " );
	       showSuccessMessage();
           window.location = url;
	    },
	    error: function( xhr, ajaxOptions, thrownError) {
	       addValidationError( "alert", "Update term has errors: " + xhr.responseText);
           showValidationErrors()
	    }
	});

}

function createTerm( term_object ) {
  $.ajax({
     url : '/terms',
     type: 'POST',
     data: { "term": JSON.stringify(term_object)},
     dataType: 'json',
     success: function (data) {
        //alert('term created')
       addSuccessMessage("success", "<b>Term " + term_object.name +   " successfully. Please wait for Term Detail page display.</b>");
	      showSuccessMessage();
        var url = escape('terms/'+ term_object.name);
        //alert(url);
        //$('#term_detail').load(url);
        window.location = url;
     },
     error: function( xhr, ajaxOptions, thrownError) {
          addValidationError( "alert", "Added Term, " +term_object.name+ ", has error: " + xhr.responseText);
          showValidationErrors()
	    }
  })

}

function addOffice(office_object ) {

  $.ajax({
     url : '/offices',
     type: 'POST',
     data: { "office": JSON.stringify(office_object)},
     dataType: 'json',
     success: function (data) {
        //alert('term created')
       addSuccessMessage("success", "<b>Office " + office_object.name +   " successfully. Please wait for Term Detail page display.</b>");
       showSuccessMessage();
       var url = escape('offices/'+ office_object.name);
        //alert(url);
        //$('#term_detail').load(url);
        window.location = url;
     },
     error: function( xhr, ajaxOptions, thrownError) {
          addValidationError( "alert", "Added office, "+office_object.name+ ", has error: " + jQuery.parseJSON(xhr.responseText).message);
          showValidationErrors()
      }
   })

}


function updateOfficeObject(office_object ) {
  clearValidationErrors()
  tinymce.triggerSave();
  console.log(office_object);
  $('.editable').each( function() {
    id = $(this).attr('id');
    if ( id ) {
      p = tinymce.get(id).getContent()
      if (id == "name") {
        var StrippedString = p.replace(/(<([^>]+)>)/ig,"")
        p = StrippedString;
      }
      console.log(p);
      console.log(id);
      office_object[id] = p;
    }
   
  });

    return office_object;
  }
function updateOffice(office_object  ) {

  $.ajax({
      url: office_object.id,
      type: 'PUT',
      data: {"officeJSON": JSON.stringify(office_object)},
      dataType: 'json',
      success: function (data) {
         var url = escape(office_object.name);
         addSuccessMessage("success", "<b>" + office_object.name + "</b>" +  " updated successfully. " );
         showSuccessMessage();
         window.location = url;
      },
      error: function( xhr, ajaxOptions, thrownError) {
         addValidationError( "alert", "Update Office, <b>" + office_object.name + "</b>  has errors: " + jQuery.parseJSON(xhr.responseText).message);
         showValidationErrors()
      }
  });

}


function deleteOffice( officeid ) {
    $.ajax({
      url:   officeid,
      type: 'DELETE',
      success: function(data, status, xhr){
        addSuccessMessage("success", "<b>" + data.message + ". Please wait for Glossary Page display.</br>" )
        showSuccessMessage(); 
        var url = '../offices'
        window.location = url;
      },
      error: function(xhr, status, error) {
           //alert(xhr.responseText)
        addValidationError( "alert", "Delete term has errors: " + jQuery.parseJSON(xhr.responseText).message);
        showValidationErrors()
      }
  });
}


tinymce.init({
    selector: ".editable",
    inline: true,
    menubar: false,
    toolbar: "insertfile undo redo | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image"
  });

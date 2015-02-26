
$(document).ready(function(){

  // if (window.location.pathname.substring(0, 9) == "/reports/") {
  //   $( "#description" ).attr( "contenteditable", "false" );
  // };
  $('#editmode').change(function(){
    if ( this.checked ) {
      changetoeditmode();
    }
    else {
      changetoviewmode();
    }
  });


  if (typeof office_json != 'undefined')  {
   $('.raci_input').select2({
        data:office_json,
        multiple: true,
        width: "500px"
    });

    $('.raci_input').each( function() {
    	$(this).data().select2.updateSelection( $(this).data('init') )
    });

  }

 if (typeof term_gov_json != 'undefined')  {
   $('.term_input').select2({
        data:term_gov_json,
        multiple: true,
        width: "500px"
    });

    $('.term_input').val(function() {
      $(this).data().select2.updateSelection( $(this).data('init') )
    });

  }
  if (typeof security_roles_json != 'undefined')  {
   $('.role_input').select2({
        data:security_roles_json,
        multiple: true,
        width: "500px"
    });

    $('.role_input').val(function() {
      $(this).data().select2.updateSelection( $(this).data('init') )
    });

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


   if(typeof report_object != 'undefined')  {

    $('#updateReportButton').click(function() {
    //alert("updating report object")
      if (updateReportObject(report_object) == false)
        return false;

      updateReport(report_object)
    })

    // $('#showJSONButton').click( function() {
    //   $('#json_container').toggle()
    // })

    $('#deleteConfirm').click( function() {
      $('a.close-reveal-modal').trigger('click')
      deleteReport(report_object.id)
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
    });
    $('#deleteCancel').click( function() {
      $('a.close-reveal-modal').trigger('click')
    });

  }




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


  $('#createReportButton').click(function() {
    var rname = $('#rname').val();
    report_new = {
      "name": rname,
      "description": "",
      "report_type": "Tableau",
      "embedJSON" : "{\"width\": \"\",\"height\": \"\" ,\"name\": \"\"}"
    };
    $('a.close-reveal-modal').trigger('click'); 
    createReport(report_new);
  })
})

function changetoeditmode() {
  $( '.view' ).css( "display", "none" );
  $( '.edit' ).css( "display", "inherit" );
  // $( "#description" ).attr({
  //   "contenteditable": "true",
  //   "spellcheck": "false",
  //   "style": "position: relative;"
  // });
  $("#description").addClass("editable free-text");
  // $("#description").addClass("free-text");
  tinymce.init({
    selector: "div.editable",
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
  $("#currentmode").text('Edit Mode');
}

function changetoviewmode() {
  $( '.edit' ).css( "display", "none" );
  $( '.view' ).css( "display", "inherit" );
  $( "#description" ).attr( "contenteditable", "false" );
  $("#description").removeClass("editable");
  $("#description").removeClass("free-text");
  $("#currentmode").text('Preview Mode');
}

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

  })

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

function createReport(report_object ) {
  report_object_string = JSON.stringify(report_object)
  $.ajax({
     url : '/reports',
     type: 'POST',
     data: { "report": report_object_string},
     dataType: 'json',
     success: function (data) {
      addSuccessMessage("success", "<b>Report " + report_object.name +   " successfully. Please wait for report Detail page display.</b>")
      showSuccessMessage();
      var url = escape('/reports/'+ report_object.name)
      window.location = url;
   },
     error: function( xhr, ajaxOptions, thrownError) {
     addValidationError( "alert", "Added Report, " +report_object.name+ ", has error: " + xhr.responseText)
     showValidationErrors()
   }
  })

}

function updateReportObject(report_object ) {
  clearValidationErrors()
  tinymce.triggerSave();
  console.log(report_object );
   $('.editable').each(function() {
    id = $(this).attr('id');
    if ( id ) {
      p = tinymce.get(id).getContent()
      console.log(id);
      // if (id !='t_width' && id !='t_height'  && id !='t_name'&& id !='t_tabs') {
      report_object[id] = p;
      // }
      console.log(report_object);
      // if ( (id =="t_height") || (id =="t_width") || (id =="t_tabs") ){
      //   var StrippedString = p.replace(/(<([^>]+)>)/ig,"");
      //   p = StrippedString;
      // }
      // if (id =='t_width'){
      //    w = p

      // }
      // if (id =='t_height'){
      //    h =p

      // }
      // if (id =='t_tabs'){
      //    t =p

      // }
      // if (id =='t_name'){

      //    n = p.replace(/(<p>|<\/p>)/g, "");
      //    n = n.replace(/&amp;/g, '&');
      //    n = n.replace(/(")/g, "");
      // }
      // if (id =='report_type' || id == 'datasource' ){

      //   p = p.replace(/(<p>|<\/p>)/g, "");

      // }

      
    }
  })
  // report_object["embedJSON"] = "{\"width\": \""+w+"\", \"height\" : \"" + h+"\",\"name\":\""+ n+"\",\"tabs\":\""+t+"\"}"


  report_object["terms"] = []
  var term_array = []

  var term_text = null;
  json_term_array = $('#term_input').select2('data')
  console.log("This is the json_term_array: " + json_term_array);
  for (var j = 0; j < json_term_array.length; j++ ) {
    report_object["terms"].push( { name: json_term_array[j]["text"]} )
    var term_exists = false;
    if (term_array != null )  {
      for (var k=0; k<term_array.length; k++){
        if (json_term_array[j]["text"] == term_array[k]["name"])  {
          term_exists = true;
          break;
        }
      }
    }
    if (!term_exists){
      term_array.push({name: json_term_array[j]["text"]})
    }
    else{
      if (!term_text)
        term_text = json_term_array[j]["text"]
      else if (term_text.search( json_term_array[j]["text"]) < 0 ){
        term_text  += " , "+ json_term_array[j]["text"]
      }
    }
  }


  report_object["name"] = $('#name-edit').val();
  report_object["tableau_link"] = $('#tableaulink').val();

  report_object["report_type"] = $('#reporttype').val();
  report_object["datasource"] = $('#datasource').val();

  // report office owner
  report_object["offices"] = []
  selected_office = $('#office_owner').val();
  console.log('grabbed offices from dom' + selected_office)
  report_object["offices"].push( { name: selected_office, stake: "Responsible"} )
  console.log('report object json with officeoffice' + report_object);




  // By default, we are setting write ability to true for all associated role nodes
  report_object["allows_access_with"] = []
  var access_array=[]

  var access_text =null;
  json_access_array = $('#role_input').select2('data')
  console.log(json_access_array);
  for (var j = 0; j < json_access_array.length; j++ ) {

    report_object["allows_access_with"].push( { name: json_access_array[j]["text"], allow_update_and_delete: true} )
    var access_exists = false;
    if (access_array !=null )  {
      for (var k=0; k<access_array.length; k++){
        if (json_access_array[j]["text"] == access_array[k]["name"])  {
          access_exists = true;
          break;
        }
      }
    }

    if (!access_exists){
      access_array.push({name: json_access_array[j]["text"]})
    }
    else{
      if (!access_text){
        access_text = json_access_array[j]["text"]
      }
      else if (access_text.search( json_access_array[j]["text"]) <0){
        access_text  += " , "+ json_access_array[j]["text"]
      }
    }
  }
}


function updateReport( report_object ) {
  
$('form#report_image_upload').submit()

  $.ajax({
      url: report_object.id,
      type: 'PUT',
      data: {"reportJSON": JSON.stringify(report_object) },
     // data: { "termJSON": term_object },
      dataType: 'json',
      success: function (data) {
         console.log("succcess block")
         var url = escape(report_object.name);
         window.location.href = url;
         addSuccessMessage("success", "<b>" + report_object.name + "</b>" +  " updated successfully. " );
         showSuccessMessage();  
      },
      error: function( xhr, ajaxOptions, thrownError) {
         addValidationError( "alert", "Update Report has errors: " + xhr.responseText);
           showValidationErrors()
      }
  })
  /*.done(function(data) {
    console.log("done block")
    //$('form#report_image_upload').submit()  // silently submit the image upload.  how to validate??    
    var url = escape(report_object.name)
    window.location.href = url
  });
*/


  

}

function deleteReport( reportid ) {
    $.ajax({
      url:   reportid,
      type: 'DELETE',
      success: function(data, status, xhr){
        addSuccessMessage("success", "<b>" + data.message + ". Please wait for Reports Page display.</br>" )
        showSuccessMessage();
        var myHashLink = "browse/reports";
        window.location.href = '/' + myHashLink;
      },
      error: function(xhr, status, error) {
           //alert(xhr.responseText)
        addValidationError( "alert", "Report delete has errors: " + xhr.responseText);
        showValidationErrors()
      }
  });
}


function deleteTerm( termid ) {
  	$.ajax({
	    url:   termid,
	    type: 'DELETE',
	    success: function(data, status, xhr){
	      addSuccessMessage("success", "<b>" + data.message + ". Please wait for Glossary Page display.</br>" )
	      showSuccessMessage();
        var myHashLink = "browse/terms";
        window.location.href = '/' + myHashLink;
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
         window.location.href = url;
         addSuccessMessage("success", "<b>" + term_object.name + "</b>" +  " updated successfully. " );
         showSuccessMessage();
	    },
	    error: function( xhr, ajaxOptions, thrownError) {
	       addValidationError( "alert", "Update term has errors: " + xhr.responseText);
           showValidationErrors()
	    }
	})

}

function createTerm( term_object ) {
  $.ajax({
     url : '/terms',
     type: 'POST',
     data: { "term": JSON.stringify(term_object)},
     dataType: 'json',
     success: function (data) {
      addSuccessMessage("success", "<b>Term " + term_object.name +   " successfully. Please wait for Term Detail page display.</b>");
	    showSuccessMessage();
      var url = escape('/terms/'+ term_object.name);
      window.location = url;
   },
     error: function( xhr, ajaxOptions, thrownError) {
     addValidationError( "alert", "Added Term, " +term_object.name+ ", has error: " + xhr.responseText);
     showValidationErrors()
	 }
  })

}

function createReport( report_object ) {
  report_object_string = JSON.stringify(report_object)
  $.ajax({
     url : '/reports',
     type: 'POST',
     data: { "report": report_object_string},
     dataType: 'json',
     success: function (data) {
      addSuccessMessage("success", "<b>Report " + report_object.name +   " successfully. Please wait for report Detail page display.</b>")
      showSuccessMessage();
      var url = escape('/reports/'+ report_object.name)
      window.location = url;
   },
     error: function( xhr, ajaxOptions, thrownError) {
     addValidationError( "alert", "Added Report, " +report_object.name+ ", has error: " + xhr.responseText)
     showValidationErrors()
   }
  })

}


function addOffice( office_object ) {
  $.ajax({
     url : '/offices',
     type: 'POST',
     data: { "office": JSON.stringify(office_object)},
     dataType: 'json',
     success: function (data) {
      var url = escape('/offices/'+ office_object.name);
      window.location = url;
      addSuccessMessage("success", "<b>Office " + office_object.name +   " successfully. Please wait for Office Detail page display.</b>");
      showSuccessMessage();
     },
     error: function( xhr, ajaxOptions, thrownError) {
      addValidationError( "alert", "Added office, "+office_object.name+ ", has error: " + jQuery.parseJSON(xhr.responseText).message);
      showValidationErrors()
    }
  })

}


function updateOfficeObject( office_object ) {
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



function updateOffice( office_object ) {

  $.ajax({
      url: office_object.id,
      type: 'PUT',
      data: {"officeJSON": JSON.stringify(office_object)},
      dataType: 'json',
      success: function (data) {
        var url = escape(office_object.name);
        window.location = url;
        addSuccessMessage("success", "<b>" + office_object.name + "</b>" +  " updated successfully. " );
        showSuccessMessage();

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
        addSuccessMessage("success", "<b>" + data.message + ". Please wait for Offices display Page.</br>" )
        showSuccessMessage();
        var myHashLink = "browse/offices";
        window.location.href = '/' + myHashLink;
      },
      error: function(xhr, status, error) {
           //alert(xhr.responseText)
        addValidationError( "alert", "Delete term has errors: " + jQuery.parseJSON(xhr.responseText).message);
        showValidationErrors()
      }
  });
}


tinymce.init({
    selector: "div.editable",
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

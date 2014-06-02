
$(document).ready(function(){






     if(typeof term_object != 'undefined')  {

		$('#updateTermButton').click(function() {
		alert("updating term object")
		updateTermObject(term_object)
		updateTerm(term_object)
		})

		$('#showJSONButton').click( function() {
			$('#json_container').toggle()
		})

		$('#deleteTermButton').click(function() {
			if ( confirm('Are you sure?') ) {
				deleteTerm(term_object.id)
		    }
		})

	}

	$("#search1").bind("change keyup",function() {
		    console.log( $(this) )
		  	if ($(this).val().length >=2 ) {

	   		var url = 'terms/partial_search?q=' + $(this).val();
         console.log(url)
			$('#search_results').load(encodeURI(url));
		}
	})

	$('#createTermButton').click(function() {
		 alert("I am here creating new term");
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
})

function updateTermObject(term_object ) {
	//alert( tinymce )
     alert("updating term ..");
	tinymce.triggerSave();
	$('.editable').each( function() {
		id = $(this).attr('id');
		if ( id ) {
			p = tinymce.get(id).getContent()
			console.log(p);
			console.log(id);
			term_object[id] = p;
		}

	});

	return term_object
}

function deleteTerm( termid ) {
    alert("termid :" + termid)
	$.ajax({
	    url:   termid,
	    type: 'DELETE',
	    success: function(data, status, xhr){

	    	alert( data.message );

	    },
	    error: function(xhr, status, error) {
           alert(xhr.responseText)
       }
	});
}
function updateTerm( term_object ) {

	$.ajax({
	    url: term_object.id,
	    type: 'PUT',
	    data: { "termJSON": JSON.stringify(term_object) },
	   // data: { "termJSON": term_object },
    	dataType: 'json',
	    success: function (data) {
	       alert('term updated')
	    },
	    error: function( xhr, ajaxOptions, thrownError) {
        	alert(xhr.status + ": " + thrownError);
	    }
	});

}

function createTerm( term_object ) {

   $.ajax({
		url : '/terms',
	    type: 'POST',
	    data: { "term": JSON.stringify(term_object) },
	   // data: { "termJSON": term_object },
    	dataType: 'json',
	    success: function (data) {
	       alert('term created')
	       var url = escape('terms/'+ term_object.name);
	       alert(url);
	       $('#term_detail').load(url);
	    },
	    error: function( xhr, ajaxOptions, thrownError) {
        	alert(xhr.status + ": " + thrownError);
	    }
	});


}



tinymce.init({
    selector: ".editable",
    inline: true,
    menubar: false,
    toolbar: "insertfile undo redo | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image"
  });

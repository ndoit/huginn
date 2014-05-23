
$(document).ready( function() { 

		term_object = JSON.parse(term_json)
	
		$("#json").html( JSON.stringify(term_object, null, 4) );
		term_object.definition = "BMR " + term_object.definition
		updateTerm( term_object )

   		$('#search1').bind("change keyup",function() {
   		  if ($(this).val().length >=2 ) {
		   var url = 'terms/partial_search?q=' + $(this).val();
			$('#search_results').load(url);

		/*
		
		alert(url);
		$.ajax({
		    url: url,
		    dataType: "json",
		    success: function (data) {
		       var x = 1;
		      //$('#search_results').html( data )  
		    }
		});
		*/
	}})
})

function updateTerm( term_object ) {

	$.ajax({
	    url: term_object.name,
	    type: 'PUT',
	    data: {
	    	"termJSON": JSON.stringify(term_object)
	    },
    	dataType: 'json',
	    success: function (data) {
	       alert('yay')
	    },
	    error: function( xhr, ajaxOptions, thrownError) {
        alert(xhr.status);
        alert(thrownError);
	    }
	});

}

tinymce.init({
    selector: ".editable",
    inline: true,
    toolbar: "undo redo",
    menubar: true
   });




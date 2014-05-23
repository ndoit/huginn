
$(document).ready( function() { 

		term_object = JSON.parse(term_json)
	
   		$('#search1').bind("change keyup",function() {
   		  	if ($(this).val().length >=2 ) {
		   		var url = 'terms/partial_search?q=' + $(this).val();
				$('#search_results').load(url);
			}
		})

		//alert( $('#updateTermButton').length );
		$('#updateTermButton').click( function() {
			updateTermObject( term_object )
			updateTerm( term_object )
		})
})

function updateTermObject( term_object ) {
	//alert( tinymce )

	tinymce.triggerSave();
	$('.editable').each( function() {

		id = $(this).attr('id');
		if ( id ) {
			p = tinymce.get(id).getContent()
			term_object[id] = p;
		}

	});
	
	return term_object
}

function updateTerm( term_object ) {

	$.ajax({
	    url: term_object.id,
	    type: 'PUT',
	    data: { "termJSON": JSON.stringify(term_object) },
    	dataType: 'json',
	    success: function (data) {
	       alert('term updated')
	    },
	    error: function( xhr, ajaxOptions, thrownError) {
        	alert(xhr.status + ": " + thrownError);
	    }
	});

}

tinymce.init({
    selector: ".editable",
    inline: true,
    menubar: true,
    toolbar: "insertfile undo redo | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image"
  });
 




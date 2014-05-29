
$(document).ready(function(){ 

     if(term_object !=null)  {

	    alert(term_object);
   		$('#search1').bind("change keyup",function() {
   		  	if ($(this).val().length >=2 ) {
		   		var url = 'terms/partial_search?q=' + $(this).val();
				$('#search_results').load(url);
			}
		})

		alert( $('#updateTermButton').length );
		$('#updateTermButton').click(function() {
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
		
		$('#createTermButton').click(function() {
			 term_object = {
                "name": "Active Student",
                "definition": "An individual who has been confirmed by an admitting office (or other admitting authority), as recorded by the University Registrar, is considered an active student until he or she:\n\n● Graduates (if degree-seeking)\n● Completes the academic term (if non degree-seeking)\n● Withdraws or is dismissed by the University \n● Fails to enroll for a spring or fall academic term (unless granted a leave of absence by a Dean)\n",
                "source_system": "Banner",
                "data_sensitivity": "SELECT *\nFROM SGBSTDN\nWHERE Status = ‘AS’\n",
                "possible_values": "N/A",
                "data_availability": "Data is available by term from Fall 1982 to the present\n\n",
                "notes": "Students who withdraw or are dismissed during an academic term may be considered active for that academic term, at the discretion of the student’s dean.\n\nDuring the Fall and Spring academic term, students have up until the sixth day of classes to complete the roll call process and students who fail to enroll are inactivated, unless on leave.  Therefore, the use of current term active student data during the first two weeks of an academic term should be done judiciously.\n"};
				alert(term_object);
				createTerm(term_object);
		    
		})
	} 
})

function updateTermObject(term_object ) {
	//alert( tinymce )

	tinymce.triggerSave();
	alert("I am in update term object");
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
	    url:  '',
	    type: 'POST',
	    data: { "term": JSON.stringify(term_object) },
	   // data: { "termJSON": term_object },
    	dataType: 'json',
	    success: function (data) {
	       alert('term created')
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
 




$(document).ready( function() { 
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

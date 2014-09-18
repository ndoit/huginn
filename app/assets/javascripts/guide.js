$(document).ready(
  function() {
  	executeSearch()

    $('#content').on('click', '.more_results',
      function() {
        loadMoreResults( $(this) )
      }
    )

    $('#content').on( 'click', '.data-type-label-container', function() {
      $(this).find('.toggle_light').toggleClass('toggle_off')
      executeFilter()
    })


    // typeahead binding
    var pendingPartialSearch
    var delay = 200
    $("#search1").bind("keyup",function() {

      // if the user is still typing, cancel the pending search
      if ( pendingPartialSearch != null ) {
         clearTimeout( pendingPartialSearch )  // stop the pending one
      }
      console.log($("#search1").val() )

       // set a new search to execute in 200ms
      pendingPartialSearch = setTimeout( function() {
        console.log($("#search1").val() )
        executeSearch()
      }, delay )

    })

  }
)

function executeSearch() {

  search_string = $('#search1').val()
  console.log(search_string);

  var search = encodeURI(search_string)
  var url = '/guide_search'
  if ( search.length  ) {
    url += '?q=' + search
  }

  $('#search_results').load( url,
    function() {
      highlightSearchString()
      bindInfiniteScrollBehavior()
      $("#search1").focus()
  })

}





// the live version of this event didn't seem to work correctly,
// so it is manually bound after the dynamic content loads.
function bindInfiniteScrollBehavior() {
  console.log('binding')
  $('.more_results').unbind('inview')
  $('.more_results').bind('inview', function(event, isInView, visiblePartX, visiblePartY) {
    console.log('hit')
    if (isInView) {
      // element is now visible in the viewport
      if (visiblePartY == 'top') {
        // top part of element is visible
      } else if (visiblePartY == 'bottom') {
        // bottom part of element is visible
      } else {
        // whole part of element is visible
        //console.log('else')
        loadMoreResults( $(this) )
      }
    } else {
      // element has gone out of viewport
    }
  });
}

function loadMoreResults( more_button ) {
    more_button.html("<div><img src='/assets/ajax-loader.gif'></div>")
    url = searchURL( more_button.data('next-page') )
    console.log( url )

    // replace the current "more" button with the new content, which
    // will contain another "more" button
    $.get(url, function(data) {
         more_button.replaceWith(data)
         bindInfiniteScrollBehavior()
         highlightSearchString()
    });
}

function highlightSearchString() {
  search_string = $('#search1').val()
  $(".do_highlight").highlight( search_string )
}


function searchURL( page ) {
  url = '/guide_search?'
  url += 'selected_resources=' + selectedResourceList()

  if ( $('#search1').val().length ) {
    url += '&q=' + $('#search1').val()
  }
  if ( page != 1 ) {
    url += "&page=" + page
  }

  return url
}


function displayLoading() {
  $('#search_results_right').html("<div class='search_results_msg'><img src='/assets/ajax-loader.gif'></div>")
}





function executeFilter() {
  console.log(searchURL(1))
  displayLoading()
  $('#search_results').load( searchURL(1), function() {
    highlightSearchString()
  } )
}




function selectedResourceList() {
  resources = []
  $('.toggle_light').not('.toggle_off').each( function() {
    resources.push( $(this).data('resource-name') )
  })
  return resources.join(",")
}

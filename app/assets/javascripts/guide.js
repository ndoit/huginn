$(document).ready(
  function() {
  	executeFilter()

    bindFilterToggleBehavior()

    bindTypeaheadSearchBehavior() 
    
  }
)

function bindFilterToggleBehavior() {
    $('#content').on( 'click', '.data-type-label-container', function() {
      $(this).find('.toggle_light').toggleClass('toggle_off')
      executeFilter()
    })
}


function bindTypeaheadSearchBehavior() {
    // every keyup event starts a search that will
    // execute in 200ms unless another key is pressed!
    // typeahead binding
    var pendingPartialSearch
    var delay = 200
    $("#search1").bind("keyup",function() {

      search_val = $("#search1").val()
      if ( search_val.length == 0 || search_val.length >= 3 ) {
        // if the user is still typing, cancel the pending search
        if ( pendingPartialSearch != null ) {
           clearTimeout( pendingPartialSearch )  // stop the pending one
        }
        console.log( search_val )

         // set a new search to execute in 200ms
        pendingPartialSearch = setTimeout( function() {
          console.log(search_val)
          executeFilter()
        }, delay )
      }

    })
}


function executeFilter() {
  console.log(getSearchURL(1))
  displayLoading()
  $('#search_results').load( getSearchURL(1), function() {
    highlightSearchString()
    bindInfiniteScrollBehavior()
  } )
}


function getSearchURL( page ) {
  url = '/guide_search?'

  url += selectedResources()

  var searchString = encodeURI($('#search1').val())
  if ( searchString.length ) {
    url += '&q=' + $('#search1').val()
  }
  if ( page != 1 ) {
    url += "&page=" + page
  }

  return url
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
    url = getSearchURL( more_button.data('next-page') )
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




function displayLoading() {
  $('#search_results_right').html("<div class='search_results_msg'><img src='/assets/ajax-loader.gif'></div>")
}


function selectedResources() {
  var url = ''
  if ( $('.toggle_light').length != 0 ) {
    url = 'selected_resources=' + getSelectedResourceList()
  }
  return url
    
}

function getSelectedResourceList() {
  resources = []
  $('.toggle_light').not('.toggle_off').each( function() {
    resources.push( $(this).data('resource-name') )
  })
  return resources.join(",")
}

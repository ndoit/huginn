// // THIS IS THE GUIDE.JS FILE, BUT RENAMED APPROPRIATELY AND REFACTORED
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
// $(document).ready(
//   function() {
//   	executeFilter()
//
//     // bindFilterToggleBehavior()
//
//     bindTypeaheadSearchBehavior()
//
// // When the user clicks on the banner, redirects to root
//     $('.dddm-header').click( function() {
//       window.location = "/"
//     })
//
// // Puts the default greyed out text in the search box
//     $('#search1').watermark('Search')
//
//
//
//   }
// )
//
// // On click of the left bar filters,
// // Switch the checkbox to different styling,
// // and perform the executFilter funcion
// function bindFilterToggleBehavior() {
//     $('#content').on( 'click', '.data-type-label-container', function() {
//       // I'm using a different partial now. this wont be needed anymore
//       $(this).find('.toggle_light').toggleClass('toggle_off')
//       executeFilter()
//     })
// }
//
// function bindTypeaheadSearchBehavior() {
//     // every keyup event starts a search that will
//     // execute in 200ms unless another key is pressed!
//     // typeahead binding
//     var pendingPartialSearch
//     var delay = 200
//     $("#search1").bind("keyup",function() {
//
//       search_val = $("#search1").val()
//       if ( search_val.length == 0 || search_val.length >= 3 ) {
//         // if the user is still typing, cancel the pending search
//         if ( pendingPartialSearch != null ) {
//            clearTimeout( pendingPartialSearch )  // stop the pending one
//         }
//         console.log( search_val )
//
//          // set a new search to execute in 200ms
//         pendingPartialSearch = setTimeout( function() {
//           console.log(search_val)
//           executeFilter()
//         }, delay )
//       }
//
//     })
// }
//
// // console logs what was input into search box
// // displays the spinning bar gif
// // then sends a get request to searchURL in huginn
// function executeFilter() {
//   var searchURL = getSearchURL(1)
//   console.log(searchURL)
//   displayLoading()
//
//   $('#search_results').load( searchURL, function() {
//     highlightSearchString()
//     bindInfiniteScrollBehavior()
//   } )
// }
//
// // assigns the url as the base '/guide_search' and adds selectedResources()
// function getSearchURL( page ) {
//   url = '/guide_search?' + selectedResources()
//
//   var searchString = encodeURI( $('#search1').val() )
//   if ( searchString.length ) {
//     url += '&q=' + searchString
//   }
//   if ( page != 1 ) {
//     url += "&page=" + page
//   }
//
//   return url
// }
//
// // sets url as an empty string
// // sidebarExists() checks if the side bar is displayed
// // then sets url as get selected resources
//
// //This is what's determining what results get displayed.
// function selectedResources() {
//   var url = ''
//   if ( sidebarExists() ) {
//     url = 'selected_resources=' + getSelectedResourceList()
//   } else {
//     if ( $('#initial_selected_resources').length != 0 ) {
//       url = 'selected_resources=' + $('#initial_selected_resources').val()
//     }
//   }
//   return url
//
// }
//
// // checks which side bar items are checked,
// // stores those names as a variable with a string
// function getSelectedResourceList() {
//   var resources = []
//   userSelectedResources().each( function() {
//     resources.push( $(this).data('resource-name') )
//   })
//   return resources.join(",")
// }
//
// function sidebarExists() {
//   return $('.toggle_light').length != 0
// }
//
// function userSelectedResources() {
//   return $('.toggle_light').not('.toggle_off')
// }
//
// //////////bindinfinitescrollbehavior//////////
//
//
//
//
// // the live version of this event didn't seem to work correctly,
// // so it is manually bound after  the dynamic content loads.
// function bindInfiniteScrollBehavior() {
//   console.log('binding')
//   $('.more_results').unbind('inview')
//   $('.more_results').bind('inview', function(event, isInView, visiblePartX, visiblePartY) {
//     console.log('hit')
//     if (isInView) {
//       // element is now visible in the viewport
//       if (visiblePartY == 'top') {
//         // top part of element is visible
//       } else if (visiblePartY == 'bottom') {
//         // bottom part of element is visible
//       } else {
//         // whole part of element is visible
//         //console.log('else')
//         loadMoreResults( $(this) )
//       }
//     } else {
//       // element has gone out of viewport
//     }
//   });
// }
//
// function loadMoreResults( more_button ) {
//     more_button.html("<div><img src='/assets/ajax-loader.gif'></div>")
//     url = getSearchURL( more_button.data('next-page') )
//     console.log( url )
//
//     // replace the current "more" button with the new content, which
//     // will contain another "more" button
//     $.get(url, function(data) {
//          more_button.replaceWith(data)
//          bindInfiniteScrollBehavior()
//          highlightSearchString()
//     });
// }
//
// function highlightSearchString() {
//   search_string = $('#search1').val()
//   $(".do_highlight").highlight( search_string )
// }
//
//
//
//
// function displayLoading() {
//   $('#search_results_right').html("<div class='search_results_msg'><img src='/assets/ajax-loader.gif'></div>")
// }

// // global functions
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
// //===================================================================
// //===================================================================
// //===================================================================
// // All the old functions related to validations
// //===================================================================
// //===================================================================
// //===================================================================
//
//
//
//
// function clearValidationErrors() {
//   $('.alert-box').each( function() {
//     $(this).find('.error_list').html('');
//     $(this).find('.success_msg').html('');
//     $(this).hide()
//   })
// }
//
// function addValidationError( type, message ) {
//   error_list = $('.alert-box.' + type ).find('ul.error_list')
//   error_list.append( '<li>' + message + '</li>')
// }
//
// function showValidationErrors() {
//   errors_exist = false
//   $('.alert-box').each( function() {
//     if ( $(this).find('li').length != 0 ){
//       type = $(this).find('alert','warning')
//       $('.alert-box.' + type.selector).show().html_safe;
//       errors_exist = true
//     }
//   })
//   if ( errors_exist ) {
//     window.scrollTo(0,0)
//   }
//   return errors_exist
// }
//
// function addSuccessMessage(type, message ) {
//   $('.alert-box.' + type ).find('span.success_msg').append(message);
// }
// function showSuccessMessage() {
//   success_exist = false
//   $('.alert-box').each( function() {
//     if ( $(this).find('span').html){
//       type = $(this).find('success')
//       $('.alert-box.' + type.selector).show().html_safe;
//       success_exist = true
//     }
//   })
//   if ( success_exist) {
//     window.scrollTo(0,0)
//   }
//   return success_exist
// }

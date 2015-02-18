// // ALL JQUERY/JAVASCRIPT RELATED TO REPORT PAGE AND REPORT PAGE CRUD FUNCTIONALITY
//
//
//
// /* global ajax */
//
// (function(){
//   'use strict'
//
//   $(document).ready(init);
//
//   function init(){
//     $('#createReportButton').on('click', createNewReport);
//   }
//
// //================================================//
// //==================REPORT OBJECT================//
// //==============================================//
//
//   function createNewReport (){
//     var report = {
//       'name'          :$('#rname').val(),
//       'description'   :'',
//       'report_type'   :'',
//       'embedJSON'     :'{\"width\": \"\",\"height\": \"\" ,\"name\": \"\"}'
//     };
//
//     $('a.close-reveal-modal').trigger('click');
//     createReport(report);
//   }
//
//
//   function createReport(report){
//     report_object_string = JSON.stringify(report_object);
//     //Not sure what to do with "successType" in the following ajax function
//     ajax('/reports', 'POST', {report:report_objct_string}, 'json', successType);
//   }
//
//   function deleteReport(reportid){
//     //Not sure what to do with "successType" in the following ajax function
//     ajax(reportid, 'DELETE', null, null, successType);
//   }
//
//   function updateReport(report_object){
//     $('form#report_image_upload').submit();
//     //Not sure what to do with "successType" in the following ajax function
//     ajax(report_objects.id, 'PUT', {'reportJSON':JSON.stringify(report_object)}, dataType:'json', successType);
//   }
//
//   function updateReportObject(report_object){
//     clearValidationErrors();
//     tinymce.triggerSave();
//     //console.log(report_object);
//     $('.editable').each(function(){
//       id = $(this).attr('id');
//       if(id){
//         p = tinymce.get(id).getContent();
//
//         switch(id){
//           case 'name' || 'office_owner' || 't_height' || 't_width' || 't_tabs':
//             var StrippedString = p.replace(/(<([^>]+)>)/ig,"");
//             p = StrippedString;
//             break;
//           case 't_width':
//             w = p;
//             break;
//           case 't_height':
//             h = p;
//             break;
//           case 't_tabs':
//             t = p;
//             break;
//           case 't_name':
//
//
//         }
//
//
//       }
//
//     })
//   }
//
// })();
//
//
//
//
//
//
// //===================================================================
// //===================================================================
// //===================================================================
// // All the old functions related to reports
// //===================================================================
// //===================================================================
// //===================================================================
//
//
// function createReport(report_object){
//   report_object_string = JSON.stringify(report_object)
//   $.ajax({
//     url : '/reports',
//     type: 'POST',
//     data: { "report": report_object_string},
//     dataType: 'json',
//     //Need to figure out how to handle success and error in the ajax function
//     success: function (data) {
//       addSuccessMessage("success", "<b>Report " + report_object.name +   " successfully. Please wait for report Detail page display.</b>")
//       showSuccessMessage();
//       var url = escape('/reports/'+ report_object.name)
//       window.location = url;
//     },
//     //What are the arguments that are being passed into the following function? Where do they come from?
//     //What is xhr?
//     error: function( xhr, ajaxOptions, thrownError) {
//       addValidationError( "alert", "Added Report, " +report_object.name+ ", has error: " + xhr.responseText)
//       showValidationErrors()
//     }
//   })
//
// }
//
// //===========================================================================================
//
// function deleteReport( reportid ) {
//   $.ajax({
//     url:   reportid,
//     type: 'DELETE',
//     //What are the arguments that are being passed into the following function? Where do they come from?
//     //What is xhr?
//     success: function(data, status, xhr){
//       addSuccessMessage("success", "<b>" + data.message + ". Please wait for Reports Page display.</br>" )
//       showSuccessMessage();
//       var myHashLink = "browse/reports";
//       window.location.href = '/' + myHashLink;
//     },
//     error: function(xhr, status, error) {
//       //alert(xhr.responseText)
//       addValidationError( "alert", "Report delete has errors: " + xhr.responseText);
//       showValidationErrors()
//     }
//   });
// }
//
// //===========================================================================================
//
//
// function updateReport( report_object ) {
//
//   $('form#report_image_upload').submit()
//
//   $.ajax({
//     url: report_object.id,
//     type: 'PUT',
//     data: {"reportJSON": JSON.stringify(report_object) },
//     // data: { "termJSON": term_object },
//     dataType: 'json',
//     success: function (data) {
//       console.log("succcess block")
//       var url = escape(report_object.name);
//       window.location.href = url;
//       addSuccessMessage("success", "<b>" + report_object.name + "</b>" +  " updated successfully. " );
//       showSuccessMessage();
//     },
//     error: function( xhr, ajaxOptions, thrownError) {
//       addValidationError( "alert", "Update Report has errors: " + xhr.responseText);
//       showValidationErrors()
//     }
//   })
//   /*.done(function(data) {
//   console.log("done block")
//   //$('form#report_image_upload').submit()  // silently submit the image upload.  how to validate??
//   var url = escape(report_object.name)
//   window.location.href = url
// });
// */
//
// //===========================================================================================
//
//
// function updateReportObject(report_object ) {
//   clearValidationErrors()
//   tinymce.triggerSave();
//   console.log(report_object );
//   $('.editable').each(function() {
//     id = $(this).attr('id');
//     if ( id ) {
//       p = tinymce.get(id).getContent()
//       if ((id == "name")  || (id == "office_owner") || (id =="t_height") || (id =="t_width") || (id =="t_tabs") ){
//         var StrippedString = p.replace(/(<([^>]+)>)/ig,"");
//         p = StrippedString;
//       }
//       if (id =='t_width'){
//         w = p
//
//       }
//       if (id =='t_height'){
//         h =p
//
//       }
//       if (id =='t_tabs'){
//         t =p
//
//       }
//       if (id =='t_name'){
//
//         n = p.replace(/(<p>|<\/p>)/g, "");
//         n = n.replace(/&amp;/g, '&');
//         n = n.replace(/(")/g, "");
//       }
//       if (id =='report_type' || id == 'datasource' ){
//
//         p = p.replace(/(<p>|<\/p>)/g, "");
//
//       }
//
//       console.log(id);
//       if (id !='t_width' && id !='t_height'  && id !='t_name'&& id !='t_tabs') {
//         report_object[id] = p;
//       }
//       console.log(report_object);
//     }
//   })
//   report_object["embedJSON"] = "{\"width\": \""+w+"\", \"height\" : \"" + h+"\",\"name\":\""+ n+"\",\"tabs\":\""+t+"\"}"
//
//   report_object["terms"] = []
//   var term_array=[]
//
//   var term_text =null;
//   json_term_array = $('#term_input').select2('data')
//   console.log("This is the json_term_array: " + json_term_array);
//   for (var j = 0; j < json_term_array.length; j++ ) {
//     report_object["terms"].push( { name: json_term_array[j]["text"]} )
//     var term_exists = false;
//     if (term_array !=null )  {
//       for (var k=0; k<term_array.length; k++){
//         if (json_term_array[j]["text"] == term_array[k]["name"])  {
//           term_exists = true;
//           break;
//         }
//       }
//     }
//     if (!term_exists){
//       term_array.push({name: json_term_array[j]["text"]})
//     }
//     else{
//       if (!term_text)
//       term_text = json_term_array[j]["text"]
//       else if (term_text.search( json_term_array[j]["text"]) <0){
//         term_text  += " , "+ json_term_array[j]["text"]
//       }
//     }
//   }
//
//   // By default, we are setting write ability to true for all associated role nodes
//   report_object["allows_access_with"] = []
//   var access_array=[]
//
//   var access_text =null;
//   json_access_array = $('#role_input').select2('data')
//   console.log(json_access_array);
//   for (var j = 0; j < json_access_array.length; j++ ) {
//
//     report_object["allows_access_with"].push( { name: json_access_array[j]["text"], allow_update_and_delete: true} )
//     var access_exists = false;
//     if (access_array !=null )  {
//       for (var k=0; k<access_array.length; k++){
//         if (json_access_array[j]["text"] == access_array[k]["name"])  {
//           access_exists = true;
//           break;
//         }
//       }
//     }
//
//     if (!access_exists){
//       access_array.push({name: json_access_array[j]["text"]})
//     }
//     else{
//       if (!access_text){
//         access_text = json_access_array[j]["text"]
//       }
//       else if (access_text.search( json_access_array[j]["text"]) <0){
//         access_text  += " , "+ json_access_array[j]["text"]
//       }
//     }
//   }
// }
//
// //===========================================================================================
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
//
// //===============================================================================
//
// // $('#createReportButton').click(function() {
// //   var report = $('#rname').val();
// //   report_new = {
// //     "name": report,
// //     "description": "",
// //     "report_type": "",
// //     "embedJSON" : "{\"width\": \"\",\"height\": \"\" ,\"name\": \"\"}"
// //   };
// //   $('a.close-reveal-modal').trigger('click');
// //
// //   createReport(report_new);
// // })

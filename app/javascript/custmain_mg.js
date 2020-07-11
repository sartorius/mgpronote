$(document).ready(function() {
  // console.log('We are in MGFollowAPP JS2');
  //mainLoaderInCaseOfChange();
});

$(document).on('turbolinks:load', function() {
  function customLogErr(msg){
    $('#alerting-msg').text('Erreur: ' + msg);
    $('#alerting').show();
  }
})

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

$(document).on("turbolinks:click", function(){
  $(".spinner").show();
  $(".modal").show();
});

$(document).on("turbolinks:load", function(){
  $(".spinner").hide();
  $(".modal").hide();
});

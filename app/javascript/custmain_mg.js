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
  //$("#screen-load").show();
  //$(".modal").show();
  $("#screen-load").show();
});

$(document).on("turbolinks:load", function(){
  //$("#screen-load").hide();
  //$(".modal").hide();
  $("#screen-load").hide();
});

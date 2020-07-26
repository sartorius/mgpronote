$(document).ready(function() {
  // console.log('We are in MGFollowAPP JS2');
  //mainLoaderInCaseOfChange();
});

$(document).on('turbolinks:load', function() {

    function customLogErr(msg){
      $('#alerting-msg').text('Erreur: ' + msg);
      $('#alerting').show();
    }


    // RGDP
    //Check if display or not
    let didAcceptRGDPAlready = localStorage.getItem("acceptRGDP");
    if((typeof didAcceptRGDPAlready == 'undefined') || (didAcceptRGDPAlready == null)){
        didAcceptRGDPAlready = 'N';
        console.log("Not readable");
    }
    if(didAcceptRGDPAlready == 'N'){
      $("#flt-bar-cookie").show();
    }
    // Handle the click accept
    $("#rgdp-wrn").click(function() {
      console.log("you clicked on #rgdp-wrn");
      // Log in JS session
      localStorage.setItem("acceptRGDP", 'Y');
      // Remove
      $("#flt-bar-cookie").hide();
    });

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

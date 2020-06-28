$(document).on('turbolinks:load', function() {
  // Should be called at each visit
  console.log('Form TBL Page as changed');
  mainFormLoaderInCaseOfChange();
})

function mainFormLoaderInCaseOfChange(){
  //initialize
  $("#crt-submit").prop('disabled', true);
  $("#crt-submit").hide();

  if($('#mg-graph-identifier').text() == 'formuser-gr'){
    listenAllFormCreate();
  }
  else{
    //do nothing
  }
}

function listenAllFormCreate(){
  $( ".crt-fill-form" ).keyup(function() {
    verityFieldFormRef();
  });
  $( "#crt-submit" ).click(function() {
    $('#crt-name').val(capitalizeFirstLetter($('#crt-name').val()));
    $('#crt-fname').val(capitalizeFirstLetter($('#crt-fname').val()));
  });
}

function capitalizeFirstLetter(string) {
  return string.charAt(0).toUpperCase() + string.slice(1).toLowerCase();
}

function validatePhoneNumber(phonetest){
  const re = /^[+-]?\d+$/;
  return re.test(phonetest);
}


function validateEmail(email){
  const re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  return re.test(email);
}

function verityFieldFormRef(){
  let allFieldOK = true;

  // Check email
  if (!(validateEmail($('#crt-email').val()))){
    allFieldOK = false;
    $('#ck-email').show(800);
  }
  else{
    $('#ck-email').hide(800);
  }
  if($('#crt-pwd').val().length < 7){
    allFieldOK = false;
    $('#ck-pwd').show(800);
  }
  else{
    $('#ck-pwd').hide(800);
  }
  // Check password
  if(($('#crt-pwd').val().length < 7)
        || (!($('#crt-cpwd').val() == $('#crt-pwd').val()))){
    allFieldOK = false;
    $('#ck-cpwd').show(800);
  }
  else{
    $('#ck-cpwd').hide(800);
  }
  if($('#crt-name').val().length < 1){
    allFieldOK = false;
    $('#ck-name').show(800);
  }
  else{
    $('#ck-name').hide(800);
  }
  if($('#crt-fname').val().length < 1){
    allFieldOK = false;
    $('#ck-fname').show(800);
  }
  else{
    $('#ck-fname').hide(800);
  }
  if (!(validatePhoneNumber($('#crt-phone').val()))){
    allFieldOK = false;
    $('#ck-phone').show(800);
  }
  else{
    $('#ck-phone').hide(800);
  }

  if(allFieldOK){
      $("#crt-submit").prop('disabled', false);
      $("#crt-submit").show(500);
  }
  else{
      $("#crt-submit").prop('disabled', true);
      $("#crt-submit").hide(500);
  }
}

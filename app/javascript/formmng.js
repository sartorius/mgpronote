$(document).on('turbolinks:load', function() {
  // Should be called at each visit
  //console.log('Form TBL Page as changed');
  mainFormLoaderInCaseOfChange();
})

function mainFormLoaderInCaseOfChange(){

  if($('#mg-graph-identifier').text() == 'formuser-gr'){
    //initialize
    $("#crt-submit").prop('disabled', true);
    $("#crt-submit").hide();
    listenAllFormCreate();
  }
  else if($('#mg-graph-identifier').text() == 'signupclt-gr'){
    //edituser-gr
    //initialize
    $("#add-clt-submit").prop('disabled', true);
    $("#add-clt-submit").hide();
    listenAddCltFormCreate();
  }
  else if($('#mg-graph-identifier').text() == 'edituser-gr'){
    //edituser-gr
    //no initializion as pre-filled
    listenEditFormCreate();
  }
  else if($('#mg-graph-identifier').text() == 'editpwd-gr'){
    //edituser-gr
    //initialize
    $("#editpwd-submit").prop('disabled', true);
    $("#editpwd-submit").hide();
    listenPwdEditFormCreate();
  }
  else if($('#mg-graph-identifier').text() == 'home-gr'){
    $("#btnVerify").click(function() {
      let refTag = $('#inputMG').val();
      if(validateMGSCode(refTag)){
        $("#read-cb-id").val(decodeMGSCodePartId(refTag));
        $("#read-cb-sec").val(decodeMGSCodePartSecure(refTag));
      }
    });
  }
  else{
    //do nothing
  }
}

function listenAllFormCreate(){
  $( ".crt-fill-form" ).keyup(function() {
    verityFieldFormRef();
  });
  $("#crt-submit").click(function() {
    $('#mg-add-pk-name').val(capitalizeFirstLetter($('#mg-add-pk-name').val()));
  });
}

function listenEditFormCreate(){
  $( ".crt-fill-form" ).keyup(function() {
    verityEditFieldFormRef();
  });
}

function listenPwdEditFormCreate(){
  $( ".crt-fill-form" ).keyup(function() {
    verityPwdEditFieldFormRef();
  });
}

function listenAddCltFormCreate(){
  $( ".crt-fill-form" ).keyup(function() {
    verityAddCltFormRef();
  });
}


// CONTROLLER Here

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


// CHECKER

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

function verityAddCltFormRef(){
  let allFieldOK = true;

  // Check email
  if (!(validateEmail($('#crt-email').val()))){
    allFieldOK = false;
  }
  // This could be simpler but we need to keep the logic
  if(allFieldOK){
      $("#add-clt-submit").prop('disabled', false);
      $("#add-clt-submit").show(500);
  }
  else{
      $("#add-clt-submit").prop('disabled', true);
      $("#add-clt-submit").hide(500);
  }
}

function verityEditFieldFormRef(){
  let allFieldOK = true;

  if (!(validatePhoneNumber($('#crt-phone').val()))){
    allFieldOK = false;
    $('#ck-phone').show(800);
  }
  else{
    $('#ck-phone').hide(800);
  }

  if(allFieldOK){
      $("#edit-submit").prop('disabled', false);
      $("#edit-submit").show(500);
  }
  else{
      $("#edit-submit").prop('disabled', true);
      $("#edit-submit").hide(500);
  }
}

function verityPwdEditFieldFormRef(){
  let allFieldOK = true;

  // Check email
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

  if(allFieldOK){
      $("#editpwd-submit").prop('disabled', false);
      $("#editpwd-submit").show(500);
  }
  else{
      $("#editpwd-submit").prop('disabled', true);
      $("#editpwd-submit").hide(500);
  }
}

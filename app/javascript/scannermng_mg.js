
$(document).on('turbolinks:load', function() {
  // Should be called at each visit
  //console.log('Scan TBL Page as changed');
  mainScanLoaderInCaseOfChange();
})

function mainScanLoaderInCaseOfChange(){
  if($('#mg-graph-identifier').text() == 'savebc-gr'){

    $("#btn-step-inc").click(function() {
        $("#blc-step-ctrl").hide(400);
        $("#blk-cmt").show(400);
        $("#mg-save-step-btn").val('Enregistrer incident');
        $("#btn-step-inc").hide();
        $("#btn-step-inc-cnl").show(400);

        //Weight need to be hide
        //M0000634S
        weightManagerDisable();

    });
    //inverse
    $("#btn-step-inc-cnl").click(function() {
        $("#blc-step-ctrl").show(400);
        $("#blk-cmt").hide(400);
        $("#mg-save-step-btn").val('Enregistrer une étape');
        $("#btn-step-inc-cnl").hide();
        $("#btn-step-inc").show(400);
        //We need to clean the step comment
        $("#stpcmt").val('');
        //Call Weight manager if needed
        weightManager();
    });

    $("#mg-save-step-btn").click(function() {
        getGeoL();
    });
    getGeoL();
    // Load the step
    displayNext(false);
  }
  else if($('#mg-graph-identifier').text() == 'grpsavebc-gr'){
    // Make sure we geolocalize everyone
    $("#mg-save-step-btn").click(function() {
        getGeoL();
    });
    getGeoL();

    // button id mg-save-step-btn

    // Load the step
    displayNext(true);
  }
  else if($('#mg-graph-identifier').text() == 'grpfinal-gr'){
    displayGrpListOfBC();
  }
  else if($('#mg-graph-identifier').text() == 'getnext-gr'){
      //console.log('in getnext-gr');
      $("#mg-check-step-btn").click(function() {
          getGeoL();
      });
      getGeoL();
      loadCameraRead(false);
  }
  else if($('#mg-graph-identifier').text() == 'grpgetnext-gr'){
      //console.log('in getnext-gr');

      $("#mg-check-step-btn").click(function() {
          getGeoL();
      });
      getGeoL();
      loadCameraRead(true);

      //DEBUG CHANGE keep for test
      //$('#mg-grp-step-btn').show();
  }
  else if($('#mg-graph-identifier').text() == 'grpnexterr-gr'){
    // We have an error after trying to group evoluate
    let errFound = parseInt($('#max-err-grp').html());
    let errNFound = parseInt($('#max-nf-err-grp').html());

    for(i=0; i<errFound; i++){
      $('#grp-bc-' + i.toString()).html(
        mgsEncode($('#id-grp-res-' + i.toString()).html(), $('#sec-grp-res-' + i.toString()).html())
      );
    }
    for(i=0; i<errNFound; i++){
      $('#grp-nf-pure-bc-' + i.toString()).html(
        mgsEncode($('#id-grp-nf-pure-res-' + i.toString()).html(), $('#sec-grp-nf-pure-res-' + i.toString()).html())
      );
    }

  }
  else if($('#mg-graph-identifier').text() == 'checkbc-gr'){
    try {
      loadCameraRead(false);
    }
    catch(err) {
      console.log(err.message);
      customLogErr(err.message);
    }
  }
  else if($('#mg-graph-identifier').text() == 'checktag-gr'){
    loadBCTag();
  }
  else if($('#mg-graph-identifier').text() == 'pereone-gr'){
    $("#save-addr-sub").click(function() {
        getGeoL();
    });
    getGeoL();
  }
  else{
    //do nothing
  }
}

/* -------------------------------------------------------------------------- */
// Show next steps
function addOptionListener(){
  $('#stepCtrl').change(function() {
      $('#read-step-txt').val($("#stepCtrl option:selected").text());


  });
}

function validateNumberOnly(weight){
  const re = /^[0-9]*$/;
  return re.test(weight);
}

function verityWeightFormRef(){
  let allFieldOK = true;

  // Check email
  if (!(validateNumberOnly($('#stpweight').val()))){
    allFieldOK = false;
  }
  if(parseInt($('#stpweight').val()) < 250){
    allFieldOK = false;
  }
  // limite 10t
  if(parseInt($('#stpweight').val()) > 10000000){
    allFieldOK = false;
  }
  if($('#stpweight').val().length == 0){
    allFieldOK = false;
  }

  if(allFieldOK){
      $("#mg-save-step-btn").prop('disabled', false);
      $("#mg-save-step-btn").show(500);
  }
  else{
      $("#mg-save-step-btn").prop('disabled', true);
      $("#mg-save-step-btn").hide(500);
  }
}

//Need to promote to generic utils forced?
function mgsEncodeClientRef(fname, lid, ref){
  let lidPlusSec = parseInt(lid.toString() + mgspad(ref, 3).toString()).toString(35);
  let fnameCode = (fname.length == 1) ? fname.substring(0, 1)+'X' : fname.substring(0, 2);
  return fnameCode.toUpperCase() + '-' + lidPlusSec.replace(/o/g,"Z").replace(/O/g,"Z").toUpperCase();
}

function weightManager(){
  //Weight Manager
  //We are trying to check weight
  // 6 is the weight step id
  if(dataTagToJsonArray[0].end_step_id == 6){
    $('#blk-weight').show();
    $('#mg-save-step-btn').hide();
    $( "#stpweight" ).keyup(function() {
      verityWeightFormRef();
    });
  }
}
// Need to be called in case of incident on off
function weightManagerDisable(){
  if(dataTagToJsonArray[0].end_step_id == 6){
    $('#blk-weight').hide();
    $('#mg-save-step-btn').show();
  }
}

function isOdd(num) {return (num % 2) == 1;}

function displayGrpListOfBC(){
  let htg1 = '<div class="size-med-nc font-mono">';
  let htg1Alt = '<div class="size-med-nc font-mono bg-pc">';
  let htg2 = '</div>'
  $(".grp-read-nb").html(parseInt(dataTagToJsonArrayPure.length) + parseInt(dataTagToJsonArrayExt.length));
  let diplayList = '';
  let j = 0;

  for(i=0; i<dataTagToJsonArrayPure.length; i++){
    diplayList = diplayList + (isOdd(j) ? htg1 : htg1Alt) + mgsEncode(dataTagToJsonArrayPure[i].id, dataTagToJsonArrayPure[i].secure) + htg2;
    j = j +1;
  }
  for(i=0; i<dataTagToJsonArrayExt.length; i++){
    diplayList = diplayList + (isOdd(j) ? htg1 : htg1Alt) + dataTagToJsonArrayExt[i].toString() + htg2;
    j = j +1;
  }
  $("#list-of-read-bc").html(diplayList);
}

function displayNext(isGrp){

  // Initialize

  let nextSteps = "";
  // target <option value="1" title="Tooltip">Livraison</option>
  let nsp1 = '<option value="';
  let nsp2 = '" >';
  let nsp2Disabled = '" disabled>';
  let curNsp2 = nsp2;
  let nsp3 = '</option>';
  let disabledCounter = 0;
  let needReInitReadStepTxt = false;
  if(dataTagToJsonArray.length > 0){


    $("#read-mwfk").val(dataTagToJsonArray[0].mwkf_id);
    $("#read-rwfk").val(dataTagToJsonArray[0].rwkf_id);
    $("#read-cb-id").val(dataTagToJsonArray[0].bc_id);
    $('#read-step-txt').val(dataTagToJsonArray[0].end_step);

    //Handle weight action here !
    //Grouping don't do Weight
    if (!isGrp){
      console.log('We DO weightManager()');
      $('#curr-status').html(dataTagToJsonArray[0].curr_step);
      weightManager();

      // Handle incident here
      if((dataTagToJsonArray[0].curr_inc != null) && (dataTagToJsonArray[0].curr_inc != '')){
        $('#descr-incident').html(dataTagToJsonArray[0].curr_inc);
        $('#decl-incident').show();
      }
    }
    else{
      /*
      console.log('We do not do weightManager()');
      console.log('Length pure: ' + dataTagToJsonArrayPure.length);
      console.log('dataTagToJsonArrayPure: ' + JSON.stringify(dataTagToJsonArrayPure));

      console.log('Length pure: ' + dataTagToJsonArrayExt.length);
      console.log('dataTagToJsonArrayExt: ' + JSON.stringify(dataTagToJsonArrayExt));
      */
      dataTagToJsonArrayPureId = new Array();
      for(i=0; i<dataTagToJsonArrayPure.length; i++){
        dataTagToJsonArrayPureId.push(dataTagToJsonArrayPure[i].id);
      }
      // We update the data to be send
      // Sending couple are useless but I want to get several code display
      $('#read-cb-grp-pure').val(JSON.stringify(dataTagToJsonArrayPure));
      $('#read-cb-grp-pure-id').val(JSON.stringify(dataTagToJsonArrayPureId));
      $('#read-cb-grp-ext').val(JSON.stringify(dataTagToJsonArrayExt));
      displayGrpListOfBC();
    }


    for(var i=0; i<dataTagToJsonArray.length; i++){
        // We check if the next action is owned by partner or not
        // Be careful on Act Owner P (partner) versus type D and P (pickup)
        if(dataTagToJsonArray[i].rse_act_owner != 'P'){
          // Then the next option is disabled
          curNsp2 = nsp2Disabled;
          disabledCounter++;
        }
        else{
          // Next option is possible as it is P
          curNsp2 = nsp2;
        }
        // Now we need to treat differently 2 and 4 which are specific
        // Step 2 cannot be pickup
        // We need to discard one of them
        if ((parseInt(dataTagToJsonArray[i].end_step_id) == 2) &&
              parseInt((dataTagToJsonArray[i].curr_step_id) == 0) &&
              (dataTagToJsonArray[i].bc_type_pack == 'P')){
              // This is not possible we do nothing
              if(i == 0){
                // We need to re-initialize the text
                needReInitReadStepTxt = true;
                console.log('needReInitReadStepTxt true');
              }
              disabledCounter++;
        }
        else {
          nextSteps = nextSteps + nsp1 + dataTagToJsonArray[i].end_step_id + curNsp2 + dataTagToJsonArray[i].end_step + nsp3;
          if (needReInitReadStepTxt){
            console.log('Did the needReInitReadStepTxt');
            $('#read-step-txt').val(dataTagToJsonArray[i].end_step);
          }
        }
    }
    $("#stepCtrl").html(nextSteps);
    // No other step is possible
    if(disabledCounter == dataTagToJsonArray.length){
      $('#stpcmt').hide();
      $('#mg-save-step-btn').hide();
      $('#no-next-step').show();
      $('#btn-cnl-nstp').removeClass('btn-sm');
      $('#btn-cnl-nstp').addClass('btn-lg');
      $('#btn-cnl-nstp').html("Retourner à l'accueil");
      $('#blok-inc-btn').hide();

    }
  }
  else{
    $("#displaymsg").html("Erreur: récupération des étapes");
  }
  addOptionListener();
}

function strbadge(str){
  return '<span class="badge badge-primary-medium">' + str + '</span>';
}

/* -------------------------------------------------------------------------- */
// Show tag
function loadBCTag(){
  var resulTag = "";

  if(dataTagToJsonArray.length > 0){

    //$("#readBC").html(dataTagToJsonArray[0].ref_tag);

    for(var i=0; i<dataTagToJsonArray.length; i++){
      resulTag = resulTag +
          strbadge(dataTagToJsonArray[i].step) + '<br>'
          + "<strong>Date: " + dataTagToJsonArray[i].create_date + "</strong><br> ";
          if(dataTagToJsonArray[i].geo_l.trim() == 'N'){
            resulTag = resulTag + 'Localisation indisponible ou refusée.';
          }
          else{
            resulTag = resulTag + 'Voir localisation: <a href="http://www.google.com/maps/place/'+ dataTagToJsonArray[i].geo + '"><i class="glyphicon glyphicon-eye-open"></i></a>';
          }
          resulTag = resulTag + '<br><span class="mg-color"><i class="glyphicon glyphicon-paperclip"></i> ' + dataTagToJsonArray[i].description + "</span><br>";
          resulTag = resulTag + '<br><span class="mg-color"><i class="glyphicon glyphicon-barcode"></i> Opéré par ' + mgsEncodeClientRef(dataTagToJsonArray[i].firstname, dataTagToJsonArray[i].uid, dataTagToJsonArray[i].uclient_ref) + "</span><br>";

          if (((dataTagToJsonArray[i].com != null)) &&
                  (dataTagToJsonArray[i].com != '')) {
            resulTag = resulTag + '<br><hr><div class="t-of-use mgs-med-note-imp"><i class="glyphicon glyphicon-exclamation-sign"></i>&nbsp;Un incident est identifié :<br> ' + dataTagToJsonArray[i].com + ' <br><i class="glyphicon glyphicon-barcode"></i>&nbsp;Taggué par: ' + mgsEncodeClientRef(dataTagToJsonArray[i].ucomfirstname, dataTagToJsonArray[i].ucomid, dataTagToJsonArray[i].ucomclient_ref) + ' - ' + dataTagToJsonArray[i].ucom_date + '</div>';
          }
          resulTag = resulTag + "<hr>";
    }
  }
  else{
    resulTag = "<h2>Navré, ce code barre est introuvable. Si vous pensez que c'est une erreur et que nous devrions le retrouver, contactez nous avec le code erreur BC404<h2>";
  }


  $("#block-of-tag").html(resulTag);
  $("#no-found-bc").show(100);

}


// Geolocalisation utils
var geoL = "N";

function getGeoL(){
  //console.log("start geolocalisation");
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(showPosition);
  } else {
    //console.log("Issue geolocation");
  }
  //console.log('Localisation: ' + geoL);
  $("#step-geol").val(geoL);
}
function showPosition(position) {
  //console.log('in showPosition');
  geoL = position.coords.latitude + ", " + position.coords.longitude;
}

// Camera utils
// isGrp can be true or false
function loadCameraRead(isGrp){
  let selectedDeviceId;
  let listOfBCToHandle = new Array();
  const maxLecture = 12;

  let readyToPExtMGS = new Array();
  let readyToPPureMGS = new Array();


  $("#mg-grp-step-btn").click(function() {

      // DEBUG CHANGE
      // 4 pures are OK ***
      /*
      listOfBCToHandle.push("M000080R3");
      listOfBCToHandle.push("M00007U88");
      listOfBCToHandle.push("M00007JC7");
      */

      /*
      listOfBCToHandle.push("M00008NH6");
      listOfBCToHandle.push("M00007AN4");
      listOfBCToHandle.push("M00006N8H");
      */


      //console.log("You have clicked on #mg-grp-step-btn");
      $('#grp-blc-cam').hide();
      for(i=0; i<listOfBCToHandle.length; i++){
        //console.log('Val: ' + listOfBCToHandle[i]);
        if(validateMGSCode(listOfBCToHandle[i])){
          //console.log('Val is code: ' + listOfBCToHandle[i]);
          let brokenMGBC = { id: decodeMGSCodePartId(listOfBCToHandle[i]), secure: decodeMGSCodePartSecure(listOfBCToHandle[i]) };
          readyToPPureMGS.push(brokenMGBC);
        }
        else{
          //console.log('Val is NOT code: ' + listOfBCToHandle[i]);
          readyToPExtMGS.push(listOfBCToHandle[i]);
        }
      }
      //console.log('readyToPPureMGS: ' + JSON.stringify(readyToPPureMGS));
      // readyToPPureMGS: [{"id":1,"secure":3301},{"id":1,"secure":3301},{"id":3,"secure":2953},{"id":2,"secure":4352}]
      //console.log('readyToPExtMGS: ' + JSON.stringify(readyToPExtMGS));
      //readyToPExtMGS: ["3263851322913","3222475413469","3263851322913","3222475413469"]
      $('#read-cb-grp-pure').val(JSON.stringify(readyToPPureMGS));
      $('#read-cb-grp-ext').val(JSON.stringify(readyToPExtMGS));

      //Then we submit all
      $("#mg-checkbc-form").submit();
  });


  function removeBarCodeFromList(val){
    //console.log('in removeBarCodeFromList: ' + listOfBCToHandle.length);
    //console.log('val : ' + val);
    for(i=0; i<listOfBCToHandle.length; i++){
      if(listOfBCToHandle[i] == val){
        listOfBCToHandle.splice(i, 1);
        break;
      }
    }
    displayGrpListBtn();
  }

  function displayGrpListBtn(){
    let displayListOfAlrdBC = '';
    let startButton = '';
    let btnReadGrpBC = '';
    for(i=0; i<listOfBCToHandle.length; i++){
      // Start as element zero
      startButton = '<button type="submit" id="grp-rBC-' + i + '" class="btn btn-default-light btn-md btn-block grp-all-btn" value="' + listOfBCToHandle[i] + '"';
      btnReadGrpBC = '><i class="monosp-ft-nc">'+listOfBCToHandle[i]+ '</i></button>'
      displayListOfAlrdBC = displayListOfAlrdBC + '<br>'+ startButton + btnReadGrpBC;
    }
    $('#grp-of-bc').html(displayListOfAlrdBC);
    if(listOfBCToHandle.length < maxLecture){
      $('#grp-nb-lec').html(listOfBCToHandle.length);
    }
    else{
      $('#grp-nb-lec').html(listOfBCToHandle.length + '<strong><i class="mgs-red">&nbsp;(Maximum)</i></strong>');
    }

    //We need to re-create all listener
    $( ".grp-all-btn" ).click(function() {
      removeBarCodeFromList($(this).val());
    });

    console.log('listOfBCToHandle.length: ' + listOfBCToHandle.length);
    // Display submit button
    // We need an action group so it will be available only if we scan at least 2 barecode
    if(listOfBCToHandle.length>1){
      $('#grp-tap-to-del').show();
      $('#mg-grp-step-btn').show();
      //console.log('listOfBCToHandle.length IN ');
    }
    else{
      $('#grp-tap-to-del').hide();
      $('#mg-grp-step-btn').hide();
      //console.log('listOfBCToHandle.length OUT ');
    }

  }

  // 1D barcode reader
  //const codeReader = new ZXing.BrowserBarcodeReader();
  //console.log('ZXing code reader initialized');

  //Aztec and QR reader
  const codeReader = new ZXing.BrowserMultiFormatReader();
  console.log('ZXing code reader initialized');
  codeReader.getVideoInputDevices()
      .then((videoInputDevices) => {
          const sourceSelect = document.getElementById('sourceSelect');
          selectedDeviceId = videoInputDevices[0].deviceId;

          // to be used if seval cam
          var poolCamJSON = {
              preferredCam: 0,
              cam: []
          };

          if (videoInputDevices.length > 1) {
              // Create the json for source device
              var icam = 0;
              videoInputDevices.forEach((element) => {

                  /*
                  const sourceOption = document.createElement('option');
                  sourceOption.text = element.label;
                  sourceOption.value = element.deviceId;
                  sourceSelect.appendChild(sourceOption);
                  */
                  poolCamJSON.cam.push({
                       "camId" : icam,
                       "label" : element.label,
                       "value"  : element.deviceId
                  });
                  icam = icam+1;
              })

              // We load preference cam here
              var prefCami = localStorage.getItem("preferredCam");
              if((typeof prefCami != 'undefined') && (prefCami != null)){
                  poolCamJSON.preferredCam = prefCami;
                  selectedDeviceId = poolCamJSON.cam[prefCami].value;
              }
              /*
              sourceSelect.onchange = () => {
                  selectedDeviceId = sourceSelect.value;
              }

              const sourceSelectPanel = document.getElementById('sourceSelectPanel');
              sourceSelectPanel.style.display = 'block';
              */
          }
          else{
            $("#switchCam").hide();
          }

          $("#resetButton").prop('disabled', true);

          $("#startButton").click(function() {
            $("#resetButton").prop('disabled', false);
            $("#startButton").prop('disabled', true);
            startScan();
          });

          $("#resetButton").click(function() {
            $("#resetButton").prop('disabled', true);
            $("#startButton").prop('disabled', false);
            endScan();
          });

          $("#startManualButton").click(function() {
            //We end the scan
            $("#resetButton").prop('disabled', true);
            $("#startButton").prop('disabled', false);
            endScan();
            $("#mgs-main-cam").hide();
            $("#mgs-manual-cam").show();

            $("#manualValid").click(function() {
              // Handle here the valid manual
              if($('#manual-cb').val().length > 0){
                  getGeoL();
                  //Go valid
                  let manualbc = $('#manual-cb').val();
                  $("#read-cb").val(manualbc);

                  if(validateMGSCode(manualbc)){
                    $("#read-cb-id").val(decodeMGSCodePartId(manualbc));
                    $("#read-cb-sec").val(decodeMGSCodePartSecure(manualbc));
                  }

                  //alert(manualbc + "valid MGS BC: " + validateMGSCode(manualbc) + " id: " + decodeMGSCodePartId(manualbc) +" sec: " + decodeMGSCodePartSecure(manualbc));
                  // Go to Post directly
                  $("#mg-checkbc-form").submit();
              }
            });
          });



          $( "#switchCam" ).click(function() {
            if (poolCamJSON.cam.length > 1){
                var getCurrentCami = parseInt(poolCamJSON.preferredCam);
                getCurrentCami = getCurrentCami+1;
                //We overpassed the length
                if(getCurrentCami > poolCamJSON.cam.length-1){
                  getCurrentCami = 0;
                }
                // Do all the changes and Restart
                poolCamJSON.preferredCam = getCurrentCami;
                localStorage.setItem("preferredCam", getCurrentCami);
                selectedDeviceId = poolCamJSON.cam[getCurrentCami].value;
                endScan();
                startScan();
            }
          });

      })
      .catch((err) => {
          console.error(err);
      })

      // Function description here
      function startScan(){
          codeReader.decodeOnceFromVideoDevice(selectedDeviceId, 'video').then((result) => {
              //console.log(result);
              document.getElementById('result').textContent = result.text;

              if (!isGrp){
                  //If we are not GRP we want to go to the check
                  $("#read-cb").val(result.text);
                  if(validateMGSCode(result.text)){
                    $("#read-cb-id").val(decodeMGSCodePartId(result.text));
                    $("#read-cb-sec").val(decodeMGSCodePartSecure(result.text));
                  }

                  $("#mg-checkbc-form").submit();

                  endScan();
              }
              else{
                    //We are GRP so we want to keep scan !
                    // GRP Marker
                    endScan();

                    if(listOfBCToHandle.length < maxLecture){
                        //console.log('Already read ?' + alreadyRead(result.text, listOfBCToHandle));
                        if (alreadyRead(result.text, listOfBCToHandle)) {
                          // It exists already
                          // We do nothing except we feedback
                          $('#grp-last-read').html(result.text);
                          $('#grp-last-already').show();
                        }
                        else{
                          // It DOES NOT exist
                          // Do feedback
                          $('#grp-read-fdb').show();
                          $('#grp-last-read').html(result.text);
                          $('#grp-last-already').hide();

                          // Update list
                          listOfBCToHandle.push(result.text);
                          // Add listener after recreation dom
                          displayGrpListBtn();
                        }
                    }
                    else{
                      //You already reach the max scan
                    }
                  startScan();
              }



          }).catch((err) => {
              console.error(err);
              document.getElementById('result').textContent = err;
          })
          //console.log(`Started continous decode from camera with id ${selectedDeviceId}`);
      }

      function endScan(){
        document.getElementById('result').textContent = '';
        codeReader.reset();
        console.log('Reset.');
      }

      function alreadyRead(val, list){
        let ret = false;
        for(i=0; i<list.length; i++){
          if(list[i] == val){
            return true;
            break;
          }
        }
        return ret;
      }
}

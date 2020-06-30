
$(document).on('turbolinks:load', function() {
  // Should be called at each visit
  //console.log('Scan TBL Page as changed');
  mainScanLoaderInCaseOfChange();
})

function mainScanLoaderInCaseOfChange(){
  if($('#mg-graph-identifier').text() == 'savebc-gr'){
    $("#mg-save-step-btn").click(function() {
        getGeoL();
    });
    getGeoL();
    // Load the step
    displayNext();
  }
  else if($('#mg-graph-identifier').text() == 'getnext-gr'){
      console.log('in getnext-gr');
      $("#mg-check-step-btn").click(function() {
          getGeoL();
      });
      getGeoL();
      loadCameraRead();
  }
  else if($('#mg-graph-identifier').text() == 'checkbc-gr'){
    try {
      loadCameraRead();
    }
    catch(err) {
      console.log(err.message);
      customLogErr(err.message);
    }
  }
  else if($('#mg-graph-identifier').text() == 'checktag-gr'){
    try {
      loadBCTag();
    }
    catch(err) {
      console.log(err.message);
      customLogErr(err.message);
    }
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

function displayNext(){
  var nextSteps = "";
  // target <option value="1" title="Tooltip">Réception</option>
  var nsp1 = '<option value="';
  var nsp2 = '" >';
  var nsp3 = '</option>';
  if(dataTagToJsonArray.length > 0){


    $("#read-mwfk").val(dataTagToJsonArray[0].mwkf_id);
    $("#read-rwfk").val(dataTagToJsonArray[0].rwkf_id);
    $("#read-cb-id").val(dataTagToJsonArray[0].bc_id);
    $('#read-step-txt').val(dataTagToJsonArray[0].end_step);
    $('#curr-status').html(dataTagToJsonArray[0].curr_step);

    for(var i=0; i<dataTagToJsonArray.length; i++){
        nextSteps = nextSteps + nsp1 + dataTagToJsonArray[i].end_step_id + nsp2 + dataTagToJsonArray[i].end_step + nsp3;
    }
    $("#stepCtrl").html(nextSteps);
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

    $("#readBC").html(dataTagToJsonArray[0].ref_tag);

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
  console.log("start geolocalisation");
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(showPosition);
  } else {
    console.log("Issue geolocation");
  }
  console.log('Localisation: ' + geoL);
  $("#step-geol").val(geoL);
}
function showPosition(position) {
  console.log('in showPosition');
  geoL = position.coords.latitude + ", " + position.coords.longitude;
}



// Camera utils
function loadCameraRead(){
  let selectedDeviceId;

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
                  var manualbc = $('#manual-cb').val();
                  $("#read-cb").val(manualbc);
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
              console.log(result);
              document.getElementById('result').textContent = result.text;


              $("#read-cb").val(result.text);
              $("#mg-checkbc-form").submit();

              endScan();

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
}

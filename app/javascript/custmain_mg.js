$(document).ready(function() {
  console.log('We are in MGFollowAPP JS2');
  //mainLoaderInCaseOfChange();
});

$(document).on('turbolinks:load', function() {
  // Should be called at each visit
  console.log('TBL Page as changed !');
  mainLoaderInCaseOfChange();
})

function mainLoaderInCaseOfChange(){
  if($('#mg-graph-identifier').text() == 'readbc'){
    loadCameraRead();
  }
}

function loadCameraRead(){
  let selectedDeviceId;
  const codeReader = new ZXing.BrowserBarcodeReader();
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
          }).catch((err) => {
              console.error(err);
              document.getElementById('result').textContent = err;
          })
          console.log(`Started continous decode from camera with id ${selectedDeviceId}`);
      }

      function endScan(){
        document.getElementById('result').textContent = '';
        codeReader.reset();
        console.log('Reset.');
      }
}

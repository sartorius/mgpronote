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
          const sourceSelect = $('#sourceSelect')
          selectedDeviceId = videoInputDevices[0].deviceId

          if (videoInputDevices.length > 1) {
              videoInputDevices.forEach((element) => {
                  const sourceOption = document.createElement('option')
                  sourceOption.text = element.label
                  sourceOption.value = element.deviceId
                  sourceSelect.appendChild(sourceOption)
              })

              sourceSelect.onchange = () => {
                  selectedDeviceId = sourceSelect.value;
              }

              const sourceSelectPanel = $('#sourceSelectPanel')
              sourceSelectPanel.style.display = 'block'
          }

          $('#startButton').addEventListener('click', () => {
              codeReader.decodeOnceFromVideoDevice(selectedDeviceId, 'video').then((result) => {
                  console.log(result)
                  $('#result').textContent = result.text
              }).catch((err) => {
                  console.error(err)
                  $('#result').textContent = err
              })
              console.log(`Started continous decode from camera with id ${selectedDeviceId}`)
          })

          $('#resetButton').addEventListener('click', () => {
              $('#result').textContent = '';
              codeReader.reset();
              console.log('Reset.')
          })

      })
      .catch((err) => {
          console.error(err)
      })
}

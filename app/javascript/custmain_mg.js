$(document).ready(function() {
  console.log('We are in MGFollowAPP JS2');

  const firstDeviceId = videoInputDevices[0].deviceId;
  codeReader
    .decodeOnceFromVideoDevice(firstDeviceId, 'video')
    .then(result => console.log(result.text))
    .catch(err => console.error(err));

});
